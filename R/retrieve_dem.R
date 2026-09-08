#' Retrieves AWS DEM data for Edinburgh
#' @return A [`terra::SpatRaster`].
#' @export
retrieve_dem <- function() {
  rast(system.file("extdata", "dem.tif", package = "travelgrid"))
}
