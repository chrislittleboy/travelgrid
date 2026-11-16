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
dem <- built_environment
dem[] <- sample(x = 1:100, size = length(built_environment[]), replace = TRUE)
gridsize <- 500
aoi <- aoi |> vect() |> set.crs("epsg:3857")
grid <- make_grid(aoi, gridsize)
wd <- tempdir()
writeVector(grid, paste0(wd, "/grid.shp"), overwrite = TRUE)
writeRaster(built_environment, paste0(wd, "/be.tif"), overwrite = TRUE)
writeRaster(dem, paste0(wd, "/dem.tif"), overwrite = TRUE)

friction_grid <- lapply(FUN = get_friction,
                        X = 1:nrow(grid),
                        grid_file = paste0(wd, "/grid.shp"),
                        gridsize = gridsize,
                        resolution = xres(template),
                        built_environment_file = paste0(wd, "/be.tif"),
                        dem_file = paste0(wd, "/dem.tif"),
                        dir = wd)

friction <- trim(mosaic(sprc(list.files(file.path(wd, "frictiontiles"), full.names = TRUE))))
built_environment <- resample(built_environment, friction)
writeRaster(friction, file.path(wd, "friction.tif"), overwrite = TRUE)
writeRaster(built_environment, file.path(wd, "be.tif"), overwrite = TRUE)

suppressWarnings(building_friction <- get_building_friction(
  built_environment_file = file.path(wd, "be.tif"),
  friction_file = file.path(wd, "friction.tif")
))

building_friction_constant <- get_building_friction(
  built_environment_file = file.path(wd, "be.tif"),
  friction_file = file.path(wd, "friction.tif"),
  distance_weighted = FALSE)

building_friction_constant[] <- round(building_friction_constant, digits = 1)

test_that("Building friction returns a SpatRaster", {
  expect_s4_class(building_friction, "SpatRaster")
})

test_that("Distance-weighted building friction increases with distance into buildings", {
  expect_true(
    max(values(building_friction), na.rm = TRUE) >
      min(values(building_friction), na.rm = TRUE)
  )
})

test_that("Constant building friction returns the expected maximum friction", {
  expect_equal(
    max(values(building_friction_constant), na.rm = TRUE),
    3.6
  )
})

test_that("Building friction is greater than the underlying friction", {
  expect_true(
    max(values(building_friction), na.rm = TRUE) > 1
  )
})

