#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(datamaps)
library(magrittr)
library(countrycode)
library(devtools)
#shiny debug options
options(shiny.trace=TRUE)
options(shiny.reactlog=TRUE)

#load data
cn <- unique(countrycode::codelist$iso3c)
cn <- cn[!is.na(cn)]
data <- data.frame(name = cn, color = ceiling(runif(length(cn), 1, 50)))
newships = read.csv("ships.csv", header=TRUE,sep=";")
adlab = read.csv("admiral_labels.csv", header=TRUE,sep=";")

# Define UI for application
shinyUI(fluidPage(
  
  titlePanel("StationFinder 1.0"),
  
  sidebarLayout(
    
    sidebarPanel(
      h4("Royal Navy Officers"),
      selectInput(
        "officerSelect",
        "Select Officer",
        choices = setNames(as.character(adlab$P_ID), as.character(adlab$Label))
        
      ),
      actionButton("update", "Update"),
      h4("Ships"),
      #selectInput(
      #  "showall",
      #  "Show All",
      #  
      #  choices = c("Hull", "Propulsion", "Displacement") ),
      
      # actionButton("sub", "Show All"),
      actionButton("debugsa", "Debug Button SA"),
      
      actionButton(
        "delete",
        "Clear map"
      ),
      
      
      selectInput(
        "shipname",
        "Name",
        choices = as.character(newships$Label)
      ),
      actionButton("subshipname","Show by Name"),
      selectizeInput(
        "shipsbyprop",
        "Propulsion",
        choices = list("Sail" = as.character(newships[newships$Propulsion=="Sail", "Label"]),
                       "Screw" =  as.character(newships[newships$Propulsion=="Screw", "Label"]),
                       "Paddle" =  as.character(newships[newships$Propulsion=="Paddle", "Label"])
        )
      ),
      actionButton("subshipsprop","Show Ships by Propulsion"),
      selectizeInput(
        "shipsbydisplacement",
        "Displacement",
        choices = list("<500" =as.character(newships[newships$Displacement < 500, "Label"]),
                       "500-1500" = as.character(newships[newships$Displacement < 500 & newships$Displacement <1500, "Label"]),
                       ">1500" = as.character(newships[newships$Displacement > 1500, "Label"]))
      ),
      actionButton("subshipsdisplacement","Show Ships by Displacement")
      
      
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Map", datamapsOutput("map")), 
        
        tabPanel("Table", tableOutput("view"))
      )
    )
  )
)
)