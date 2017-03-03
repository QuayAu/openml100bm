library(ggplot2)
library(dplyr)
library(OpenML)
library(farff)


shinyServer(function(input, output, session) {
  
  server.files = list.files(path = "./server", pattern = "*.R")
  server.files = paste0("server/", server.files)
  for (i in seq_along(server.files)) {
    source(server.files[i], local = TRUE)
  }
  
  session$onSessionEnded(stopApp)
})