#' Retrieves the City of Edinburgh locality boundary
#' @return A [`terra::SpatVector`].
#' @export
#'
retrieve_edinburgh <- function() {
  vect(system.file("extdata", "edinburgh.shp", package = "travelgrid"))
}
