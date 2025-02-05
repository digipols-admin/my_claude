library(shiny)
library(shinychat)
library(bslib)
library(ellmer)

# Predefined system prompts
system_prompts <- list(
  "R Dashboard Expert" = "You are an expert R programmer who prefers the tidyverse. 
    You should take into account that we will be programming in Quarto, therefore your code should be compatible with .qmd files. 
    We will be developing dashboards and websites with Quarto code. For reactive elements we will be using using observable js (OJS) or shiny, shinylive. 
    When working with quarto OJS you should prefer ojs native functions rather than adding more complicated .html solutions for creating interactive plots or rendering filtered tables.
    Provide your output in markdown type syntax with clearly delineated inline Quarto code.",
  
  "Observable JS Expert" = "You are an Observable JS expert. 
    Focus on creating reactive dashboards using Observable JS (ojs) cells in Quarto.
    Prefer native Observable Plot over external libraries when possible.
    Always explain how the reactivity flow works in your solutions.
    Include proper variable declarations with mutable states when needed.",
  
  "Data Viz Consultant" = "You are a data visualization consultant specializing in Quarto dashboards.
    Provide guidance on best practices for data visualization.
    Suggest appropriate chart types based on the data and analytical goals.
    Include accessibility considerations in your recommendations."
)

ui <- page_sidebar(
  title = "AI Assistant for Dashboard Development",
  subtitle = "Powered by Claude",
  
  sidebar = sidebar(
    selectInput("model", "Claude Model:",
                choices = c("claude-3-sonnet-20240229",
                            "claude-3-haiku-20240307"),
                selected = "claude-3-sonnet-20240229"),
    
    selectInput("system_prompt", "System Prompt:",
                choices = names(system_prompts),
                selected = "R Dashboard Expert"),
    
    actionButton("new_chat", "Start New Chat",
                 class = "btn-primary",
                 width = "100%"),
    
    fileInput("files", "Upload Files",
              multiple = TRUE,
              accept = c(".r", ".qmd", ".Rmd", ".csv", ".txt", ".yml"),
              width = "100%")
  ),
  
  chat_ui("chat")
)

server <- function(input, output, session) {
  # Reactive chat instance
  chat <- reactive({
    ellmer::chat_claude(
      system_prompt = system_prompts[[input$system_prompt]],
      model = input$model
    )
  })
  
  # Function to read file contents
  read_file_contents <- function(file_path) {
    tryCatch({
      readLines(file_path, warn = FALSE) |> 
        paste(collapse = "\n")
    }, error = function(e) {
      paste("Error reading file:", e$message)
    })
  }
  
  # Handle chat messages
  observeEvent(input$chat_user_input, {
    # Process uploaded files if any
    files_content <- ""
    if (!is.null(input$files)) {
      files_content <- sapply(input$files$datapath, function(path) {
        file_name <- basename(path)
        content <- read_file_contents(path)
        sprintf("\n### File: %s\n```\n%s\n```\n", file_name, content)
      }) |> 
        paste(collapse = "\n")
    }
    
    # Construct the message with clear separation between query and files
    user_message <- if (files_content != "") {
      sprintf("%s\n\n### Attached Files:\n%s", 
              input$chat_user_input,
              files_content)
    } else {
      input$chat_user_input
    }
    
    # Send to Claude and handle response
    stream <- chat()$stream_async(user_message)
    chat_append("chat", stream)
  })
  
  # Handle new chat button
  observeEvent(input$new_chat, {
    chat_clear("chat")
  })
}

shinyApp(ui, server)