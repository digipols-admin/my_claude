# Load required packages
library(shiny)
library(shinychat)
library(bslib)
library(ellmer)
library(tidyverse)

# Load system prompts
system_prompts_df <- read_csv("data/system_prompts.csv")

# Convert to format needed for selectInput
system_prompts <- setNames(
  system_prompts_df$description,
  system_prompts_df$title
)

# Function to list projects
list_projects <- function(projects_dir = "data/projects") {
  if (!dir.exists(projects_dir)) return(character(0))
  list.dirs(projects_dir, full.names = FALSE, recursive = FALSE)
}

# API keys and other configurations could go here
# config <- config::get()
# claude_api_key <- config$claude_api_key