source("R/server_components.R")

server <- function(input, output, session) {
  # Load the shinychat package
  library(shinychat)
  
  # Initialize chat instance with reactiveVal instead of reactive
  chat_instance <- reactiveVal(NULL)
  
  # Initialize chat on startup
  observe({
    if (is.null(chat_instance())) {
      chat_instance(initialize_chat(input))
    }
  })
  
  # Handle chat messages
  observeEvent(input$chat_user_input, {
    req(chat_instance())
    handle_chat_message(input, chat_instance())
  })
  
  # Handle new chat button
  observeEvent(input$new_chat, {
    # First clear the chat UI
    chat_clear("chat")
    # Then create a new chat instance
    isolate({
      chat_instance(initialize_chat(input))
    })
  }, ignoreInit = TRUE)
  
  # Update project list when new projects are added
  observe({
    invalidateLater(30000) # Changed to 30 seconds
    projects <- c("None", list_projects())
    updateSelectInput(session, "current_project",
                      choices = projects,
                      selected = input$current_project)
  })
}