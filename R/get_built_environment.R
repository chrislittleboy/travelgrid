#' Rasterizes buildings and roads onto a common template to create a surface
#' representing areas that are impassable, preferential walking routes, and
#' unrestricted areas.
#'
#' @param buildings A [`terra::SpatVector`] containing building polygons.
#' @param roads A [`terra::SpatVector`] containing roads and paths.
#' @param template A [`terra::SpatRaster`] defining the extent, resolution,
#'   and coordinate reference system of the output raster.
#' @param road_travel Numeric friction value applied travel along roads and paths.
#'   This is a scalar adjustment to slope-derived Tobler walking speeds.
#'   A value of 2, for example, means that the speed of travel is halved.
#' @param non_road_travel Numeric friction value applied to areas that are not
#'   buildings or roads but remain passable.
#'   This is a scalar adjustment to slope-derived Tobler walking speeds.
#'   A value of 2, for example, means that the speed of travel is halved.
#' @return A [`terra::SpatRaster`] representing the built-environment friction
#'   surface. Building cells are `NA` (impassable), non-road areas have the
#'   value specified by `non_roadpace`, and unrestricted cells have a value of
#'   `1`.
#'
#' @export

get_built_environment <- function(buildings, roads, template, road_travel = 1, non_road_travel = 1){
  br <- rasterize(buildings,template, field = 0, background = -1, touches = TRUE) # gets building data as a raster
  rr <- rasterize(roads,template, field = -1, background = 0, touches = TRUE) # gets road and path data as a raster
  brr <- br + rr # gets building and road data together
  brr[brr == 0] <- NA # building but not a road - impassable
  brr[brr == -1] <- non_road_travel # can be used to slow non-path walking
  brr[brr == -2] <- road_travel # not building not road
  return(brr)
  }
