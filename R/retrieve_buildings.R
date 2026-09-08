#' Retrieves OSM building footprint data for Edinburgh
#' @return A [`terra::SpatVector`].
#' @export
retrieve_buildings <- function() {
  vect(system.file("extdata", "buildings.shp", package = "travelgrid"))
}
