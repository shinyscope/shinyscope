library(shiny)
library(tidyverse)
library(lubridate)
library(dplyr)
library(DT)
library(shinythemes)


#Create UI Comps
UICompDirectory <- "UIComponents/"
source(paste0(UICompDirectory, "ConfigTab.R"), local = TRUE)
source(paste0(UICompDirectory, "AnalysisTab.R"), local = TRUE)


shinyUI(
  
  fluidPage(theme = shinytheme("yeti"),  
            navbarPage("",
                       ConfigTab,
                       AnalysisTab
            )
  ))