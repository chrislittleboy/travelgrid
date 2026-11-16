#' Extract OSM buildings, highways and health facilities for an area
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
#' @param amenity a string, used to parse and extract relevant itemsfrom OSM points.
#' If NULL, no amenities are extracted and the returned object will have lenght 2.
#' @return A list with three elements:
#'   \describe{
#'     \item{buildings}{A [terra::SpatVector] containing OSM building
#'     footprints within the area of interest.}
#'     \item{network}{A [terra::SpatVector] containing OSM features tagged with
#'     `highway` within the area of interest.}
#'     \item{amenity}{A [terra::SpatVector] containing an amenity (i.e. health facilities)
#' extracted from OSM data.
#'     within the area of interest.}
#'   }
#'
#' @export

get_osm <- function(filename_area, osm = NULL, amenity = NULL){

  aoi <- sf::read_sf(filename_area) |> st_transform(st_crs(4326)$wkt) |> st_union()

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
  buildings_aoi <- vect(buildings_aoi)

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
  network_aoi <- vect(network_aoi)

  if(!is.null(amenity)){
    amenity_query <- paste0(
      "other_tags LIKE '%\"amenity\"=>\"",
      amenity,
      "\"%'"
    )
    amenity_query <- paste(amenity_query, collapse = " OR ")
    amenity_query
    amenity_aoi <- osmextract::oe_read(
    osm,
    layer = "points",
    boundary = aoi,
    query = paste0(
      "SELECT *
       FROM points
       WHERE ", amenity_query
    ))
  amenity_aoi <- vect(amenity_aoi)
  return(list(buildings = buildings_aoi, network = network_aoi, amenity = amenity_aoi))
  }
  return(list(buildings = buildings_aoi, network = network_aoi))
}
