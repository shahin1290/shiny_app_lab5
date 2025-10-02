library(shiny)
library(shinythemes)

library(devtools)
devtools::install_github("njmurov-ux/lab5apiaccess")
library(lab5apiaccess)


ui <- fluidPage(
  titlePanel("Stadia Tile Viewer"),
  imageOutput("tile")
)

server <- function(input, output, session) {
  output$tile <- renderImage({
    # Save to a temporary file
    tmpfile <- tempfile(fileext = ".png")
    stadia_get_tile(
      12, 654, 1577, style = "outdoors", file = tmpfile
    )
    list(
      src = tmpfile,
      contentType = "image/png",
      width = 256, height = 256
    )
  }, deleteFile = TRUE)  # delete temp file when done
}

shinyApp(ui, server)
