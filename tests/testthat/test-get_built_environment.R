roads <- retrieve_roads()
buildings <- retrieve_buildings()
edinburgh <- retrieve_edinburgh()
template <- rast(edinburgh, res=100)

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
