library(shiny)
library(tidyverse)
library(lubridate)
library(dplyr)
library(DT)
library(bslib)



#Create UI Comps
UICompDirectory <- "UIComponents/"
source(paste0(UICompDirectory, "AnalysisTab.R"), local = TRUE)
source(paste0(UICompDirectory, "StudentViewTab.R"), local = TRUE)
source(paste0(UICompDirectory, "AssignmentView.R"), local = TRUE)
source(paste0(UICompDirectory, "TestingTab.R"), local = TRUE)


shinyUI(
  fluidPage(theme = bs_theme(version = 5, bootswatch = "minty"),
            navbarPage(title = tags$div(
              "",
              tags$span("", style = "margin-right: 0px;margin-top: -20px; margin-bottom: -20px;"),
              tags$div(fileInput("upload", "", accept = c(".csv")),
                       style = "display:inline; width: 20%;margin-top: -20px; margin-bottom: -20px;")
            ),
            AnalysisTab,
            StudentViewTab,
            AssignmentView,
            TestingTab
            )
  ))