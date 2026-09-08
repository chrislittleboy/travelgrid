## code to prepare `roads` dataset goes here

buildings <- vect("./fulldata/osmnov2025/gis_osm_buildings_a_free_1.shp") |> project(st_crs(27700)[[2]])# gets buildings osm data
buildings <- crop(buildings, edinburgh)
writeVector(buildings, "./inst/extdata/buildings.shp")
