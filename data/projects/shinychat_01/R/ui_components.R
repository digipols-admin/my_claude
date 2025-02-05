#' Create sidebar UI
#' @return Shiny sidebar UI component
create_sidebar <- function() {
  sidebar(
    selectInput("model", "Claude Model:",
                choices = c("claude-3-sonnet-20240229",
                            "claude-3-haiku-20240307"),
                selected = "claude-3-sonnet-20240229"),
    
    selectInput("system_prompt", "System Prompt:",
                choices = names(system_prompts),
                selected = "Project File Analyzer"),
    
    selectInput("current_project", "Project Directory:",
                choices = c("None", list_projects()),
                selected = "None"),
    
    actionButton("refresh_projects", "Refresh Project List",
                 class = "btn-secondary",
                 width = "100%"),
    
    actionButton("new_chat", "Start New Chat",
                 class = "btn-primary",
                 width = "100%"),
    
    fileInput("files", "Upload Additional Files",
              multiple = TRUE,
              accept = c(".r", ".qmd", ".Rmd", ".csv", ".txt", ".yml", ".json"),
              width = "100%")
  )
}
