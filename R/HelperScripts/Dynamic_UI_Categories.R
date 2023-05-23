dynamic_ui_categories <- function(categories_table) {
  button_ids <- reactive({
    paste0("edit_button_", 1:nrow(categories_table))
  })
  
  print(button_ids())
  button_states <- reactiveValues()
  
  # Create UI elements for each row in the datatable
  lapply(1:nrow(categories_table), function(i) {
    category <- categories_table[i, 1]
    weight <- categories_table[i, 2]
    assignments <- categories_table[i, 3]
    drops <- categories_table[i, 4]
    grading_policy <- categories_table[i, 5]
    clobber <- categories_table[i, 6]
    late_policy <- categories_table[i, 7]
    late <- unlist(str_split(late_policy, ";"))
    if (length(late) >= 2) {
      late_policy <- paste0("Lateness of ", late[1], " allowed with a deduction of ", late[2])
      if (length(late) == 4) {
        late_policy <- paste0(late_policy, "; Lateness of ", late[1], " allowed with a deduction of ", late[2])
      }
    }
    
    category_html <- paste0(
      '<div class="navbar navbar-expand-lg navbar-light bg-light" style="padding: 10px;">',
      '<span style="font-size: 21px;">', tools::toTitleCase(category),
      '</span>',
      '</div>'
    )
    
    # unique id for each edit_button
    edit_button_id <- button_ids()[i]
    
    # create an actionButton for each Edit button
    edit_button <- actionButton(edit_button_id, "Edit", icon = icon("edit"))
    
    observeEvent(input[[edit_button_id]], {
      button_states[[edit_button_id]] <- isolate({
        if (is.null(button_states[[edit_button_id]])) {
          0
        } else {
          button_states[[edit_button_id]]
        }
      }) + 1
      
      if (button_states[[edit_button_id]] %% 2 == 1) {
        
        button_index <- as.numeric(strsplit(edit_button_id, "_")[[1]][3])
        
        
        
        showModal(modal_confirm)
        
        
        num <- as.numeric(strsplit(button_id, "_")[[1]][3]) #regex - it takes the number value from the ID at the end
        
        if (num <= nrow(categories$cat_table)){
          
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
        
      }
    })
  
    
    
    
    tagList(
      HTML(category_html),
      
      # edit_button in the UI
      div(edit_button, style = "position: relative; top: 10px; right: 10px;"),
      
      div(
        style = "border-left: 1px solid #ddd; padding-left: 10px; display: flex;",
        div(
          style = "flex: 1; display: flex; flex-direction: column; margin-right: 10px;",
          p(strong("Weight:"), style = "margin-bottom: 5px;"),
          p(strong("Drops:"), style = "margin-bottom: 5px;"),
          p(strong("Grading Policy:"), style = "margin-bottom: 5px;"),
          p(strong("Clobber Policy:"), style = "margin-bottom: 5px;"),
          p(strong("Late Policy:"), style = "margin-bottom: 5px;"),
          br(),
          p(strong("Assignments Included:"), style = "margin-bottom: 5px;")
        ),
        div(
          style = "flex: 1; display: flex; flex-direction: column;",
          p(paste(weight), style = "margin-bottom: 5px;"),
          p(paste(drops), style = "margin-bottom: 5px;"),
          p(paste(grading_policy), style = "margin-bottom: 5px;"),
          p(paste(clobber), style = "margin-bottom: 5px;"),
          p(paste(late_policy), style = "margin-bottom: 5px;"),
          br(),
          p(paste(assignments), style = "margin-bottom: 5px;")
        )
      ),
      
      if (i != nrow(categories_table)) {
        hr(style = "border-top: 1px solid #ddd;")
      }
    )
  })
}
