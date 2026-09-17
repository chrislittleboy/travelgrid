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
aoi <- vect(aoi) |> set.crs("epsg:3857")
grid <- make_grid(aoi, gridsize)

friction_grid <- lapply(FUN = get_friction,
                        X = 1:nrow(grid),
                        grid = grid,
                        gridsize = gridsize,
                        resolution = xres(template),
                        built_environment = built_environment,
                        dem = dem)

friction <- trim(mosaic(sprc(friction_grid)))
res(friction) <- rep(round(res(friction)[[1]]),2)
built_environment <- resample(built_environment, friction)

building_friction <- get_building_friction(
  built_environment,
  friction
)
building_friction_constant <- get_building_friction(
  built_environment,
  friction,
  distance_weighted = FALSE
)
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
