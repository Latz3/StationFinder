library(shiny)
library(datamaps)
library(magrittr)
library(countrycode)
library(devtools)
library(rdrop2)
library(digest)

#load data
cn <- unique(countrycode::codelist$iso3c)
cn <- cn[!is.na(cn)]
data <- data.frame(name = cn, color = ceiling(runif(length(cn), 1, 50)))
newships = read.csv("ships.csv", header=TRUE,sep=";")
adlab = read.csv("admiral_labels.csv", header=TRUE,sep=";")


#dropacc auth
token = readRDS("droptoken.rds")

#shiny debug
options(shiny.trace=TRUE)
options(shiny.reactlog=TRUE)

# Define server logic

shinyServer(function(input, output){
 
  
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
    datamaps() %>%
      config_geo(popup.on.hover = FALSE,
                 highlight.on.hover = FALSE,
                 border.color = "lightgreen",
                 border.opacity = 0) %>%
      add_data(newships) %>%
      add_bubbles(Long, Lat, radius = 10, ColVal, sprintf("Ship: %s<br/>Station: %s<br/>Displacement(BM): %.0f",Label, Station, Displacement), colors = c("blue", "red", "yellow", "grey"))
  })
  showTab(inputId = "MainOut", target = "Table")
  output$view <- renderTable({
    head(newships, n=20)
  })
  #output$pie <- renderPlot({
  #  blub = as.data.frame(table(paste(newships$Hull, newships$Propulsion, sep="~")))
  #  pie(blub$Freq,labels = blub$Var1, main = "Distribution of Ship Characteristics")
  #})
  
  observeEvent(input$update, {
    
    output$map <- renderDatamaps({
      data %>%
        datamaps() %>%
        config_geo(popup.on.hover = FALSE,
                   highlight.on.hover = FALSE,
                   border.opacity = 0,
                   border.color = "lightgreen") %>%
        
        add_data(newships[newships$P_ID == updated_data()$pid,]) %>%
        add_bubbles(Long, Lat, radius = 10, ColVal, sprintf("Ship: %s<br/>Station: %s<br/>Displacement(BM): %.0f",Label, Station, Displacement), colors = c("blue", "red", "yellow", "grey")) %>%
        config_bubbles(fill.opacity = 0,
                       border.opacity = 0.2)
    })
    showTab(inputId = "MainOut", target = "Table")
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
      update_bubbles(Long, Lat, radius = 10,ColVal, sprintf("Ship: %s<br/>Station: %s<br/>Displacement(BM): %.0f",Shipname, Station, Displacement), colors = c("blue", "red", "yellow", "grey")) %>% # update
      config_bubbles(popup.on.hover = TRUE,
                     highlight.on.hover = TRUE,
                     highlight.border.width = 3)
    hideTab(inputId = "MainOut", target = "Table")
  })
  
  observeEvent(input$subshipsprop, {
    datamapsProxy("map") %>%
      add_data(updateprop()) %>% # pass updated data
      update_bubbles(Long, Lat, radius = 10,ColVal, sprintf("Ship: %s<br/>Station: %s<br/>Displacement(BM): %.0f",Shipname, Station, Displacement), colors = c("blue", "red", "yellow", "grey")) %>%
      config_bubbles(popup.on.hover = TRUE,
                     highlight.on.hover = TRUE)# update
    hideTab(inputId = "MainOut", target = "Table")
  })
  observeEvent(input$subshipsdisplacement, {
    datamapsProxy("map") %>%
      add_data(updatedisplacement()) %>% # pass updated data
      update_bubbles(Long, Lat, radius = 10, ColVal, sprintf("Ship: %s<br/>Station: %s<br/>Displacement(BM): %.0f",Shipname, Station, Displacement), colors = c("blue", "red", "yellow", "grey")) %>%
      config_bubbles(popup.on.hover = TRUE,
                     highlight.on.hover = TRUE)# update
    hideTab(inputId = "MainOut", target = "Table")
  })
  observeEvent(input$debugsa, {
    output$map <- renderDatamaps({
      datamaps(responsive = TRUE) %>%
        config_geo(popup.on.hover = FALSE,
                   highlight.on.hover = FALSE,
                   border.color = "lightgreen",
                   border.opacity = 0) %>%
        add_data(newships) %>%
        add_bubbles(Long, Lat, radius = 10, ColVal, sprintf("Ship: %s<br/>Station: %s<br/>Displacement(BM): %.0f",Label, Station, Displacement), colors = c("blue", "red", "yellow", "grey"))
    })
    showTab(inputId = "MainOut", target = "Table")
    output$view <- renderTable({
      head(newships, n=20)
    })
  })
  # observeEvent(input$delete, {
  #   output$map <- renderDatamaps({
  #     data %>%
  #       datamaps(responsive = TRUE) %>%
  #       config_geo(border.opacity = 0,
  #                  border.color = "lightgreen")
  #     
  #   })
  # })
  
  output$contents <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default,
    # or all rows if selected, will be shown.
    
    req(input$file1)
    
    # when reading semicolon separated files,
    # having a comma separator causes `read.csv` to error
    tryCatch(
      {
        df <- read.csv(input$file1$datapath,
                       header = input$header,
                       sep = input$sep,
                       quote = input$quote)
      
      
      },
      error = function(e) {
        # return a safeError if a parsing error occurs
        stop(safeError(e))
      }
    )
    observeEvent(input$upload, {
      token = drop_auth()
      saveRDS(token, "droptoken.rds")
      token = readRDS("droptoken.rds")
      
      #filePath <- file.path(tempdir(), "newdata.csv")
      filename = paste("newdata",as.integer(Sys.time()),".csv", sep="")
      outfile = write.csv(df, filename, row.names = FALSE)
      file.exists(filename)
      drop_upload(filename ,path = "drop_test")
      
      #fileName <- sprintf("newdata_%s.csv", as.integer(Sys.time())),
      #                    write.csv(newships, fileName, row.names = FALSE, quote = TRUE)
      #                    token <- readRDS("droptoken.rds")
      #                    drop_acc(dtoken = token)    
      #                    drop_upload(fileName, dest = "drop_test",dtoken=token) 
    })
    
      return(df)
    
    
  })  
  

  
  
})