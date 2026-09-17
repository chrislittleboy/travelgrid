test_that("get_osm returns the expected SpatVector list", {
  osm <- system.file("its-example.osm.pbf", package = "osmextract")
  aoi <- osmextract::oe_read(osm, layer = "multipolygons") |>
    sf::st_union() |>
    sf::st_convex_hull() |>
    sf::st_as_sf() |>
    sf::write_sf(paste0(tempdir(), "/testaoi.shp"))
  results <- get_osm(filename_area = paste0(tempdir(), "/testaoi.shp"), osm = osm)
  expect_equal(names(results), c("buildings", "network"))
  expect_s4_class(results[[1]], "SpatVector")
  expect_s4_class(results[[2]], "SpatVector")
})
