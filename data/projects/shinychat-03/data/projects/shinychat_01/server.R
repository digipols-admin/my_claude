source("R/server_components.R")

server <- function(input, output, session) {
  # Reactive chat instance
  chat <- reactive(initialize_chat(input))
  
  # Handle chat messages
  observeEvent(input$chat_user_input, {
    handle_chat_message(input, chat())
  })
  
  # Handle new chat button
  observeEvent(input$new_chat, {
    chat_clear("chat")
  })
  
  # Create a reactive value to store project list
  projects_rv <- reactiveVal(c("None", list_projects()))
  
  # Update project list less frequently and more efficiently
  observe({
    invalidateLater(30000)  # Check every 30 seconds instead of 5
    req(session$token)      # Only run if session is active
    
    # Get current project list
    new_projects <- c("None", list_projects())
    
    # Only update if the list has changed
    if (!identical(new_projects, projects_rv())) {
      projects_rv(new_projects)
      updateSelectInput(session, "current_project",
                        choices = new_projects,
                        selected = isolate(input$current_project))
    }
  })
}