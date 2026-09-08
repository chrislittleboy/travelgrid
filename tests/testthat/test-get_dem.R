edinburgh <- retrieve_edinburgh()
template <- rast(edinburgh, res = 100)
dem <- get_dem(edinburgh, template)

test_that("Returns a SpatRast", {
  expect_s4_class(dem, "SpatRaster")
})
