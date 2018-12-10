#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
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
#load data
cn <- unique(countrycode::codelist$iso3c)
cn <- cn[!is.na(cn)]
data <- data.frame(name = cn, color = ceiling(runif(length(cn), 1, 50)))
newships = read.csv("ships.csv", header=TRUE,sep=";")
adlab = read.csv("admiral_labels.csv", header=TRUE,sep=";")

#shiny debug
options(shiny.trace=TRUE)
options(shiny.reactlog=TRUE)

# Define server logic

shinyServer(function(input, output){
 
  
  arc <- reactive({
    
    data.frame( fromlong = strsplit( input$from, "~" )[[1]][1],
                fromlat = strsplit( input$from, "~" )[[1]][2],
                tolong = strsplit( input$to, "~" )[[1]][1],
                tolat = strsplit( input$to, "~" )[[1]][2])
  })
  
  
  
  updated_data <- reactive({
    data.frame(pid= input$officerSelect
    )
  })
  
  updateshipname <- reactive({
    
    df = data.frame(Shipname = input$shipname,
                    Displacement = as.numeric(newships[newships$Label == input$shipname, "Displacement"]),
                    Radius = as.numeric(newships[newships$Label == input$shipname, "Displacement"])*0.02,
                    Hull = newships[newships$Label == input$shipname, "Hull"],
                    Propulsion = newships[newships$Label == input$shipname, "Propulsion"],
                    Station = newships[newships$Label == input$shipname, "Station"],
                    Lat = newships[newships$Label == input$shipname, "Lat"],
                    Long = newships[newships$Label == input$shipname, "Long"],
                    ColVal = newships[newships$Label == input$shipname, "ColVal"]
    )
    
  })
  
  
  updateprop <- reactive({
    
    df = data.frame(Shipname = input$shipsbyprop,
                    Displacement = as.numeric(newships[newships$Label == input$shipsbyprop, "Displacement"]),
                    Radius = as.numeric(newships[newships$Label == input$shipsbyprop, "Displacement"])*0.02,
                    Hull = newships[newships$Label == input$shipsbyprop, "Hull"],
                    Propulsion = newships[newships$Label == input$shipsbyprop, "Propulsion"],
                    Station = newships[newships$Label == input$shipsbyprop, "Station"],
                    Lat = newships[newships$Label == input$shipsbyprop, "Lat"],
                    Long = newships[newships$Label == input$shipsbyprop, "Long"],
                    ColVal = newships[newships$Label == input$shipsbyprop, "ColVal"]
    )
    
    
  })
  
  updatedisplacement <- reactive({
    
    df = data.frame(Shipname = input$shipsbydisplacement,
                    Displacement = as.numeric(newships[newships$Label == input$shipsbydisplacement, "Displacement"]),
                    Radius = as.numeric(newships[newships$Label == input$shipsbydisplacement, "Displacement"])*0.02,
                    Hull = newships[newships$Label == input$shipsbydisplacement, "Hull"],
                    Propulsion = newships[newships$Label == input$shipsbydisplacement, "Propulsion"],
                    Station = newships[newships$Label == input$shipsbydisplacement, "Station"],
                    Lat = newships[newships$Label == input$shipsbydisplacement, "Lat"],
                    Long = newships[newships$Label == input$shipsbydisplacement, "Long"],
                    ColVal = newships[newships$Label == input$shipsbydisplacement, "ColVal"]
    )
    
    
  })
  output$map <- renderDatamaps({
    datamaps(responsive = TRUE) %>%
      config_geo(border.color = "lightgreen",
                 border.opacity = 0) %>%
      add_data(newships) %>%
      add_bubbles(Long, Lat, log(Displacement)+5, ColVal, sprintf("Ship: %s<br/>Station: %s<br/>Displacement(BM): %.0f",Label, Station, Displacement), colors = c("blue", "red", "yellow", "grey"))
  })
  
  output$view <- renderTable({
    head(newships, n=20)
  })
  observeEvent(input$update, {
    
    output$map <- renderDatamaps({
      data %>%
        datamaps(responsive = TRUE) %>%
        config_geo(border.opacity = 0,
                   border.color = "lightgreen") %>%
        
        add_data(newships[newships$P_ID == updated_data()$pid,]) %>%
        add_bubbles(Long, Lat, log(Displacement)+5, ColVal, sprintf("Ship: %s<br/>Station: %s<br/>Displacement(BM): %.0f",Label, Station, Displacement), colors = c("blue", "red", "yellow", "grey")) %>%
        config_bubbles(fill.opacity = 0,
                       border.opacity = 0.2)
    })
    output$view <- renderTable({
      head(newships[newships$P_ID == updated_data()$pid,], n=20)
    }) 
    
  })
  
  observeEvent(input$submit, {
    datamapsProxy("map") %>%
      add_data(arc()) %>%
      #update_arcs_name(from, to)
      update_arcs(fromlat,fromlong,tolat,tolong)
    #update_arcs(from, to)
  })
  
  observeEvent(input$subshipname, {
    datamapsProxy("map") %>%
      add_data(updateshipname()) %>% # pass updated data
      update_bubbles(Long, Lat, Radius,ColVal, sprintf("Ship: %s<br/>Station: %s<br/>Displacement(BM): %.0f",Shipname, Station, Displacement), colors = c("blue", "red", "yellow", "grey")) %>% # update
      config_bubbles(popup.on.hover = TRUE,
                     highlight.on.hover = TRUE,
                     highlight.border.width = 3)
  })
  
  observeEvent(input$subshipsprop, {
    datamapsProxy("map") %>%
      add_data(updateprop()) %>% # pass updated data
      update_bubbles(Long, Lat, Radius,ColVal, sprintf("Ship: %s<br/>Station: %s<br/>Displacement(BM): %.0f",Shipname, Station, Displacement),colors = c("blue", "red", "yellow", "grey")) %>%
      config_bubbles(popup.on.hover = TRUE,
                     highlight.on.hover = TRUE)# update
  })
  observeEvent(input$subshipsdisplacement, {
    datamapsProxy("map") %>%
      add_data(updatedisplacement()) %>% # pass updated data
      update_bubbles(Long, Lat, Radius, ColVal, sprintf("Ship: %s<br/>Station: %s<br/>Displacement(BM): %.0f",Shipname, Station, Displacement),colors = c("blue", "red", "yellow", "grey")) %>%
      config_bubbles(popup.on.hover = TRUE,
                     highlight.on.hover = TRUE)# update
  })
  observeEvent(input$debugsa, {
    output$map <- renderDatamaps({
      data %>%
        datamaps(responsive = TRUE) %>%
        config_geo(border.opacity = 0,
                   border.color = "lightgreen") %>%
        add_data(newships) %>%
        add_bubbles(Long, Lat, log(Displacement)+5, ColVal, sprintf("Ship: %s<br/>Station: %s<br/>Displacement(BM): %.0f",Label, Station, Displacement), colors = c("blue", "red", "yellow", "grey")) #%>%
      #config_bubbles(fill.opacity = 0.5)
    })
  })
  
  observeEvent(input$delete, {
    output$map <- renderDatamaps({
      data %>%
        datamaps(responsive = TRUE) %>%
        config_geo(border.opacity = 0,
                   border.color = "lightgreen")
      
    })
  })
  
  
  
  
  
})
