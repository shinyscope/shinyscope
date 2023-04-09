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
            navbarPage(title = "shinyscope",
              tags$div(fileInput("upload", "", accept = c(".csv"))
            ),
            AnalysisTab,
            StudentViewTab,
            AssignmentView,
            TestingTab
            ),
            hr(),
            br(),
            br(),
            tags$div(class="disclaimer", 
                     tags$style(".center {text-align:center}"),
                     div(textOutput("disclaimer"), class = "center")),
            br(),
            br()
  ))