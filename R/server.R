# load libraries

#load helper scripts
HSLocation <- "HelperScripts/"
source(paste0(HSLocation, "ShinyServerFunctions.R"))
source(paste0(HSLocation, "AssignmentTable.R"))
source(paste0(HSLocation, "Pivot.R"))
source(paste0(HSLocation, "ProcessSid.R"))
source(paste0(HSLocation, "Grading.R"))
source(paste0(HSLocation, "Dynamic_UI_Categories.R"))
source(paste0(HSLocation, "GradesTable.R"))
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
# this allows lubridate values to be saved in the dataframe
    convert_to_min <- function(hms){
    save <- lubridate::hms(hms)
    save <- period_to_seconds(save)
    save <- save/60
    return (save)
  }
  
  output$data_manipulation <- renderDataTable({
    new_data()
  })
  
  #####------------------------DASHBOARD - DYNAMIC UI------------------------#####
  
  # Creates a reactive UI that shows the course statistics gives at least one category is added
  course_stats_html <- reactive(if(!is.null(grades$table) && ncol(grades$table) > 3)
  {
    stats <- getGradeStats(grades$table)
    category_stats <- ""
    for (i in 4:length(stats)) {
      if (!is.na(stats[i])) {
        category_stats <- paste0(category_stats, '<p class="card-text">',  names(stats)[i], stats[i], '</p>')
      }
    }
    paste0(
      '<div class="card border-light mb-3">',
      '<div class="card-header">Course Stats</div>',
      '<div class="card-body">',
      '<p class="card-text">',stats[1],'</p>',
      '<p class="card-text">',stats[2],'</p>',
      '<p class="card-text">',stats[3],'</p>',
      category_stats,
      '</div>',
      '</div>'
    )
  })
  
  student_concerns_html <- reactive(if(!is.null(grades$table) && ncol(grades$table) > 3)
  {
    student_concerns <- getStudentConcerns(grades$table, grades$bins$CutOff[4])
    paste0(
      '<div class="card border-light mb-3">',
      '<div class="card-header">Students with Low Scores:</div>',
      '<div class="card-body">',
      '<ul style="padding-left: 0;">',
      '<ul>',
      paste(sapply(student_concerns, function(concern) {
        paste("<li>", concern, "</li>", sep = "")
      }), collapse = ""),
      '</ul>',
      '</div>',
      '</div>'
    )
  })
  
  
  
  dashboard_ui <- reactive({
    if (!is.null(grades$table) && ncol(grades$table) > 3)
    {
      tagList(
        fluidRow(
          column(4,
                 h3("Course Summary Statistics"),
                 HTML(course_stats_html()),
                 HTML(student_concerns_html()),
                 br(),
          ),
          column(8,
                 mainPanel(
                   tabsetPanel(
                     tabPanel("All Grades Distributions",
                              br(),
                              br(),
                              plotOutput("grade_dist")
                     ),
                     tabPanel("Per Category", 
                              br(),
                              selectInput("which_cat", "Pick a Category", choices = categories$cat_table$Categories),
                              plotOutput("cat_dist"),
                     ),
                     tabPanel("Per Assignment",
                              br(),
                              selectInput("which_assign", "Pick an Assignment", choices = assigns$table$colnames),
                              plotOutput("assign_dist")
                     ),
                     tabPanel("Grades Table",
                              br(),
                              h6("If you would like to download your course grades, click the download button below."),
                              downloadButton("download_grades_data"),
                              br(),
                              br(),
                              h4("Overall Grades Table"),
                              dataTableOutput("grades_table")
                                
                     )
                   )
                 )
          )
        )
      )
          
      
    } else if (!is.null(input$upload)){
      tagList(
        h6(paste0("Thank you! You have uploaded a dataset with ", nrow(assigns$table), " assignments and ", nrow(grades$table), " students.")),
        h6("Go into the 'Policies' tab above and fill in the grading criteria for each category."),
        h6("Once you're done, return to this 'Dashboard' page to see your course statistics.")
      )
    } 
    else {
      h6("Welcome to GradeBook! To begin, upload your Gradescope csv by clicking the 'Browse' button above.")
    }
  })
  
  #render dashboard UI
  output$dashboard <- renderUI({ dashboard_ui()  })

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
      if (categories$cat_table$Late_Policy[num] != "None"){
        policy <- as.character(categories$cat_table$Late_Policy[num])
        prev_policy <- unlist(str_split(policy, ";"))
        updateRadioButtons(session, "change_late_boolean", selected = "Yes")
        shinyTime::updateTimeInput(session, "change_late_a", value = as.POSIXct(prev_policy[2],format="%T"))
        updateNumericInput(session, "change_late_p", value = prev_policy[2])
        if (length(prev_policy) == 4){
          updateRadioButtons(session, "change_late_boolean2", selected = "Yes")
          updateNumericInput(session, "change_late_p2", value = prev_policy[4])
        }
      }
      
      
    }
  })
  
  
  #####------------------------Modal Done button ------------------------#####
  # modal closes when Done button pressed, categories are updated
  observeEvent(input$done, {
    if (!is.null(categories$cat_table)){
      assigns$table <- changeCategory(assigns$table, categories$cat_table, input$nRow)
      clobber <- getClobber(input$change_clobber_boolean, input$change_clobber)
      late <- getLatePolicy(input$change_late_boolean, input$change_late_boolean2, input$change_late_a, input$change_late_a2, input$change_late_p, input$change_late_p2)
      categories$cat_table <- updateRow(categories$cat_table, input$nRow, input$change_name, input$change_weight, input$change_assign, input$change_drops, input$change_policy, clobber, late)
      grades$table <- updateCatGrade(grades$table, pivotdf(), categories$cat_table, input$nRow)
      grades$table <- getOverallGrade(grades$table, categories$cat_table, grades$bins)
      assigns$table <- updateCategory(assigns$table, input$change_assign, input$change_name)
    }
    removeModal()
  })
  
  
  
  #####------------------------ create a new assignment category ------------------------#####
  
    # input$create event is activated on "save" button when creating a new assignemnt category
  observeEvent(input$create, {
    
    # updates category table with new row with new name, weights, assignments
  clobber <- getClobber(input$clobber_boolean, input$clobber_with)
  late <- getLatePolicy(input$late_boolean, input$late_boolean2, input$late_allowed, input$late_allowed2, input$late_penalty, input$late_penalty2)
  categories$cat_table <- updateCategoryTable(input$assign, categories$cat_table, input$cat_name, input$weight, 
                                             input$num_drops, input$grading_policy, clobber, late)
  
  if (!is.null(input$assign)){
    assigns$table <- updateCategory(assigns$table, input$assign, input$cat_name)
  }
  cat_num <- nrow(categories$cat_table)
  grades$table <- updateCatGrade(grades$table, pivotdf(), categories$cat_table, cat_num)
  grades$table <- getOverallGrade(grades$table, categories$cat_table, grades$bins)
  removeModal()
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

  
  grades <- reactiveValues(table = NULL,
                           bins = data.frame(Grades = c("A", "B", "C", "D", "F"),
                                             CutOff = c(90, 80, 70, 60, 0))
                           )
  observe({
    if (!is.null(data())){
      grades$table <- createGradesTable(processed_sids()$unique_sids$names)
    }
  })
  
  output$grades <- renderDataTable(
    grades$table
  )

  
  #####------------------------ GRADE TABLE ON DASHBOARD TAB ------------------------#####
  grades_table <- reactive({
    sid_df <- processed_sids()$unique_sids %>% select(names, sid, email, sections)
    grades <- grades$table #%>% select(Overall_Grade, Letter_Grade)
    result = cbind(sid_df, grades)
    
    return(result)
  })
  output$grades_table <- renderDataTable(
    as.data.frame(grades_table())
  )
  
  #####---------------------------GRADE BINS-----------------------------#####

  #reactively updates grade bins
  observe({
    grades$bins <- updateBins(grades$bins, input$A, input$B, input$C, input$D, input$F)
    if (!is.null(grades$table)){
      if (grades$table[1,2] != "TBD"){
        grades$table <- getOverallGrade(grades$table, categories$cat_table, grades$bins) 
      }
    }
  })
  
  #renders grade bin UI
  output$grade_bin_percent <- renderUI({ grade_bin_pct()})
  
  #reactive grade bin text for percentages per letter grade
  grade_bin_pct <- reactive({
    if (!is.null(grades$table) && ncol(grades$table) > 3){
      tagList(
        fluidRow(
          column(2,
                 h6(paste0(round(mean(grades$table$Letter_Grade == "F")*100,2), " %"))
                 ),
          column(2,
                 h6(paste0(round(mean(grades$table$Letter_Grade == "D")*100,2), " %"))
          ),
          column(2,
                 h6(paste0(round(mean(grades$table$Letter_Grade == "C")*100,2), " %"))
          ),
          column(2,
                 h6(paste0(round(mean(grades$table$Letter_Grade == "B")*100,2), " %"))
          ),
          column(2,
                 h6(paste0(round(mean(grades$table$Letter_Grade == "A")*100,2), " %"))
          ),
        )
      )
    }
  })
  
  ### GGPLOT in Coursewide - a plot about the GRADE BINS - A,B,C,D,F
  output$letter_dist <- renderPlot({
    plot <-grades$table %>% ggplot(aes(x = as.integer(Overall_Grade))) +geom_histogram() +
      geom_rug(alpha = .35) + labs(x = "Grade (out of 100)") + xlim(0, 110) +
      geom_vline(xintercept = grades$bins$CutOff, color = "goldenrod", lwd = 1.5) +
      theme_minimal()
    return (plot)
  })
  
  output$bins <- renderDataTable({(grades$bins)})
  
  #####---------------------------DASHBOARD-----------------------------#####
  
  ### GGPLOT on a overall grades 
  output$grade_dist <- renderPlot({
    plot <- grades$table %>% 
      mutate(Overall_Grade = as.integer(Overall_Grade)) %>%
      ggplot(aes(x = Overall_Grade)) + geom_histogram( color = "grey", fill = "lightgrey") +
      ggtitle("Distribution of Overall Grades") + xlab("Individual Grades") +
      theme_bw()
    plot
  })
  
  ### GGPLOT on a distribution of a category of choice
  output$cat_dist <- renderPlot({
    if (ncol(grades$table) > 4){
      plot <-grades$table %>% ggplot(aes_string(x = input$which_cat)) +
        geom_histogram() + theme_bw() +
        ggtitle(paste0("Distribution of ", input$which_cat))
      return (plot)
    }
  })
  
  ### GGPLOT on a distribution of an Assignment of choice

  output$assign_dist <- renderPlot({
    pivot <- pivotdf()
    plot <-pivot %>% 
      filter(colnames == input$which_assign)%>%
      mutate(score = raw_points/max_points) %>%
      ggplot(aes(x = score)) + geom_histogram() + theme_bw() +
      ggtitle(paste0("Distribution of ", input$which_assign))
    plot
  })
  

  
 


  #####------------------------ ALL-GRADES TABLE------------------------#####
  
  ### Step1: AllGradesTable calculations. 
  allgradestable <- reactive({
    pivotdf <- pivotdf()
    if (!is.null(categories$cat_table) && length(categories$cat_table) > 0) {
      AllGradesTable(pivotdf, categories$cat_table)
    } 
  })
  output$all_grades_table <- renderDataTable({
    allgradestable()
  })
  
  ### Step2: GradesPerCategory calculations. 
  gradespercategory <- reactive({
    pivotdf <- pivotdf()
    if (!is.null(categories$cat_table) && length(categories$cat_table) > 0) {
      AllGradesTable(pivotdf, categories$cat_table) %>%
        GradesPerCategory()
    } else {
      NULL
    }
  })
  
  output$grades_per_category <- renderDataTable({
    gradespercategory()
  })
  
  
  #####------------------------Download Grades File------------------------#####
  
  output$download_grades_data <- downloadHandler(
    
    filename = function() {
      paste("course_grades_", Sys.Date(), ".csv", sep = "")
    },
    content = function(filename) {
      write.csv(grades_table, filename, row.names = FALSE)
    })
  
  
  
  #####---------------------------JSON CONFIG FILES---------------------------#####
  
  #####------------------------CAT_TABLE TO JSON FILES------------------------#####
  
  #create a path to make a folder
  path <- "../../gradebook-data"
  dir.create(path, showWarnings = FALSE)

  #save config
  observeEvent(input$save_config, {
    req(!is.null(categories$cat_table))
    cat_table <- categories$cat_table
    config_list <- list(categories$cat_table, grades$bins)
    jsonlite::write_json(config_list, paste(path, "cat_table.json", sep = "/"))
  })
  
  
  #####-------------------------JSON TO CAT_TABLE --------------------------#####
  
  #load config
  observeEvent(input$load_config, {
    if (file.exists(paste(path, "cat_table.json", sep = "/"))) {
      df <- jsonlite::fromJSON(paste(path, "cat_table.json", sep = "/"))
      categories$cat_table <- df[[1]]

      grades$bins <- df[[2]]
      updateNumericInput(session, "A", value = grades$bins$CutOff[1])
      updateNumericInput(session, "B", value = grades$bins$CutOff[2])
      updateNumericInput(session, "C", value = grades$bins$CutOff[3])
      updateNumericInput(session, "D", value = grades$bins$CutOff[4])
      updateNumericInput(session, "F", value = grades$bins$CutOff[5])
      
      for (x in 1:nrow(categories$cat_table)){
        name <- categories$cat_table$Categories[x]
        assign <- categories$cat_table$Assignments_Included[x]
        assign <- unlist(str_split(assign, ", "))
        assigns$table <- updateCategory(assigns$table, assign, name) 
        grades$table <- updateCatGrade(grades$table, pivotdf(), categories$cat_table, x)
      }
      grades$table <- getOverallGrade(grades$table, categories$cat_table, grades$bins)
      
    } else {
      print("File not found")
    }
  })
  
  
  ####------------------------ Disclaimer - FOOTER ------------------------#####
  output$disclaimer <- renderText({
    "Gradebook, 2023"
  })
})
