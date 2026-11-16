greenspace_source <- vect(system.file("extdata", "greenspace.shp", package = "travelgrid")) # gets os greenspace data
edinburgh <- retrieve_edinburgh()
template <- rast(edinburgh, res = 100)
greenspace <- get_target_onesource(greenspace_source, template)
wd <- tempdir()
writeRaster(greenspace, file.path(wd, "gs.tif"), overwrite = TRUE)
friction <- rast(system.file("extdata", "friction.tif", package = "travelgrid"))

tt <- get_travel_time(
  target_file = file.path(wd, "gs.tif"),
  friction_file = system.file("extdata", "friction.tif", package = "travelgrid")
  )

test_that("Returns a SpatRast", {
  expect_s4_class(tt, "SpatRaster")
})
