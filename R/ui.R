library(shiny)
library(tidyverse)
library(lubridate)
library(dplyr)
library(DT)
library(bslib)
library(shinyFiles)
library(jsonlite)


#Create UI Comps
UICompDirectory <- "UIComponents/"

source(paste0(UICompDirectory, "Policies.R"), local = TRUE)
source(paste0(UICompDirectory, "Scratchpad.R"), local = TRUE)
source(paste0(UICompDirectory, "Dashboard.R"), local = TRUE)


shinyUI(
 # fluidPage(theme = bs_theme(version = 5, bootswatch = "minty"),
    fluidPage(
      theme = bs_theme(
  
      version = 5, bootswatch = "yeti",
      base_font = font_google("Roboto"),
      code_font = c("Courier", "monospace"),
      "primary" = "#007bff"
    )
    ,
  
            navbarPage(
           
              title = "Gradebook",
              tags$div(fileInput("upload", "", accept = c(".csv"))
            ),
            Dashboard,
            Policies,
            Scratchpad
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