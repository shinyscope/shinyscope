# load libraries


#load helper scripts
HSLocation <- "HelperScripts/"
source(paste0(HSLocation, "ShinyServerFunctions.R"))
source(paste0(HSLocation, "AssignmentTable.R"))
source(paste0(HSLocation, "Pivot.R"))
source(paste0(HSLocation, "ProcessSid.R"))
source(paste0(HSLocation, "Grading.R"))
source(paste0(HSLocation, "Dynamic_UI_Categories.R"))
source(paste0(HSLocation, "AllGradesTable.R"))
source(paste0(HSLocation, "Distributions.R"))

shinyServer(function(input, output, session) {
  
  
  #####----------------------------------------------------------------#####
  #####------------------------uploading a file------------------------#####
  #####----------------------------------------------------------------#####
  data <- reactive({
    req(input$upload)
    
    ext <- tools::file_ext(input$upload$name)
    switch(ext,
           csv = vroom::vroom(input$upload$datapath, delim = ",", na = c("", "NA")),
           validate("Invalid file; Please upload a .csv or .tsv file")
    )
  })
  
  # alternative approach?
  #shinyFileChoose(input, 'files', root=c(root='.'), filetypes=c('', 'txt'))
  
  #####----------------------------------------------------------------#####
  #####---------------------------ANALYSIS TAB-------------------------#####
  #####----------------------------------------------------------------#####
  
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
        mutate(across(contains("submission_time"), lubridate::mdy_hm), #convert to datetimes , previous format: lubridate::ymd_hms
              across(contains("lateness"), convert_to_min),
              across(contains("lateness"), as.character))
    return(new_time)
  })
  
  convert_to_min <- function(hms){
    save <- lubridate::hms(hms)
    save <- period_to_seconds(save)
    save <- save/60
    return (save)
  }
  
  output$data_manipulation <- renderDataTable({
    new_data()
  })
  
  
  #####------------------------pivot_longer function------------------------#####
  #### USING processed_sids()$unique_sids DATAFRAME TO PROCESS PIVOT LONGER TABLE!!!
  #### Remember, the processed_sids() returns a list of  2 dataframes, we only need the first one
  
  pivotdf <- reactive({
    processed_sids <- processed_sids()$unique_sids

    pivot(processed_sids, assigns$table, categories$cat_table)
  })
  
   output$pivotlonger <- renderDataTable({
    pivotdf()
  })

   #####--------------------------------------------------------------------#####
   #####---------------------------STUDENT VIEW TAB-------------------------#####
   #####--------------------------------------------------------------------#####
   
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
    num_assignments <- (nrow(assigns$table))
    paste0('<div class="alert alert-success" role="alert"><i class="fas fa-check-circle"></i> ', num_rows, ' students were imported. <br>',
           '<i class="fas fa-check-circle"></i> ', num_assignments, ' assignments were imported.</div>')
  })
  
  
  output$duplicates_msg <- renderText({
    dup_df <- processed_sids()$duplicates
    num_duplicate <- dup_df %>% drop_na(sid)%>% distinct(sid) %>% nrow()
    sid_nas <- sum(is.na(dup_df$sid))
    paste0('<div class="alert alert-warning" role="alert"><i class="fas fa-exclamation-triangle"></i> ', num_duplicate, ' duplicates of SIDs were merged. <br>',
           '<i class="fas fa-exclamation-triangle"></i> ', sid_nas, ' SID numbers are missing.</div>')
  })
  
  
  #####--------------------------------------------------------------------#####
  #####------------------------ CONFIGURATIONS TAB-------------------------#####
  #####--------------------------------------------------------------------#####
  
  #####---------------------------Assignment View--------------------------#####
  
  categories <- reactiveValues(cat_table = NULL)
  
  #####--------------------------- EDIT MODAL  ----------------------------#####
  
  #renders table of categories with respective assignments and weights
  output$cat_table <- renderDataTable({ datatable(categories$cat_table)})
  
  #reactive unassigned assignments table
  assigns <- reactiveValues(table = NULL)
  
  #creates unassigned assignments table
  observe({
    assigns$table <- data.frame(assignments()) %>%
      filter(!str_detect(colnames, "Name|Sections|Max|Time|Late|Email|SID"))
  })
  
  output$text <- renderText({"Let's upload some data first..."})
  
  #prints the "New Assignmetns" 
  output$myList <- renderUI(
    if (!is.null(assigns$table)){
      HTML(markdown::renderMarkdown(text = paste(paste0("- ", getUnassigned(assigns$table), "\n"), collapse = "")))
    } else {
      textOutput("text")
    }
  )

  #####--------------------------- EDIT MODAL  ----------------------------#####
  
  # modal opens when Edit button pressed and updates default settings of input widgets
  observeEvent(input$edit, {
    showModal(modal_confirm)
    updateNumericInput(session, "nRow", value = 1, min = 1, max = nrow(categories$cat_table))
  })
  
  observeEvent(input$nRow, {
    #updates default inputs when picking different rows
    num <- input$nRow
    
    if (!is.null(categories$cat_table) && num <= nrow(categories$cat_table)){
      updateTextInput(session, "change_name", value = categories$cat_table$Categories[num])
      updateNumericInput(session, "change_weight", value = categories$cat_table$Weights[num])
      
      # Preload selected values
      preloaded_values <- categories$cat_table$Assignments_Included[num]
      preloaded_values <- unlist(strsplit(preloaded_values, ", ")) # Split the string and unlist the result
      
      # Update the SelectizeInput with the preloaded values
      updateRadioButtons(session, "change_clobber_boolean", selected = "No")
      
      choices <- assigns$table %>% filter (category == "Unassigned") %>% select(colnames)
      prev_selected <- ""
      if (categories$cat_table$Clobber_Policy[num] != "None"){
        prev_selected <- unlist(strsplit(categories$cat_table$Clobber_Policy[num], "Clobbered with "))
        updateRadioButtons(session, "change_clobber_boolean", selected = "Yes")
      }
      choices = c(choices, preloaded_values)
      updateSelectInput(session, "change_clobber", choices = categories$cat_table$Categories, selected = prev_selected)
      updateSelectizeInput(session, "change_assign", choices = choices, selected = preloaded_values) #make dropdown of assignments
      
      if (input$change_late_policy1 == "Yes") {
        categories$cat_table <- updateCategoryTable(categories$cat_table, num, 
                                                    lp1_time = input$change_lp1_time, lp1_unit = input$change_lp1_unit, lp1_deduction = input$change_lp1_deduction)
      }

      if (input$change_late_policy2 == "Yes") {
        categories$cat_table <- updateCategoryTable(categories$cat_table, num,
                                                    lp2_time = input$change_lp2_time, lp2_unit = input$change_lp2_unit, lp2_deduction = input$change_lp2_deduction)
      }
    }
  })
  
  
  #####------------------------Modal Done button ------------------------#####
  # modal closes when Done button pressed, categories are updated
  observeEvent(input$done, {
    if (!is.null(categories$cat_table)){
      assigns$table <- changeCategory(assigns$table, categories$cat_table, input$nRow)
      clobber <- getClobber(input$change_clobber_boolean, input$change_clobber)
      categories$cat_table <- updateRow(categories$cat_table, input$nRow, input$change_name, input$change_weight, input$change_assign, input$change_drops, input$change_policy, clobber, input$change_lp1_time, input$change_lp1_unit, input$change_lp1_deduction, input$change_lp2_time, input$change_lp2_unit, input$change_lp2_deduction)
      
      grades$table <- updateCatGrade(grades$table, pivotdf(), categories$cat_table, input$nRow)
      assigns$table <- updateCategory(assigns$table, input$change_assign, input$change_name)
    }
    removeModal()
  })
  
  
  
  #####------------------------ create a new assignment category ------------------------#####
  
    # input$create event is activated on "save" button when creating a new assignemnt category
  observeEvent(input$create, {
    
    # updates category table with new row with new name, weights, assignments
  clobber <- getClobber(input$clobber_boolean, input$clobber_with)
  print(paste0("1categories:cat_table is: ", categories$cat_table))
  categories$cat_table <- updateCategoryTable(input$assign, categories$cat_table, input$cat_name, input$weight, 
                                             input$num_drops, input$grading_policy, clobber,
                                             lp1_time = input$lp1_time,
                                             lp1_unit = input$lp1_unit, lp1_deduction = input$lp1_deduction,
                                             lp2_time = input$lp2_time,
                                             lp2_unit = input$lp2_unit, lp2_deduction = input$lp2_deduction)
  
  print(paste0("2categories:cat_table is: ", categories$cat_table))
  if (!is.null(input$assign)){
    assigns$table <- updateCategory(assigns$table, input$assign, input$cat_name)
  }
  
  # if (input$late_policy1 == "Yes") {
  #   categories$cat_table <- updateCategoryTable(cat_table = categories$cat_table,lp1_time = input$lp1_time,
  #                                               lp1_unit = input$lp1_unit, lp1_deduction = input$lp1_deduction)
  # }
  # 
  # if (input$late_policy2 == "Yes") {
  #   categories$cat_table <- updateCategoryTable(cat_table = categories$cat_table,lp2_time = input$lp2_time,
  #                                               lp2_unit = input$lp2_unit, lp2_deduction = input$lp2_deduction)
  # }
   })
  
  
    #display modal for a new assignment category
  observeEvent(input$create_category, {
      
    showModal(add_new_category_modal)
    choices <- assigns$table$colnames
    if (!is.null(assigns$table))
      {choices <- assigns$table %>% filter (category == "Unassigned") %>% select(colnames)} 
      updateSelectizeInput(session, "assign", choices = choices)
      updateSelectInput(session, "clobber_with", choices = categories$cat_table$Categories)
  })
  
  observeEvent(input$create, {
    removeModal()
  })
  
  
  #####------------------------ delete button on modal ------------------------#####
  
  observeEvent(input$delete, {
    if (!is.null(categories$cat_table)){
      assigns$table <- changeCategory(assigns$table, categories$cat_table, input$nRow)
      category <- categories$cat_table$Categories[input$nRow]
      categories$cat_table <- deleteRow(categories$cat_table, input$nRow)
      grades$table <- deleteCategory(grades$table, category)
    }
    removeModal()
  })
  #####------------------------ cancel button on modal ------------------------#####
  
  #cancel button closes modal without changing anything
  observeEvent(input$cancel, {
    removeModal() 
  })
  
  
  #####------------------------ DYNAMIC UI FOR DISPLAYING CATEGORIES ------------------------#####
  #display dynamic UI
  output$dynamic_ui <- renderUI({
    if(!is.null(categories$cat_table)){
    categories_table <- categories$cat_table
    dynamic_ui_categories(categories_table)
    }
  })
  
  
  #####--------------------------------------------------------------------#####
  #####------------------------ Grading ------------------------#####
  observe({
    updateSelectInput(session, "pick_student", choices = processed_sids()$unique_sids$names)
    updateSelectInput(session, "pick_cat", choices = categories$cat_table$Categories)
  })
  
  
  output$individ_grades <- renderDataTable({
    if (!is.null(categories$cat_table)){
      cat_num <- which(categories$cat_table$Categories == input$pick_cat)
      return (getValidAssigns(pivotdf(),input$pick_student, categories$cat_table, cat_num))
    }
  })
  
  grades <- reactiveValues(table = NULL,
                           bins = data.frame(Grades = c("A", "B", "C", "D", "F"),
                                             CutOff = c(90, 80, 70, 60, 0))
                           )
  observe({
    if (!is.null(data())){
      grades$table <- createGradesTable(processed_sids()$unique_sids$names)
    }
  })
  
  
  observeEvent(input$create, {
    cat_num <- nrow(categories$cat_table)
    grades$table <- updateCatGrade(grades$table, pivotdf(), categories$cat_table, cat_num)
  })
  
  output$grades <- renderDataTable(
    grades$table
  )
  
  observeEvent(input$grade_all, {
    if (!is.null(categories$cat_table)){
      grades$table <- getOverallGrade(grades$table, categories$cat_table, grades$bins) 
    }
  })

  
  #####---------------------------GRADE BINS-----------------------------#####

  
  observe({
    grades$bins <- updateBins(grades$bins, input$A, input$B, input$C, input$D, input$F)
    if (!is.null(grades$table)){
      if (grades$table[1,2] != "TBD"){
        grades$table <- getOverallGrade(grades$table, categories$cat_table, grades$bins) 
      }
    }
  })
  
  output$grade_dist <- renderPlot({
      plot <- grades$table %>% 
        ggplot(aes(x = Overall_Grade)) + geom_histogram()
      plot
  })
  
  output$letter_dist <- renderPlot({
    plot <-grades$table %>% ggplot(aes(x = Letter_Grade)) +geom_bar()
    return (plot)
  })
  

  output$cat_dist <- renderPlot({
    if (ncol(grades$table) > 3){
      plot <-grades$table %>% ggplot(aes_string(x = input$which_cat)) +
        geom_histogram()
      return (plot)
    }
  })
  
  output$assign_dist <- renderPlot({
    pivot <- pivotdf()
    plot <-pivot %>% 
      filter(colnames == input$which_assign)%>%
      mutate(score = raw_points/max_points) %>%
      ggplot(aes(x = score)) + geom_histogram()
    plot
  })

  observe({
    updateSelectInput(session, "which_assign", choices = assigns$table$colnames)
    updateSelectInput(session, "which_cat", choices = categories$cat_table$Categories)
  })
  
  
  #####------------------------ ALL-GRADES TABLE------------------------#####
    
  output$all_grades_table <- renderDataTable({
    pivotdf <- pivotdf()
    AllGradesTable(pivotdf,categories$cat_table)
  })
  
  
  #####--------------------------------------------------------------------#####
  

  
  #####------------------------Manipulate dataframe------------------------#####
  modified_data <- reactiveVal(NULL)
  
  
  #####------------------------select columns & calculate the mean------------------------##### 
  
  
  #it seems to calculate the mean correctly
  
  result <- eventReactive(input$calculate, {
    dataframe <- data()
    columns <- dataframe[,input$cols]
    dataframe$mean <- rowMeans(columns)
    #
    return(dataframe)
  })
  
  
  #####------------------------select columns & calculate the mean------------------------##### 
  observe({
    numeric_cols <- colnames(data())[sapply(data(), is.numeric)] #this only selects numeric columns
    updateSelectizeInput(session, "cols", choices =  numeric_cols) # all columns: updateSelectizeInput(session, "cols", choices = colnames(data()))
  })
  
  
  #####------------------------Download File------------------------#####
  observeEvent(input$upload, {
    output$downloadBtn <- renderUI({
      downloadButton("downloadData", "Download Data")
    })
  })
  
  #####------------------------CSV file is named modified_data_YYYY-MM-DD.csv------------------------#####
  
  
  
  output$download_grades_data <- downloadHandler(
    
    filename = function() {
      paste("course_grades_", Sys.Date(), ".csv", sep = "")
    },
    content = function(filename) {
      sid_df <- processed_sids()$unique_sids %>% select(names, sid, email, sections)
      grades <- grades$table %>% select(Overall_Grade, Letter_Grade)
      result = cbind(sid_df, grades)
      write.csv(result, filename, row.names = FALSE)
    })
  
  

  
  ####------------------------ Disclaimer - FOOTER ------------------------#####
  output$disclaimer <- renderText({
    "Shinyscope, 2023"
  })
})
