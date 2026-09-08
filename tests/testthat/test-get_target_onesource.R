greenspace_source <- vect(system.file("extdata", "greenspace.shp", package = "travelgrid")) # gets os greenspace data
edinburgh <- retrieve_edinburgh()
template <- rast(edinburgh, res = 100)
greenspace <- get_target_onesource(greenspace_source, edinburgh, template)
x <- sort(unique(values(greenspace)))
test_that("Returns a SpatRast", {
  expect_s4_class(greenspace, "SpatRaster")
})
test_that("SpatRast has one layer", {
  expect_equal(nlyr(greenspace), 1)
})
test_that("Returns correct classifications", {
  expect_equal(x, c(-1,1))
})

