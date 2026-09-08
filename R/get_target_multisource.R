#' Create a target raster from multiple sources
#' Rasterizes multiple target areas onto a common template and combines them
#' into a single raster identifying all target cells.
#' @param targets A list of filepaths to polygon objects defining target areas.
#' @param template A [`terra::SpatRaster`] providing the extent, resolution,
#' and coordinate reference system of the output raster.
#' @return A [`terra::SpatRaster`] in which target cells have a value of `-1`
#' and all other cells have a value of `1`.
#' @export
get_target_multisource <- function(targets, template){
target_list <- lapply(targets, function(t){
  v <- vect(t)
  rasterize(x = v,
            y = template,
            field = 1)})
target_rast <- rast(target_list)
ts <- app(target_rast, fun = "max", na.rm = TRUE)
ts[!is.na(ts)] <- -1
ts[is.na(ts)] <- 1
return(ts)
}
