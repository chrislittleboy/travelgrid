#' Extract OSM buildings and highways for an area
#'
#' Downloads an OpenStreetMap PBF extract appropriate for the supplied area,
#' or uses an existing PBF file if supplied.
#'
#' @param filename_area Path to an area-of-interest vector file. The file is
#'   read using [sf::read_sf()] and is used to identify the appropriate
#'   OpenStreetMap extract and to spatially restrict the extracted features.
#' @param osm Optional path to an existing OpenStreetMap PBF file. If `NULL`,
#'   an appropriate PBF is identified using [osmextract::oe_match()] and
#'   downloaded using [osmextract::oe_download()]. Supplying an existing PBF
#'   is useful for testing or when the required extract has already been
#'   downloaded.
#'
#' @return A list with two elements:
#' \describe{
#'   \item{buildings}{A [terra::SpatVector] containing OSM building
#'   footprints within the area of interest.}
#'   \item{network}{A [terra::SpatVector] containing OSM features tagged with
#'   `highway` within the area of interest.}
#' }
#'
#' @importFrom sf read_sf
#' @export

get_osm <- function(filename_area, osm = NULL){

  aoi <- sf::read_sf(filename_area)

  if(is.null(osm)){
    osmdetails <- osmextract::oe_match(aoi)
    osm <- osmextract::oe_download(file_url = osmdetails$url)
    }

  buildings_aoi <- osmextract::oe_read(
    osm,
    layer = "multipolygons",
    boundary = aoi,
    query = "SELECT * FROM multipolygons WHERE building IS NOT NULL"
  )
  network_aoi <- osmextract::oe_read(
    osm,
    layer = "lines",
    boundary = aoi,
    query = "
    SELECT *
    FROM lines
    WHERE highway IS NOT NULL
  "
  )
  buildings_aoi <- vect(buildings_aoi)
  network_aoi <- vect(network_aoi)
  return(list(buildings = buildings_aoi, network = network_aoi))
}
