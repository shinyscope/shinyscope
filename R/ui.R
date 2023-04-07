library(shiny)
library(tidyverse)
library(lubridate)
library(dplyr)
library(DT)
library(shinythemes)


#Create UI Comps
UICompDirectory <- "UIComponents/"
source(paste0(UICompDirectory, "AnalysisTab.R"), local = TRUE)
source(paste0(UICompDirectory, "StudentViewTab.R"), local = TRUE)
source(paste0(UICompDirectory, "AssignmentView.R"), local = TRUE)
source(paste0(UICompDirectory, "TestingTab.R"), local = TRUE)



shinyUI(
  
  fluidPage(theme = shinytheme("yeti"),  
            navbarPage("",
                       AnalysisTab,
                       StudentViewTab,
                       AssignmentView,
                       TestingTab
                
            )
  ))