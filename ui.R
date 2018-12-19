library(shiny)
library(datamaps)
library(magrittr)
library(countrycode)
library(devtools)
library(rdrop2)
library(digest)

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
      actionButton("debugsa", "Show All"),
      
      #actionButton(
      #  "delete",
      #  "Clear map"
      #),
      
      
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
        
        tabPanel("Table", tableOutput("view")),
        tabPanel("File Upload",
                 fileInput("file1", "Choose CSV File",
                           multiple = FALSE,
                           accept = c("text/csv",
                                      "text/comma-separated-values,text/plain",
                                      ".csv")),
                 actionButton("upload", "Upload File"),

                 # Horizontal line ----
                 tags$hr(),

                 # Input: Checkbox if file has header ----
                 checkboxInput("header", "Header", TRUE),

                 # Input: Select separator ----
                 radioButtons("sep", "Separator",
                              choices = c(Comma = ",",
                                          Semicolon = ";",
                                          Tab = "\t"),
                              selected = ","),

                 # Input: Select quotes ----
                 radioButtons("quote", "Quote",
                              choices = c(None = "",
                                          "Double Quote" = '"',
                                          "Single Quote" = "'"),
                              selected = '"'),

                 # Horizontal line ----
                 tags$hr(),

                 # Input: Select number of rows to display ----
                 radioButtons("disp", "Display",
                              choices = c(Head = "head",
                                          All = "all"),
                              selected = "head"),



                 tableOutput("contents")),
        tabPanel("Contributions",
                 tags$div(
                    tags$p("Ahoy! Thank you for checking out the StationFinder project!\n"),
                    tags$p("If you want to contribute to this project,
                  you can follow the tutorial in the Contribute Section of the github repository:"),
                    tags$a(href = "https://github.com/Latz3/StationFinder", "StationFinder - Contribute")
                 )
                 ),
                
        id = "MainOut"
      )
    )
  )
)
)