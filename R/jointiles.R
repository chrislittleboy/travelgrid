#' Mosaic raster tiles using GDAL
#'
#' Builds a virtual raster mosaic (VRT) from all raster files in an input
#' directory using GDAL's `gdalbuildvrt`, then writes the resulting mosaic
#' to a GeoTIFF.
#'
#' The output resolution is specified explicitly, with target-aligned pixels
#' (`-tap`). A GDAL pixel function can be supplied to control how overlapping
#' input pixels are combined.
#'
#' @param inputdir Character. Directory containing the input raster tiles.
#' @param outputname Character. Name used for the intermediate VRT, input
#'   file list and output GeoTIFF.
#' @param resolution Numeric. Target pixel resolution in map units.
#' @param pixelf Character. GDAL pixel function used to combine overlapping
#'   raster pixels (e.g. `"max"`, `"min"` or `"mean"`).
#'
#' @return Writes a GeoTIFF mosaic to `./out/<outputname>.tif` and an
#'   intermediate VRT to `./vrt/<outputname>.vrt`. Returns `NULL`
#'   invisibly.
#'
#' @details
#' Also writes a text file listing the input rasters to
#' `./filelists/<outputname>.txt`.
#'
#'
#' @export
jointiles <- function(inputdir, outputname, resolution, pixelf){
  f <- list.files(inputdir, full.names = TRUE)
  dir.create("filelists", showWarnings = FALSE)
  dir.create("vrt", showWarnings = FALSE)
  writeLines(f, paste0("./filelists/", outputname, ".txt"))
  vrt_file <- file.path("./vrt", paste0(outputname, ".vrt"))

  args <- c(
    "-resolution", "user",
    "-tr", resolution, resolution,
    "-tap",
    "-pixel-function", pixelf
  )

  result <- gdal_utils(
    util = "buildvrt",
    source = f,
    destination = vrt_file,
    options = args
  )

  output <- rast(vrt_file)
  writeRaster(output, paste0("./out/", outputname, ".tif"))
}
