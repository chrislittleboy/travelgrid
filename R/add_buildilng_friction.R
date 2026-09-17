#' Add friction to building cells
#'
#' Assigns friction values to building cells and combines these with an
#' existing friction raster. Building friction is intended for use with
#' [terra::costDist()], where buildings should be strongly discouraged as
#' travel routes but should not necessarily be completely impassable.
#'
#' @param built_environment A `SpatRaster` identifying the built environment.
#'   Building cells must have `NA` values and non-building cells must have
#'   non-`NA` values.
#' @param friction A `SpatRaster` containing the existing friction values.
#'   The building friction is combined with this raster using the cell-wise
#'   maximum.
#' @param constant Numeric multiplier controlling the magnitude of the
#'   friction assigned to building cells. Defaults to `3.6` to tally with
#'   Tobler walking speed on steep terrain.
#' @param distance_weighted Logical; if `TRUE`, friction increases with
#'   distance into a building. If `FALSE`, all building cells receive the
#'   same friction. Defaults to `TRUE`.
#'
#' @return A `SpatRaster` containing the original friction values together
#'   with friction values assigned to building cells.
#'
#' @details
#' When `distance_weighted = TRUE`, [terra::distance()] is used to calculate
#' the distance of each cell to the nearest non-building cell. Distances are
#' expressed in raster-cell units by dividing by the mean raster resolution.
#' Consequently, cells near the edge of a building receive lower friction,
#' while cells further inside the building receive progressively higher
#' friction.
#'
#' When `distance_weighted = FALSE`, all building cells are assigned the
#' value of `constant`.
#'
#' The resulting building friction is resampled to the resolution and extent
#' of `friction` and combined with the existing friction using the cell-wise
#' maximum. This allows buildings to act as high-friction areas in
#' [terra::costDist()] without making them completely impassable.
#'
#' @seealso [terra::costDist()], [terra::distance()]
#'
#' @export
get_building_friction <- function(built_environment, friction,
                                  constant = 3.6, distance_weighted = TRUE) {
  if (distance_weighted == TRUE) {
    r <- distance(built_environment)
    r <- r / mean(res(r))
  }

  if (distance_weighted != TRUE) {
    r <- ifel(is.na(built_environment), 1, 0)
  }

  r <- r * constant
  r <- resample(r, friction, method = "near")
  friction_including_buildings <- app(c(r, friction), "max", na.rm = TRUE)
  mi <- minmax(friction)[1]
  friction_including_buildings[friction_including_buildings == 0] <- mi
  return(friction_including_buildings)
}
