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
					choices = sort(d$local_authority)),
			
			selectInput("gender", "Choose which gender to view data for:", 
					choices = c("both", "female", "male")),
			
			h4("Explanatory text"),
			
			p("There is a wealth of UK public health data available on 
			  www.data.gov.uk, but much of it is not very accessible without 
			  downloading and processing. The aim of this app is to take a 
			  small part of this data and visualise it, making it more 
			  accessible.", 
			  style = "font-family: 'baskerville'; font-si16pt"),
			
			p("This app allows you to explore alcohol-related admissions 
			  across local authorities in the UK. The data that this app 
			  uses is available at data.gov.uk. The specific file is available 
			  at the link below:", 
			  style = "font-family: 'baskerville'; font-si16pt"), 
			
			a(href = "http://www.hscic.gov.uk/catalogue/PUB15483/alc-eng-2014-tab_csv.csv",
				 "Link to raw alcohol data at data.gov.uk"),
			
			p("You select a local authority (a local government area in England) 
			  and whether you want to view data for men, women or both sexes. 
			  The app then displays where your chosen local authority is in the 
			  distribution of alcohol-related hospital admissions. The colour 
			  indicates whether your local authority is in the top third (red), 
			  middle third (amber) or bottom third (green) for alcohol-related 
			  hospital admissions. A text summary is displayed below the graph.", 
			  style = "font-family: 'baskerville'; font-si16pt"),
			
			p("People who might be interested in this information are local 
			  citizens who want to lobby for action, local government officials 
			  looking to see how their area is doing, or people deciding where 
			  to live.", 
			  style = "font-family: 'baskerville'; font-si16pt"),
			
			a(href = "https://github.com/stevenlsenior/Data_Products",
			  "Link to source code on GitHub")
		),
		
		# Show a summary of the dataset and an HTML table with the 
		# requested number of observations
		mainPanel(
			plotOutput("myPlot"),
			h3("Summary of output:"),
			h4("Local Authority:"),
			verbatimTextOutput("Text1"),
			h4("Alcohol-related hospital admissions per 100,000 people:"),
			verbatimTextOutput("Text2"),
			h4("% of local authorities that are better than your area:"),
			verbatimTextOutput("Text3")
		)
	)
))