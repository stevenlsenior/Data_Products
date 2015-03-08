## This R script loads and prepares data on alcohol related admissions for local 
## authorities in the UK. This data is then used to create a Shiny app that allows 
## users to view alcohol related admissions in their region and compare them to national and
## distribution.

get_alc_admissions_data <- function(){
	# Download data from data.gov.uk
	data_URL <- paste("http://www.hscic.gov.uk/catalogue/PUB15483/alc-eng-2014-tab_csv.csv", 
				sep = "")
	
	download.file(data_URL, destfile = "raw_alcohol_stats.csv")
	raw <- read.csv("raw_alcohol_stats.csv")
	
	# Select local authority alcohol related admissions data from table 4.6
	la_start <- grep("Table 4.6", raw[,1])
	la_stop  <- grep("Table 4.7", raw[,1])
	processed_1 <- raw[la_start:la_stop,]
	
	# Tidy the data
	## Drop rows containing footnotes
	footer_start <- grep("Footnotes", processed_1[,1])
	processed_2 <- processed_1[-(footer_start:nrow(processed_1)),]
	
	## Get rid of empty rows and columns
	non.empty <- function(x, min_full = 1, empty_char = "", by.row = TRUE){
		full_cells <- logical()
		if(by.row == TRUE){
			for(i in 1:nrow(x)){
				full_cells[i] <- sum(x[i,] != empty_char, na.rm = TRUE)
			}
		}
		else {
			for(i in 1:ncol(x)){
				full_cells[i] <- sum(x[,i] != empty_char, na.rm = TRUE)
			}
		}
		not_empty <- full_cells > min_full
	}
	
	keep_rows <- non.empty(processed_2)
	keep_cols <- non.empty(processed_2, by.row = FALSE)
	
	processed_3 <- processed_2[keep_rows, keep_cols]
	
	## Rename columns and drop rows containing headers
	col_names <- character(length = ncol(processed_3))
	
	for(i in 1:ncol(processed_3)){
		col_names[i] <- paste(processed_3[1,i], processed_3[2,i])
	}
	
	library(stringr)
	col_names <- str_trim(col_names)
	col_names <- gsub(" ", "_", col_names)
	col_names <- gsub(",", "", col_names)
	
	names(processed_3) <- col_names
	processed_4 <- processed_3[-(1:2),]
	
	## Drop columns with the same value in every row
	keep_cols <- logical(length = ncol(processed_4))
	for(i in 1:ncol(processed_4)){
		if(length(unique(processed_4[,i])) > 2){
			keep_cols[i]  <- TRUE
		}
	}
	
	processed_5 <- processed_4[,keep_cols]
	
	## Convert numeric variables from factor to numeric class
	for(i in 5:ncol(processed_5)){
		processed_5[,i] <- as.character(processed_5[,i])
		processed_5[,i] <- gsub(",", "", processed_5[,i])
		processed_5[,i] <- as.numeric(processed_5[,i])
	}
	
	processed_5[,4] <- as.character(processed_5[,4])
	
	## Remove 'England' row
	processed_6 <- processed_5[-grepl("ENGLAND", processed_5[,4]),]
	
	## Create separate 'Region' variable
	Region <- character(length = nrow(processed_6))
	for(i in 1:nrow(processed_6)){
		if(processed_6[i,4] == toupper(processed_6[i,4])){
			Region[i] <- as.character(processed_6[i,4])	
		} 
		else Region[i] <- Region[i-1]
	}
	
	## Get rid of separate Region entries
	processed_7 <- cbind(processed_6[,1:4], Region, processed_6[,5:10])
	LA_rows <- processed_7$Region_and_LA_Name != processed_7$Region
	processed_8 <- processed_7[LA_rows,]
	
	## Tidy up final column names
	library(dplyr)
	data <- rename(processed_8, 
			   local_authority = Region_and_LA_Name)
	names(data) <- tolower(names(data))
	names(data) <- gsub(",", "", names(data))
	names(data) <- gsub("persons9_", "", names(data))
	names(data) <- gsub("number_of_", "", names(data))
	names(data) <- gsub("_population10", "", names(data))
	names(data) <- gsub("\\.1", "_males", names(data))
	names(data) <- gsub("\\.2", "_females", names(data))
	
	
	return(data)
}

## The alc_admissions_plot function plots a density chart of the admissions data
## and overlays a cutoff based on whether the selected local authority is

alc_admissions_plot <- function(data, gender = "both", la = "County Durham"){
	library(ggplot2); library(RColorBrewer); library(classInt)
	
	## Make sure gender is right class and case
	gender <- tolower(as.character(gender))
	
	## Check that la value is valid
	if(!is.element(la, data$local_authority)){
		stop("la must be a string giving a valid local authority name")
	}
	else la <<- la
	
	## Set variables for plotting, use global assignment to enable ggplot later
	if(gender == "both") {
		la_val <<- data$admissions_per_100000[data$local_authority == la]
		admissions <<- data$admissions_per_100000
	}
	else if(gender == "male") {
		la_val <<- data$admissions_per_100000_males[data$local_authority == la]
		admissions <- data$admissions_per_100000_males
	}
	else if(gender == "female") {
		la_val <<- data$admissions_per_100000_females[data$local_authority == la]
		admissions <<- data$admissions_per_100000_females
	}
	else stop("gender must be a string equal one of 'both', 'male' or 'female'.")
	
	# Set colours for top, middle and bottom thirds of distribution
	cols <- c("darkgreen", "orange", "red")
	breaks <- classIntervals(admissions, n=3, style="quantile")
	line_col <<- cols[findInterval(la_val, breaks$brks)]
		
	# Make the plot
	dd <- with(density(admissions),data.frame(x,y))
	
	ggplot(data = dd, mapping = aes(x = x, y = y)) + geom_line(color = "black") +
		layer(data = dd, mapping = aes(x = ifelse(x < la_val, x, la_val), y = y), 
			geom = "area", 
			geom_params = list(fill = line_col,alpha = .3)) +
		scale_y_continuous(limits = c(0,max(dd$y)), name="Density") +
		geom_vline(aes(xintercept = la_val), color = line_col, linetype="dashed") +
		scale_x_continuous(name = "Admissions per 100,000 population") +
		labs(title = "Alcohol Related Hospital Admissions") + theme_minimal()	
}