## code to prepare `dem` dataset goes here

template <- rast(retrieve_edinburgh(), res = 15)
dem <- get_dem(retrieve_edinburgh(), template)
dem <- round(dem /2)
dem[dem > 255] <- 255
dem[dem < 0] <- 0
writeRaster(
  dem,
  "./inst/extdata/dem.tif",
  datatype = "INT1U",
  gdal = "COMPRESS=DEFLATE",
  overwrite = TRUE
)
