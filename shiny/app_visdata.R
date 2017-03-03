#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)
library(ggplot2)
library(dplyr)
library(OpenML)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
  # Application title
  titlePanel("OpenML 100 Benchmark"),
  sidebarLayout(
    sidebarPanel(
      uiOutput("dataset"),
      uiOutput("perfmeasure"),
      uiOutput("learner")
    ),
    mainPanel(plotlyOutput("plotly"))
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  #setwd("C:\\Users\\ag-compstat\\Documents\\openml100bm\\shiny")
  load(file = "runs.RData")
  allomlmeasures = listOMLEvaluationMeasures()$name
  pm = intersect(colnames(runs), gsub(pattern = "_", replacement = ".", allomlmeasures))
  
  output$dataset = renderUI({
    selectInput('ds', 'Dataset', unique(runs$data.name), selected = unique(runs$data.name)[1], multiple = TRUE)
  })
  
  output$perfmeasure = renderUI({
    selectInput('perf', 'Performance Measure', pm, selected = pm[1])
  })
   
  output$learner = renderUI({
    df1 = filter(runs, data.name %in% input$ds)
    selectInput('lrn', 'learner', unique(df1$flow.name), selected = unique(df1$flow.name), multiple = TRUE)
  })

  output$plotly = renderPlotly({
    df2 = filter(runs, data.name %in% input$ds, runs$flow.name %in% input$lrn)
    #eval(parse(text = paste0("p = ggplot(df2, aes(x = ", input$perf, ", y = data.name))")))
    p = ggplot(df2, aes(x = get(input$perf), y = data.name)) + xlab(input$perf)
    p = p +  geom_point(aes(colour = flow.name))
    p = ggplotly(p)  
    p
  })

}

# Run the application 
shinyApp(ui = ui, server = server)

