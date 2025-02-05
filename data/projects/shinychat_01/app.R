# Load all required functions and components first
# source("R/functions.R")
# source("R/ui_components.R")
# source("R/server_components.R")

# Load global configuration
source("global.R")

# Load UI and server
source("ui.R")
source("server.R")

# Run the application
shinyApp(ui = ui, server = server)

