library(shiny)
library(shinythemes)

library(devtools)
devtools::install_github("njmurov-ux/lab5apiaccess")
library(lab5apiaccess)


latlon_to_tile <- function(lat, lon, zoom) {
  n <- 2^zoom
  xtile <- floor((lon + 180) / 360 * n)
  ytile <- floor((1 - log(tan(lat * pi/180) + 1 / cos(lat * pi/180)) / pi) / 2 * n)
  list(x = xtile, y = ytile)
}

ui <- fluidPage(
  titlePanel("Responsive Stadia Tile Viewer (75%)"),
  sidebarLayout(
    sidebarPanel(
      numericInput("lat", "Latitude:", value = 37.7749, min = -90, max = 90),
      numericInput("lon", "Longitude:", value = -122.4194, min = -180, max = 180),
      numericInput("z", "Zoom level:", value = 12, min = 0, max = 18),
      selectInput("style", "Map Style:",
                  choices = c("outdoors", "alidade_smooth", "alidade_smooth_dark",
                              "stamen_toner_lite", "stamen_terrain"))
    ),
    mainPanel(
      imageOutput("tile", width = "75%", height = "auto")  # scaled to 75%
    )
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
      width = floor(panel_width * 0.75),
      height = floor(panel_width * 0.75)   
    )
  }, deleteFile = TRUE)
}

shinyApp(ui, server)