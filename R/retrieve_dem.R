#' Retrieves AWS DEM data for Edinburgh.
#' Raw elevation values were divided by 2
#' and stored as integers between 0 and 255 to minimize filesize.
#' @return A [`terra::SpatRaster`].
#' @export
retrieve_dem <- function() {
  rast(system.file("extdata", "dem.tif", package = "travelgrid"))*2
}
