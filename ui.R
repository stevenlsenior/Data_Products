library(shiny)
d <- read.csv("alcohol_related_admissions.csv", stringsAsFactors = FALSE)

# Define UI for dataset viewer application
shinyUI(fluidPage(
	
	# Application title
	titlePanel("Alcohol-related hospital admissions by English local authority"),
	
	# Sidebar with controls to select a dataset and specify the
	# number of observations to view
	sidebarLayout(
		sidebarPanel(
			selectInput("la", "Choose a local authority:", 
					choices = d$local_authority),
			
			selectInput("gender", "Choose which gender to view data for:", 
					choices = c("both", "female", "male")),
			
			h4("Explanatory text")
			p("This app allows you to explore alcohol-related admissions 
			  across local authorities in the UK. The data that this app 
			  uses is available at data.gov.uk. The specific file is available 
			  at this:") tags$a(href = "http://www.hscic.gov.uk/catalogue/PUB15483/alc-eng-2014-tab_csv.csv",
				 "Link")
		),
		
		# Show a summary of the dataset and an HTML table with the 
		# requested number of observations
		mainPanel(
			plotOutput("myPlot")
		)
	)
))