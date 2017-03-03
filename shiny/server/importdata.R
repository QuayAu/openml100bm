dataframe = reactive({
  req(input$data.import) #only do something, if you push the button
  f = input$data.import$datapath
  readARFF(f)
})

output$data.columns = renderUI({
  req(dataframe()) #only execute the rest, if dataframe is available
  dataframe = dataframe() #dataframe needs do be assigned reactively 
  list(
    column(6, selectInput('dc', 'data column', colnames(dataframe), selected = FALSE)),
    column(6, selectInput('pc', 'performance columns', colnames(dataframe), multiple = TRUE)),
    column(6, selectInput('lc', 'learner column', colnames(dataframe), selected = FALSE))
    )
    
})


output$data.table = DT::renderDataTable({
  req(dataframe())
  dataframe = dataframe()
  dataframe
}, options = list(scrollX = TRUE))
