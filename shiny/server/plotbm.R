output$dataset = renderUI({
  req(dataframe()) #solange dataframe nicht vorhanden, passiert nichts
  dataframe = dataframe() #dataframe neu reingeladen wird
  selectInput('ds', 'data set', unique(dataframe[, input$dc]), selected = FALSE, multiple = TRUE)
})

output$perf = renderUI({
  selectInput('perf', 'performance measure', input$pc, selected = FALSE)
})

output$learner = renderUI({
  req(dataframe())
  dataframe = dataframe()
  selectInput('lrn', 'learner', unique(dataframe[, input$lc]), selected = FALSE, multiple = TRUE)
})

output$plotly = renderPlotly({
  req(dataframe())
  dataframe = dataframe()
  
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