library(shiny)
library(tidyverse)
library(lubridate)
library(dplyr)
library(DT)
library(bslib)



#Create UI Comps
UICompDirectory <- "UIComponents/"

source(paste0(UICompDirectory, "Home.R"), local = TRUE)
source(paste0(UICompDirectory, "Configurations.R"), local = TRUE)
source(paste0(UICompDirectory, "Scratchpad.R"), local = TRUE)


shinyUI(
  fluidPage(theme = bs_theme(version = 5, bootswatch = "minty"),
            navbarPage(title = "shinyscope",
              tags$div(fileInput("upload", "", accept = c(".csv"))
            ),
            Home,
            Configurations,
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