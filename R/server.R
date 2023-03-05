# load libraries


#load helper scripts
HSLocation <- "helperScripts/"
source(paste0(HSLocation, "ShinyServerFunctions.R"))


shinyServer(function(input, output, session) {
 
  #uploading a file
  data <- reactive({
    req(input$upload)
    
    ext <- tools::file_ext(input$upload$name)
    switch(ext,
           csv = vroom::vroom(input$upload$datapath, delim = ",", na = c("", "NA")),
           validate("Invalid file; Please upload a .csv or .tsv file")
    )
  })
  
  # tab you can see the original uploaded data
  output$data <- renderDataTable({
    if(is.null(input$upload)){
      return("Upload some data first")
    }
    read.table(input$upload$datapath, sep = ",", header = TRUE)
    
  })
  # -----------------Manipulate dataframe---------------------
  modified_data <- reactiveVal(NULL)
  
  #---------- select columns & calculate the mean 
  observe({
    numeric_cols <- colnames(data())[sapply(data(), is.numeric)] #this only selects numeric columns
    updateSelectizeInput(session, "cols", choices =  numeric_cols) # all columns: updateSelectizeInput(session, "cols", choices = colnames(data()))
  })
  #---------- select columns & calculate the mean 

  #it seems to calculate the mean correctly
  
  result <- eventReactive(input$calculate, {
    dataframe <- data()
    columns <- dataframe[,input$cols]
    dataframe$mean <- rowMeans(columns)
    #
    return(dataframe)
  })
  
  #in DATA MANIPULATION tab
  #output function look for action in the above function
  #for calculating the mean and return the result
  # RETURNS THE MEAN by adding a column at the end

  output$table <- renderDataTable({
    if(is.null(result())){return()}
    datatable(result())
  })
  
  #-----------------Download File-----------------
  observeEvent(input$upload, {
    output$downloadBtn <- renderUI({
      downloadButton("downloadData", "Download Data")
    })
  })
  
  # CSV file is named modified_data_YYYY-MM-DD.csv
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("modified_data", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(result(), file, row.names = FALSE)
    })
})