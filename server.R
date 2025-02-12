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
    print("New Chat button pressed") # Debug print
    
    # Create a new chat instance
    isolate({
      new_chat <- initialize_chat(input)
      print("New chat initialized") # Debug print
      chat_instance(new_chat)
    })
    
    # Clear the input field
    updateTextAreaInput(session, "chat_user_input", value = "")
    
    # Force UI refresh
    output$chat_ui <- renderUI({
      # Assuming you have a chat_ui output in your UI
      div(
        id = "chat-container",
        # Add any initial chat UI elements here
        textAreaInput("chat_user_input", "Enter your message:", width = "100%"),
        actionButton("send", "Send")
      )
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