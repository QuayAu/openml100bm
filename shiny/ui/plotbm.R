tabpanel.plotly = list(
  fluidRow( #fluidrow for nicer layout
    box(width = 12, #also for layout
      h2("Plots"),
      column(12, #also for layout
        uiOutput("dataset"),
        uiOutput("perf"),
        uiOutput("learner"),
        plotlyOutput("plotly", width = 768)
      )
    )
  )
)