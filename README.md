# Alcohol-related hosiptal admissions in English local authority areas

### Code developed for the 'Developing Data Products' Coursera course. 

**Steve Senior**

The code here is for a Shiny app that displays the distribution of alcohol-related hospital admissions in English local authority areas, and overlays a line showing where a selected local authority is in the distribution. The app also calculates some simple statistics.

The two files, server.R and ui.R together comprise a Shiny application. This application can be found on my [shinyapps.io page](https://stevenlsenior.shinyapps.io/Data_Products/).

The code for server.R is messy - it repeats if-else statements because I couldn't figure out how to do this calculation outside of the reactive code elements in such a way that it is available to all the subsequent elements. Always interested in suggestions on how to improve it.