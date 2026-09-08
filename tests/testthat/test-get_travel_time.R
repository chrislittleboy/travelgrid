greenspace_source <- vect(system.file("extdata", "greenspace.shp", package = "travelgrid")) # gets os greenspace data
edinburgh <- retrieve_edinburgh()
template <- rast(edinburgh, res = 100)
greenspace <- get_target_onesource(greenspace_source, edinburgh, template)
friction <- rast(system.file("extdata", "friction.tif", package = "travelgrid"))

tt <- get_travel_time(friction, greenspace)

test_that("Returns a SpatRast", {
  expect_s4_class(tt, "SpatRaster")
})
