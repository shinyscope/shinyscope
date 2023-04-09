# load libraries


#load helper scripts
HSLocation <- "helperScripts/"
source(paste0(HSLocation, "ShinyServerFunctions.R"))
source(paste0(HSLocation, "AssignmentTable.R"))
source(paste0(HSLocation, "Pivot.R"))
source(paste0(HSLocation, "ProcessSid.R"))
source(paste0(HSLocation, "Grading.R"))
source(paste0(HSLocation, "Dynamic_UI_Categories.R"))

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
    read.table(input$upload$datapath, sep = ",", header = TRUE, fill=TRUE)
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
   # assignments()
    assigns$table #reactiveValue table from Assignment View tab
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
  
  
  
  #####------------------------StudentView functions------------------------#####
  processed_sids <- reactive({
    new_data <- new_data()
    process_sids(new_data)
   })
   
  output$students <- renderDataTable({
    sid_df <- processed_sids()$unique_sids
    sid_df %>% select(names, sid, email, sections)
   })
   
  output$duplicate_sids <- renderDataTable({
    dup_df <- processed_sids()$duplicates
    dup_df %>% select(names, sid, email, sections)
   })
  
  
  #####------------------------Student View - Summaries------------------------#####
  output$num_students_msg <- renderText({
    sids <- processed_sids()$unique_sids
    num_rows <- nrow(sids)
    paste0('<div class="alert alert-success" role="alert"><i class="fas fa-check-circle"></i> ', num_rows, ' students were imported.</div>')
  })
  
  output$num_assign_msg <- renderText({
    #assignments <- assignments()
    num_rows <- (nrow(assigns$table))
    paste0('<div class="alert alert-success" role="alert"><i class="fas fa-check-circle"></i> ', num_rows, ' assignments were imported.</div>')
  })
  
  output$duplicates_msg <- renderText({
    dup_df <- processed_sids()$duplicates
    num_duplicate <- dup_df %>% drop_na(sid)%>% distinct(sid) %>% nrow()
    sid_nas <- sum(is.na(dup_df$sid))
    paste0('<div class="alert alert-warning" role="alert"><i class="fas fa-exclamation-triangle"></i> ', num_duplicate, ' duplicates of SIDs were merged. <br>',
           '<i class="fas fa-exclamation-triangle"></i> ', sid_nas, ' SID numbers are missing.</div>')
  })
  

  #####------------------------Assignment View------------------------#####
  
  categories <- reactiveValues(cat_table = NULL)
  
  observeEvent(input$create, {
    updateTextInput(session, "assign", value = "")
    updateTextInput(session, "cat_name", value = "")
    
    # updates category table with new row with new name, weights, assignments
    categories$cat_table <- updateCategoryTable(input$assign, categories$cat_table, input$cat_name, input$weight, input$num_drops, input$grading_policy)
    if (!is.null(input$assign)){
      assigns$table <- updateCategory(assigns$table, input$assign, input$cat_name)
      }
  })
  
  # renders table of categories with respective assignments and weights
  output$cat_table <- renderDataTable({ datatable(categories$cat_table)})
  
  #reactive unassigned assignments table
  assigns <- reactiveValues(table = NULL)
  
  # creates unassigned assignments table
  observe({
    assigns$table <- data.frame(assignments()) %>%
      filter(!str_detect(colnames, "Name|Sections|Max|Time|Late|Email|SID"))
  })

  
  observeEvent(input$delete, {
    if (!is.null(categories$cat_table)){
      assigns$table <- changeCategory(assigns$table, categories$cat_table, input$nRow)
      categories$cat_table <- deleteRow(categories$cat_table, input$nRow) 
    }
    removeModal()
  })
  
  # modal opens when Edit button pressed and updates default settings of input widgets
  observeEvent(input$edit, {
    showModal(modal_confirm)
    num <- input$nRow
    if (!is.null(categories$cat_table)){
      updateNumericInput(session, "nRow", max = nrow(categories$cat_table)) 
    }
    updateSelectizeInput(session, "change_assign", choices = assigns$table$colnames) #make dropdown of assignments
  })
  
  observeEvent(input$nRow, {
    #updates default inputs when picking different rows
    num <- input$nRow
    updateTextInput(session, "change_name", value = categories$cat_table$Categories[num])
    updateSliderInput(session, "change_weight", value = categories$cat_table$Weights[num])
  })
  
  observeEvent(input$cancel, {
    removeModal() #cancel button closes modal without changing anything
  })
  
  # modal closes when Done button pressed, categories are updated
  observeEvent(input$done, {
    if (!is.null(categories$cat_table)){
      assigns$table <- changeCategory(assigns$table, categories$cat_table, input$nRow)
      categories$cat_table <- updateRow(categories$cat_table, input$nRow, input$change_name, input$change_weight, input$change_assign, input$change_drops, input$change_policy)
      if (!is.null(input$assign)){
        assigns$table <- updateCategory(assigns$table, input$change_assign, input$change_name)
      }
    }
    removeModal()
  })
  
  #####------------------------ Grading ------------------------#####
  
  output$grades <- renderDataTable({
    students <- processed_sids()$unique_sids %>% select(names)
    pivot <- pivotdf()
    calculateGrades(students, pivot, categories$cat_table)
  })
  
  output$myList <- renderUI(
    HTML(markdown::renderMarkdown(text = paste(paste0("- ", getUnassigned(assigns$table), "\n"), collapse = "")
  )))
  

  
  
  #####------------------------ DYNAMIC UI FOR DISPLAYING CATEGORIES ------------------------#####
 
  #display modal for editing existing assignemnt category
  observeEvent(input$create_category, {
    showModal(add_new_category_modal)
    choices <- assigns$table$colnames
    if (!is.null(assigns$table))
    {choices <- assigns$table %>% filter (category == "Unassigned") %>% select(colnames)} 
    updateSelectizeInput(session, "assign", choices = choices) 
  })
  observeEvent(input$create, {
    removeModal()
  })
    
  #display dynamic UI
  output$dynamic_ui <- renderUI({
    if(!is.null(categories$cat_table)){
    categories_table <- categories$cat_table
    dynamic_ui_categories(categories_table)
    }
  })

  
  
  
  
  
  #####------------------------ Disclaimer - FOOTER ------------------------#####
  output$disclaimer <- renderText({
    "Shinyscope, 2023"
  })
})