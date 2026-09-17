roads <- retrieve_roads() |> project("epsg:3857")
buildings <- retrieve_buildings() |> project("epsg:3857")
aoi <- terra::convHull(
  rbind(
    terra::vect(terra::geom(roads)),
    terra::vect(terra::geom(buildings))
  )
) |>
  st_as_sf()
template <- rast(aoi, res=10, crs = crs(roads))

built_environment <- get_built_environment(buildings, roads, template, non_road_travel = 1)
built_environment_f <- get_built_environment(buildings, roads, template, non_road_travel = 2)

freq_b <- nrow(freq(built_environment))
freq_bf <- nrow(freq(built_environment_f))

test_that("Built environment without speed adjustments returns correct number of classess", {
  expect_equal(freq_b, 1)
})
test_that("Built environment with speed adjustments returns correct number of classess", {
  expect_equal(freq_bf, 2)
})
test_that("Returns a SpatRast", {
  expect_s4_class(built_environment, "SpatRaster")
})
