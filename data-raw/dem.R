## code to prepare `dem` dataset goes here

template <- rast(retrieve_edinburgh(), res = 15)
dem <- get_dem(retrieve_edinburgh(), template)
dem <- writeRaster(dem, "./inst/extdata/dem.tif")
