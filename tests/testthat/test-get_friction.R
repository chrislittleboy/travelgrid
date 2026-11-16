roads <- retrieve_roads()
buildings <- retrieve_buildings()
edinburgh <- retrieve_edinburgh()
template <- rast(edinburgh, res=100)
dem <- retrieve_dem()
gridsize <- 5000
grid <- make_grid(edinburgh, gridsize)
built_environment <- get_built_environment(buildings, roads, template, non_road_travel = 2)
wd <- tempdir()
writeVector(grid, paste0(wd, "/grid.shp"), overwrite = TRUE)
writeRaster(built_environment, paste0(wd, "/be.tif"), overwrite = TRUE)
writeRaster(dem, paste0(wd, "/dem.tif"), overwrite = TRUE)

friction_grid <- lapply(FUN = get_friction,
                        X = sample(1:nrow(grid), 5),
                        grid_file = paste0(wd, "/grid.shp"),
                        gridsize = gridsize,
                        resolution = xres(template),
                        built_environment_file = paste0(wd, "/be.tif"),
                        dem_file = paste0(wd, "/dem.tif"),
                        dir = wd)

friction <- trim(mosaic(sprc(list.files(file.path(wd, "frictiontiles"), full.names = TRUE))))

mm <- as.numeric(minmax(friction))

test_that("Friction grids are all SpatRasters", {
  expect_s4_class(friction, "SpatRaster")
})

test_that("Minimum speed respected", {
  expect_true(mm[1] > 0)
})

test_that("Maximum speed respected", {
  expect_true(mm[2] < 10)
})
