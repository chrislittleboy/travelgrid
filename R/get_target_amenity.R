#' Create an amenity raster
#'
#' Projects OpenStreetMap amenity features to the coordinate reference system
#' of a template raster, buffers them by approximately one cell width, and
#' rasterizes them onto the template grid.
#'
#' @param osm A list containing an `amenity` SpatVector of OpenStreetMap
#'   amenity features.
#' @param template A `SpatRaster` defining the target grid, including its
#'   resolution, extent and coordinate reference system.
#'
#' @return A `SpatRaster` with amenity cells assigned a value of -1 and
#'   background cells assigned a value of 1.
#'
#' @details
#' Amenity features are projected to the coordinate reference system of
#' `template` and buffered by `xres(template) + 1` map units before
#' rasterization. This ensures that amenities are represented in the
#' resulting grid even when they do not intersect a cell centre.
#'
#' @export
get_target_amenity <- function(osm, template){
  amenity <- project(osm$amenity, template)
  amenity <- buffer(amenity, xres(template)+1)
  r <- rasterize(amenity, template, field = -1, background = 1)
  return(r)
}
