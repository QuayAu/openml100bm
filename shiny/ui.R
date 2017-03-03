library(shiny)
library(shinydashboard)
library(shinyjs)
library(shinyBS)
library(DT)
library(plotly)

ui.files = list.files(path = "./ui", pattern = "*.R")
ui.files = paste0("ui/", ui.files)

for (i in seq_along(ui.files)) {
  source(ui.files[i], local = TRUE)
}

shinyUI(
  dashboardPage(
    dashboardHeader(title = "OpenML100 Benchmark"),
    dashboardSidebar(
      sidebarMenu(
        menuItem("Choose Columns", tabName = "cols"),
        menuItem("Plots", tabName = "plots")
      )
    ),
    dashboardBody(
      tabItems(
        tabItem(tabName = "cols", tabpanel.import),
        tabItem(tabName = "plots", tabpanel.plotly)
      )
    )
  )
)  
