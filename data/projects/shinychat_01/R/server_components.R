#' Initialize chat instance
#' @param input Shiny input object
#' @return Claude chat instance
initialize_chat <- function(input) {
  ellmer::chat_claude(
    system_prompt = system_prompts[[input$system_prompt]],
    model = input$model
  )
}

#' Handle chat messages
#' @param input Shiny input
#' @param chat Chat instance
handle_chat_message <- function(input, chat) {
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
