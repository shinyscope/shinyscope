# load libraries

#load helper scripts
HSLocation <- "helperScripts/"
source(paste0(HSLocation, "ShinyServerFunctions.R"))
source(paste0(HSLocation, "AssignmentTable.R"))
source(paste0(HSLocation, "Pivot.R"))

shinyServer(function(input, output, session) {
  
  #####------------------------uploading a file------------------------#####
  data <- reactive({
    req(input$upload)
    
    ext <- tools::file_ext(input$upload$name)
    switch(ext,
           csv = vroom::vroom(input$upload$datapath, delim = ",", na = c("", "NA")),
           validate("Invalid file; Please upload a .csv or .tsv file")
    )
  })
  
  #####------------------------ the original uploaded data------------------------#####
  output$data <- renderDataTable({
    data <- data()
    if(is.null(input$upload)){
      return("Upload some data first")
    }
    else{
    read.table(input$upload$datapath, sep = ",", header = TRUE)
    }
      })
  
  #####------------------------takes reactive data output ------------------------#####
  #####------------------------and creates a reactive assignment table------------#####
  assignments <- reactive({
    data <- data()
    createAssignTable(data)
  })
  #####------------------------creates a table of the assignments------------------------#####
  output$assign <- renderDataTable({
    assignments()
})
  
  #####------------------------takes the new colnames and replaces original colnames--#####
  #####------------------------makes a new data frame new_data------------------------#####
  new_data <- reactive({
    # Get the new column names from the form data frame
    new_colnames <- assignments()$new_colnames
    # Rename the columns of the data frame using the new column names
    data_new_colnames <- data() %>%
      rename(!!!setNames(names(.), new_colnames))
    #fix dates
    new_time <- data_new_colnames%>%
        mutate(across(contains("submission_time"), lubridate::ymd_hms), # convert to datetimes
              across(contains("lateness"), lubridate::hms))
    return(new_time)
  })
  
  output$table <- renderDataTable({
    new_data()
  })
  
  
  
  #####------------------------pivot_longer function------------------------#####
  pivotdf <- reactive({
    new_data <- new_data()
    pivot(new_data)
  })
  
   output$pivotlonger <- renderDataTable({
    pivotdf()
  })



  #####------------------------Manipulate dataframe------------------------#####
  modified_data <- reactiveVal(NULL)
  
  #####------------------------select columns & calculate the mean------------------------##### 
  observe({
    numeric_cols <- colnames(data())[sapply(data(), is.numeric)] #this only selects numeric columns
    updateSelectizeInput(session, "cols", choices =  numeric_cols) # all columns: updateSelectizeInput(session, "cols", choices = colnames(data()))
  })
  #####------------------------select columns & calculate the mean------------------------##### 
 

   ## create dropdown for all assignments only in NIKITA
   observe({
     assignments <- assignments()
     assignments <- assignments %>%
       filter(!str_detect(colnames, "Name|Sections|Max|Time|Late"))
     updateSelectizeInput(session, "assign_niki", choices = assignments$colnames) #make dropdown of assignments
   })
   
   ## update categories
   observe({
     categories <- categories()
     updateSelectizeInput(session, "cat_niki", choices = categories$Categories) #make dropdown of assignments
     
   })
   
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

  # output$table <- renderDataTable({
  #   if(is.null(result())){return()}
  #   datatable(result())
  # })
  
  #####------------------------Download File------------------------#####
  observeEvent(input$upload, {
    output$downloadBtn <- renderUI({
      downloadButton("downloadData", "Download Data")
    })
  })
  
  #####------------------------CSV file is named modified_data_YYYY-MM-DD.csv------------------------#####
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("modified_data", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(result(), file, row.names = FALSE)
    })
  
  categories <- reactive({
    num <- input$num_cat
    Categories <- sprintf("Category %d",1:num)
    cat_table <- data.frame(Categories) %>%
      mutate(Weights = 1/num) %>%
      mutate(Assignments_Included = "")
  })
  
  output$cat_table <- renderDataTable({
    categories <- categories()
    updateCategories(categories, input$cat_niki, input$assign_niki)
  })
  
  
})