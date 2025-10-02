library(shiny)
library(shinythemes)

library(devtools)
devtools::install_github("njmurov-ux/lab5apiaccess")
library(lab5apiaccess)




ui <- fluidPage(
  titlePanel("Stadia Tile Viewer"),
  sidebarLayout(
    sidebarPanel(
      numericInput("z", "Zoom level (z):", value = 12, min = 0, max = 18),
      numericInput("x", "Tile X:", value = 654, min = 0, max = 999999),
      numericInput("y", "Tile Y:", value = 1577, min = 0, max = 999999),
      selectInput("style", "Map Style:",
                  choices = c("outdoors", "alidade_smooth", "alidade_smooth_dark",
                              "stamen_toner_lite", "stamen_terrain"))
    ),
    mainPanel(
      imageOutput("tile", width = "512px", height = "512px")  # <- larger display
    )
  )
)

server <- function(input, output, session) {
  
  # Reactive expression to fetch the tile
  tile_file <- reactive({
    tmpfile <- tempfile(fileext = ".png")
    
    try({
      stadia_get_tile(
        z = input$z,
        x = input$x,
        y = input$y,
        style = input$style,
        file = tmpfile
      )
      tmpfile
    }, silent = TRUE)
  })
  
  # Render the image
  output$tile <- renderImage({
    req(tile_file())
    list(
      src = tile_file(),
      contentType = "image/png",
      width = 512,  # <- match display width
      height = 512  # <- match display height
    )
  }, deleteFile = TRUE)
}

shinyApp(ui, server)