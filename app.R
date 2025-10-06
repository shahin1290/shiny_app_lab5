library(devtools)
devtools::install_github("njmurov-ux/lab5apiaccess")
library(lab5apiaccess)

library(shiny)
library(shinythemes)
set_stadia_api_key("645a1c62-4a7d-4ad2-a407-b7e5510009e3")


# Convert latitude/longitude to tile coordinates
latlon_to_tile <- function(lat, lon, zoom) {
  n <- 2^zoom
  xtile <- floor((lon + 180) / 360 * n)
  ytile <- floor((1 - log(tan(lat * pi/180) + 1 / cos(lat * pi/180)) / pi) / 2 * n)
  list(x = xtile, y = ytile)
}

ui <- fluidPage(
  theme = shinytheme("flatly"),
  
  # Remove default padding
  tags$style(HTML("
    .container-fluid {
      padding-left: 0px;
      padding-right: 0px;
    }
  ")),
  
  # Full-width header
  tags$header(
    style = "width:100%; background-color:#2c3e50; color:white; padding:15px; 
             text-align:center; position:relative; z-index:1000;",
    tags$h1("Shiny Map")
  ),
  
  # Description (centered)
  tags$div(
    style = "font-size: 20px; padding:10px; margin:15px auto; background-color:#ecf0f1; text-align:center; width:80%;",
    tags$p("This app allows you to view Maps tiles at a specified location, zoom level, and map style."),
    tags$p("Use the sidebar to change latitude, longitude, zoom, or style."),
  ),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("lat", "Latitude:", value = 58.41034521233622, min = -90, max = 90, , step = 0.1),
      numericInput("lon", "Longitude:", value = 15.56316375732422, min = -180, max = 180, , step = 0.1),
      numericInput("z", "Zoom level:", value = 12, min = 0, max = 18),
      selectInput("style", "Map Style:",
                  choices = c("outdoors", "alidade_smooth", "alidade_smooth_dark",
                              "stamen_toner_lite", "stamen_terrain"))
    ),
    mainPanel(
      tags$div(
        style = "padding:20px; border:1px solid #ddd; background-color:#f8f9fa; margin-bottom:80px;",
        imageOutput("tile", width = "75%", height = "auto")
      )
    )
  ),
  
  # Sticky Footer
  tags$footer(
    style = "
      position: fixed;
      bottom: 0;
      left: 0;
      width: 100%;
      background-color:#2c3e50; 
      color:white; 
      padding:10px; 
      text-align:center;
      z-index:1000;",
    "© 2025 Shiny Map. All rights reserved."
  )
)

server <- function(input, output, session) {
  
  tile_file <- reactive({
    xy <- latlon_to_tile(input$lat, input$lon, input$z)
    tmpfile <- tempfile(fileext = ".png")
    
    try({
      stadia_get_tile(
        z = input$z,
        x = xy$x,
        y = xy$y,
        style = input$style,
        file = tmpfile
      )
      tmpfile
    }, silent = TRUE)
  })
  
  output$tile <- renderImage({
    req(tile_file())
    panel_width <- session$clientData$output_tile_width
    list(
      src = tile_file(),
      contentType = "image/png",
      width = floor(panel_width * 0.65),
      height = floor(panel_width * 0.65)
    )
  }, deleteFile = TRUE)
}

shinyApp(ui, server)

