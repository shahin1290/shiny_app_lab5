stadia_get_tile_safe <- function(z, x, y, style = "outdoors", file = NULL) {
  # Validate zoom
  if (!is.numeric(z) || length(z) != 1 || z < 0 || z > 22) {
    stop("Zoom level 'z' must be an integer between 0 and 22.")
  }
  z <- as.integer(z)
  
  # Validate x/y ranges
  max_tile <- 2^z - 1
  if (x < 0 || x > max_tile || y < 0 || y > max_tile) {
    stop(sprintf("Tile coordinates out of range for zoom %d: x and y must be 0..%d", z, max_tile))
  }
  
  # Validate style
  valid_styles <- c("outdoors", "alidade_smooth", "alidade_smooth_dark",
                    "stamen_toner_lite", "stamen_terrain")
  if (!(style %in% valid_styles)) {
    stop("Invalid style. Choose from: ", paste(valid_styles, collapse = ", "))
  }
  
  # Try fetching the tile
  tryCatch(
    {
      stadia_get_tile(z = z, x = x, y = y, style = style, file = file)
    },
    error = function(e) {
      stop("Failed to fetch tile: ", e$message)
    }
  )
}
