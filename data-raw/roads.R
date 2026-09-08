## code to prepare `roads` dataset goes here

roads <- vect("./fulldata/osmnov2025/gis_osm_roads_free_1.shp") |>
  project(st_crs(27700)[[2]]) # gets roads osm data
roads <- crop(roads, edinburgh)
writeVector(roads, "./inst/extdata/roads.shp")
