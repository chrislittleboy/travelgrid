#' Retrieves OSM road network data for Edinburgh
#' @return A [`terra::SpatVector`].
#' @export
#'
retrieve_roads <- function() {
  vect(system.file("extdata", "roads.shp", package = "travelgrid"))
}
