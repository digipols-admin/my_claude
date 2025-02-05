source("R/ui_components.R")

ui <- page_sidebar(
  title = "AI Assistant for Dashboard Development",
  sidebar = create_sidebar(),
  chat_ui("chat")
)
