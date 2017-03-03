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
  
  uiOutput("dataset"),
   
  mainPanel(
    DT::dataTableOutput("bmrtable")
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  #setwd("C:\\Users\\ag-compstat\\Desktop\\openml_workshop\\benchmark\\shiny")
   load(file = "../results.RData")
   library(mlr)
   bmrperf = getBMRAggrPerformances(bmr, as.df = TRUE)

   output$dataset = renderUI({
     selectInput('ds', 'Dataset', unique(bmrperf$task.id))
   })
   
   output$perfmeasure = renderUI({
     selectInput('perf', 'Performance Measure', getBMRMeasureIds(bmr))
   })
   
   output$bmrtable = DT::renderDataTable({
     bmrperf[bmrperf$task.id == input$ds, ]
   })
    
}

# Run the application 
shinyApp(ui = ui, server = server)

