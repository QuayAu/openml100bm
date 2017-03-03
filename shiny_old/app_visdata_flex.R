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
library(farff)
library(shinydashboard)

# Define UI for application that draws a histogram
ui <- dashboardPage(
  dashboardHeader(title = "Plot Benchmark Results"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Choose Columns", tabName = "cols"),
      menuItem("Plots", tabName = "plots")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "cols",
        h2("Select the right columns:"),
        uiOutput("datacolumn"),
        uiOutput("perfcolumn"),
        uiOutput("learnercolumn"),
        DT::dataTableOutput('datatable')
      ),
      
      tabItem(tabName = "plots",
        h2("Plots"),
        sidebarLayout(
          sidebarPanel(
            uiOutput("dataset"),
            uiOutput("perf"),
            uiOutput("learner")
          ),
          mainPanel(plotlyOutput("plotly"))
        )
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  #setwd("C:\\Users\\ag-compstat\\Documents\\openml100bm\\shiny")
  dataframe = readARFF(file.choose())
  
  #Choose Columns page
  
  output$datacolumn = renderUI({
    selectInput('dc', 'data column', colnames(dataframe), selected = FALSE)
  })
  
  output$perfcolumn = renderUI({
    selectInput('pc', 'performance columns', colnames(dataframe), multiple = TRUE)
  })
  
  output$learnercolumn = renderUI({
    selectInput('lc', 'learner column', colnames(dataframe), selected = FALSE)
  })
  
  output$datatable = DT::renderDataTable({
    dataframe
  }, options = list(scrollX = TRUE))
  
  
  #plots page
  output$dataset = renderUI({
    selectInput('ds', 'data set', unique(dataframe[, input$dc]), selected = FALSE, multiple = TRUE)
  })
  
  output$perf = renderUI({
    selectInput('perf', 'performance measure', input$pc, selected = FALSE)
  })
  
  output$learner = renderUI({
    selectInput('lrn', 'learner', unique(dataframe[, input$lc]), selected = FALSE, multiple = TRUE)
  })
  
  
  output$plotly = renderPlotly({
    eval(parse(text =  paste0("df = filter(dataframe,", input$dc, "%in% input$ds, ", input$lc, "%in% input$lrn)")))
    print(paste0("df = filter(dataframe,", input$dc, "%in% input$ds, ", input$lc, "%in% input$lrn)"))
    #df = dplyr::filter(dataframe, get(input$dc) %in% input$ds, get(input$lc) %in% input$lrn)
    #p = ggplot(df, aes(x = get(input$perf), y = get(input$dc))) + xlab(input$perf) + ylab(input$dc)
    eval(parse(text =  paste0("p = ggplot(df, aes(x =", input$perf, ", y =", input$dc, "))")))
    #p = p + geom_point(aes(colour = get(input$lc)))
    eval(parse(text =  paste0("p = p + geom_point(aes(colour = ", input$lc, "))")))
    p = ggplotly(p)
    p
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

