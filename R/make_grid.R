#' Creates a regular grid of polygons covering an area.
#' @param area A [`terra::SpatVector`] defining the area to cover.
#' @param gridsize The grid cell size in map units.
#' @return A [`terra::SpatVector`] containing the grid cells, with an `id`
#'   attribute identifying each cell.
#' @export
make_grid <- function(area, gridsize){
  grid <- rast(area, resolution = gridsize, vals = 1)
  grid <- mask(grid, area, touches = TRUE)
  grid <- extend(grid, 3)
  grid <- buffer(grid, gridsize)
  grid <- ifel(grid, 1,NA)
  grid <- as.polygons(grid, aggregate = FALSE, na.rm = TRUE)
  names(grid) <- "id"
  grid$id <- 1:nrow(grid)
  return(grid)
}
