#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
  # Application title
  titlePanel("OpenML 100 Benchmark"),
   
  # Show a plot of the generated distribution
  mainPanel(
     tableOutput("bmrtable")
  ),
  uiOutput('datasets')
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  #setwd("C:\\Users\\ag-compstat\\Desktop\\openml_workshop\\benchmark\\shiny")
   load(file = "../results.RData")
   bmrperf = getBMRAggrPerformances(bmr, as.df = TRUE)
   # output$bmrtable <- renderTable({
   #   bmrperf
   # })
   output$datasets = renderUI({
     selectInput('columns2', 'Columns', unique(bmrperf$task.id))
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

