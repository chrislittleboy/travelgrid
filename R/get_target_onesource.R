#' Transforms a target shapefile into raster format.
#' @param target A [`terra::SpatVector`] defining where people are travelling to.
#' @param area A [`terra::SpatVector`] defining the area of analysis.
#' @param template A [`terra::SpatRaster`] providing the extent, resolution,
#'   and coordinate reference system for the output raster.
#' @return A [`terra::SpatRaster`] in which target cells have a value of `-1`
#'   and all other cells have a value of `1`.
#' @export
get_target_onesource <- function(target, area, template){
  t <- intersect(target,area) # gets target polygon for area
  t <- rasterize(t, template, field = 1) # makes target raster
  t[!is.na(t)] <- -1 # -1 is a target
  t[is.na(t)] <- 1
  return(t)
}
