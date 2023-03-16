#load libraries
library(shiny)
library(dplyr)

#load ui and server
source("ui.R")
source("server.R")


shinyApp(ui, server)

