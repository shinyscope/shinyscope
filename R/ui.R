library(shiny)
library(tidyverse)
library(lubridate)
library(dplyr)
library(DT)
library(shinythemes)


#Create UI Comps
UICompDirectory <- "UIComponents/"
source(paste0(UICompDirectory, "AnalysisTab.R"), local = TRUE)
source(paste0(UICompDirectory, "ConfigTab.R"), local = TRUE)
source(paste0(UICompDirectory, "Monika.R"), local = TRUE)
source(paste0(UICompDirectory, "Nikita.R"), local = TRUE)
source(paste0(UICompDirectory, "Matt.R"), local = TRUE)


shinyUI(
  
  fluidPage(theme = shinytheme("yeti"),  
            navbarPage("",
                       AnalysisTab,
                       ConfigTab,
                       Monika,
                       Nikita,
                       Matt
                
            )
  ))