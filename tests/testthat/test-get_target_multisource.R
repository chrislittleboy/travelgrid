bluespace_sources <- list.files(
  system.file("extdata/bluespace", package = "travelgrid"),
  pattern = "\\.shp$",
  full.names = TRUE
)
edinburgh <- retrieve_edinburgh()
template <- rast(edinburgh, res = 100)
bluespace <- get_target_multisource(
  targets = bluespace_sources,
  template = template)

x <- sort(unique(values(bluespace)))
test_that("Returns a SpatRast", {
  expect_s4_class(bluespace, "SpatRaster")
})
test_that("SpatRast has one layer", {
  expect_equal(nlyr(bluespace), 1)
})
test_that("Returns correct classifications", {
  expect_equal(x, c(-1,1))
})
