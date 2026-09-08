#' Creates a friction surface for a grid cell using elevation, slope, and
#' built-environment data. Friction represents traversal time in seconds
#' per metre, incorporating walking speed from slope and adjustments for the
#' built environment. and can optionally be written to disk as a GeoTIFF.
#'
#' @param grid A [`terra::SpatVector`] containing the analysis grid and an
#'   `id` attribute.
#' @param id The identifier of the grid cell for which friction is calculated.
#' @param gridsize The size of the analysis grid cell in map units.
#' @param resolution The spatial resolution of the friction raster in map
#'   units.
#' @param dem A [`terra::SpatRaster`] containing elevation data.
#' @param built_environment A [`terra::SpatRaster`] containing built-environment
#'   friction values.
#' @param todisk Logical; whether to write the friction surface to disk.
#' @param dir Character; directory in which to write friction surfaces.
#' @return A [`terra::SpatRaster`] containing the friction surface for the
#'   specified grid cell.
#' @export

get_friction <- function(
    grid,
    id,
    gridsize,
    resolution,
    dem,
    built_environment,
    todisk = FALSE,
    dir = NULL){

  aoi <- grid[grid$id == id,]

  tpl <- rast(aoi, res = resolution) # makes a grid covering the AOI in a given resolution
  tpl <- extend(tpl, ceiling((gridsize/resolution)/2)) # adds space  to the edges of the grid to account for spillovers

  built_environment <- crop(built_environment, tpl)
  built_environment <- resample(built_environment, tpl, method = "near")

  ele <- crop(dem, tpl)
  ele <- resample(ele, tpl)

  slope <- terrain(ele, unit = "radians")
  tobler <- slope
  tobler[] <- get_tobler(values(slope)) # fills cost distance with topography information
  tobler[tobler < 1] <- 1 # means that 1km/h is the slowest speed possible (to prevent too high friction values where DEM values are potential errors)
  friction <- 3.6 / tobler # simplified, km/h to m/s

  friction <- friction * built_environment # accounts for walking routes via paths/roads and avoiding buildings

  if(isTRUE(todisk)){
  writeRaster(friction, filename = paste0(dir, "./frictiontiles/t",id, ".tif"), overwrite = TRUE)
  if(id%%50 == 0){print(paste("Done:", id))}
  }
  return(friction)
}

