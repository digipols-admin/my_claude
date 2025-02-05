#' Initialize chat instance
#' @param input Shiny input object
#' @return Claude chat instance
initialize_chat <- function(input) {
  tryCatch({
    ellmer::chat_claude(
      system_prompt = system_prompts[[input$system_prompt]],
      model = input$model
    )
  }, error = function(e) {
    warning("Failed to initialize chat: ", e$message)
    NULL
  })
}

#' Handle chat messages
#' @param input Shiny input
#' @param chat Chat instance
handle_chat_message <- function(input, chat) {
  if (is.null(chat)) return()
  
  files_content <- process_uploaded_files(input$files)
  project_content <- read_project_contents(input$current_project)
  
  user_message <- construct_message(
    input$chat_user_input,
    files_content,
    project_content
  )
  
  stream <- chat$stream_async(user_message)
  chat_append("chat", stream)
}