#' Creates a friction surface for a grid cell using elevation, slope, and
#' built-environment data. Friction represents traversal time in seconds
#' per metre, incorporating walking speed from slope and adjustments for the
#' built environment. and can optionally be written to disk as a GeoTIFF.
#'
#' @param grid_file a path to a shp file with an analysis grid and an
#'   `id` attribute.
#' @param id The identifier of the grid cell for which friction is calculated.
#' @param gridsize The size of the analysis grid cell in map units.
#' @param resolution The spatial resolution of the friction raster in map
#'   units.
#' @param dem_file A filepath to a .tif containing elevation data.
#' @param built_environment_file A filepath to a .tif containing built-environment
#'   friction values.
#' @param dir Character; directory in which to write friction surfaces.
#' @return Writes a GeoTIFF into a newly created directory, frictiontiles.

#' @export

get_friction <- function(
    grid_file,
    id,
    gridsize,
    resolution,
    dem_file,
    built_environment_file,
    dir = NULL){

  grid <- vect(grid_file)
  aoi <- grid[grid$id == id,]

  tpl <- rast(aoi, res = resolution) # makes a grid covering the AOI in a given resolution
  tpl <- extend(tpl, ceiling((gridsize/resolution)/2)) # adds space  to the edges of the grid to account for spillovers

  built_environment <- rast(built_environment_file)
  built_environment <- crop(built_environment, tpl)
  built_environment <- resample(built_environment, tpl, method = "near")

  dem <- rast(dem_file)
  ele <- crop(dem, tpl)
  ele <- resample(ele, tpl)

  slope <- terrain(ele, unit = "radians")
  tobler <- slope
  tobler[] <- get_tobler(values(slope)) # fills cost distance with topography information
  tobler[tobler < 1] <- 1 # means that 1km/h is the slowest speed possible (to prevent too high friction values where DEM values are potential errors)
  friction <- 3.6 / tobler # simplified, km/h to m/s

  friction <- friction * built_environment # accounts for walking routes via paths/roads and avoiding buildings
  if(is.null(dir)){dir <- tempdir()}
  dir.create(file.path(dir, "frictiontiles"), showWarnings = FALSE)
  writeRaster(friction, filename = paste0(dir, "/frictiontiles/t",id, ".tif"), overwrite = TRUE)
}

