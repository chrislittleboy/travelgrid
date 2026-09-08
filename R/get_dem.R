#' Downloads elevation data for an area using `elevatr` and prepares it to
#' match a specified raster template.
#' @param area A [`terra::SpatVector`] defining the area for which elevation
#'   data are required.
#' @param template A [`terra::SpatRaster`] defining the extent, resolution,
#'   and coordinate reference system of the output raster.
#' @return A [`terra::SpatRaster`] containing elevation data aligned with
#'   `template`.
#' @export
get_dem <- function(area, template){
  dem <- elevatr::get_elev_raster(locations = sf::st_as_sf(project(area, "epsg:4326")),
                                  src = "aws", z = 11,
                                  override_size_check = TRUE)
  dem <- rast(dem)
  dem <- project(dem, template)
  dem <- resample(dem, template)
  return(dem)
}
