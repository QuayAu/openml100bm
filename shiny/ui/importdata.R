tabpanel.import =  list(
  fluidRow(
    box(width = 12,
      h2("Select the right columns:"),
      column(12, fileInput("data.import", "Import ARFF file", accept = ".arff")),
      uiOutput("data.columns"),
      DT::dataTableOutput('data.table')
    )
  )
)