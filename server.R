library(shiny)
library(classInt)
library(ggplot2)

d <- read.csv("alcohol_related_admissions.csv", stringsAsFactors = FALSE)

## Server code to make plot
shinyServer(
	function(input, output) {
		output$myPlot <- renderPlot({
			la <- input$la
			gender <- input$gender
			
			## Set variables for plotting, use global assignment to enable ggplot later
			if(gender == "both") {
				la_val <<- d$admissions_per_100000[d$local_authority == la]
				admissions <- d$admissions_per_100000
			}
			else if(gender == "male") {
				la_val <<- d$admissions_per_100000_males[d$local_authority == la]
				admissions <- d$admissions_per_100000_males
			}
			else if(gender == "female") {
				la_val <<- d$admissions_per_100000_females[d$local_authority == la]
				admissions <- d$admissions_per_100000_females
			}
			# Set colours for top, middle and bottom thirds of distribution
			cols <- c("darkgreen", "orange", "red")
			
			# Set line colour on whether la_val is top, middle or bottom third
			breaks <- classIntervals(admissions, n=3, style="quantile")
			line_col <- cols[findInterval(la_val, breaks$brks)]
			
			dd <- with(density(admissions), data.frame(x,y))
			g <- ggplot(dd, aes(x = x, y = y))
			p <- g + geom_line(color = "black")  +
				layer(data = dd, mapping = aes(x = ifelse(x < la_val, x, la_val), y = y), 
					geom = "area", 
					geom_params = list(fill = line_col,alpha = .3)) +
				scale_y_continuous(limits = c(0,max(dd$y)), name="Density") +
				geom_vline(aes(xintercept = la_val), color = line_col, linetype="dashed") +
				scale_x_continuous(name = "Admissions per 100,000 population") + theme_classic()
			print(p)

		})
		
	}
)