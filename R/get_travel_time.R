#' Calculates the travel time from target cells across a friction
#' surface using `terra::costDist()`.
#' @param target A [`terra::SpatRaster`] defining the target cells from which
#'   travel time is calculated.
#' @param friction A [`terra::SpatRaster`] representing the travel cost or
#'   friction of each cell.#'
#' @return A [`terra::SpatRaster`] containing the accumulated least-cost travel
#'   cost from the target cells.
#' @export
get_travel_time <- function(target, friction){
  t <- crop(target, friction)
  t <- resample(t, friction, method = "near")
  tf <- t*friction
  tf[tf < 0] <- -1
  tt <- costDist(tf, -1)
}
