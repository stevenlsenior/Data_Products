library(shiny)
d <- read.csv("alcohol_related_admissions.csv", stringsAsFactors = FALSE)

# Define UI for dataset viewer application
shinyUI(fluidPage(
	
	# Application title
	titlePanel("Shiny Text"),
	
	# Sidebar with controls to select a dataset and specify the
	# number of observations to view
	sidebarLayout(
		sidebarPanel(
			selectInput("la", "Choose a local authority:", 
					choices = d$local_authority),
			
			selectInput("gender", "Choose which gender to view data for:", 
					choices = c("both", "female", "male"))
		),
		
		# Show a summary of the dataset and an HTML table with the 
		# requested number of observations
		mainPanel(
			plotOutput("myPlot")
		)
	)
))