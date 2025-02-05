#' Read file contents safely
#' @param file_path Path to the file to read
#' @return Character string of file contents
read_file_contents <- function(file_path) {
  tryCatch({
    if (tolower(tools::file_ext(file_path)) == "json") {
      # Pretty print JSON for better readability
      content <- jsonlite::read_json(file_path)
      jsonlite::toJSON(content, auto_unbox = TRUE, pretty = TRUE)
    } else {
      readLines(file_path, warn = FALSE) |> 
        paste(collapse = "\n")
    }
  }, error = function(e) {
    paste("Error reading file:", e$message)
  })
}

#' Read project directory contents
#' @param project_name Name of the project directory
#' @return Formatted string of file contents
read_project_contents <- function(project_name) {
  if (is.null(project_name) || project_name == "None") return("")
  
  project_path <- file.path("data/projects", project_name)
  if (!dir.exists(project_path)) return("")
  
  # Get all files recursively
  files <- list.files(project_path, 
                      recursive = TRUE, 
                      full.names = TRUE,
                      pattern = "\\.([Rr]|[Rr]md|qmd|csv|txt|yml|json)$")
  
  contents <- sapply(files, function(file_path) {
    rel_path <- sub("data/projects/[^/]+/", "", file_path)
    content <- read_file_contents(file_path)
    sprintf("\n### File: %s\n```\n%s\n```\n", rel_path, content)
  })
  
  paste(contents, collapse = "\n")
}

#' Process uploaded files
#' @param files Input$files from Shiny
#' @return Formatted string of file contents
process_uploaded_files <- function(files) {
  if (is.null(files)) return("")
  
  sapply(files$datapath, function(path) {
    file_name <- basename(path)
    content <- read_file_contents(path)
    sprintf("\n### File: %s\n```\n%s\n```\n", file_name, content)
  }) |> 
    paste(collapse = "\n")
}

#' Construct user message
#' @param input_text User input text
#' @param files_content Processed file content
#' @param project_content Project directory content
#' @return Combined message string
construct_message <- function(input_text, files_content, project_content) {
  msg_parts <- c()
  
  if (nzchar(input_text)) msg_parts <- c(msg_parts, input_text)
  
  if (nzchar(files_content)) {
    msg_parts <- c(msg_parts, 
                   "\n\n### Uploaded Files:",
                   files_content)
  }
  
  if (nzchar(project_content)) {
    msg_parts <- c(msg_parts, 
                   "\n\n### Project Files:",
                   project_content)
  }
  
  paste(msg_parts, collapse = "\n")
}

