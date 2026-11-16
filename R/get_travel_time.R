#' Calculates the travel time from target cells across a friction
#' surface using `terra::costDist()`.
#' @param target_file Path to a raster readable by rast() defining the target cells from which
#'   travel time is calculated.
#' @param friction_file Path to a raster readable by rast() representing the travel cost or
#'   friction of each cell.#'
#' @param dir a working directory.
#' @return Writes a GeoTIFF into the a specified directory for the accumulated least-cost travel
#'   cost from the target cells.
#' @export
get_travel_time <- function(target_file, friction_file, dir = NULL){
  target <- rast(target_file)
  friction <- rast(friction_file)
  t <- crop(target, friction)
  t <- resample(t, friction, method = "near")
  tf <- t*friction
  tf[tf < 0] <- -1
  tt <- costDist(tf, -1)
  if(is.null(dir)){dir <- tempdir()}
  writeRaster(tt,
              filename = paste0(
                dir, "/", basename(friction_file)),
             overwrite = TRUE)
}
