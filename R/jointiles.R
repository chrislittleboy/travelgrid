#' @export
jointiles <- function(inputdir, outputname, resolution, pixelf){
  f <- list.files(inputdir, full.names = TRUE)
  writeLines(f, paste0("./filelists/", outputname, ".txt"))
  vrt_file <- file.path("./vrt", paste0(outputname, ".vrt"))
  args <- c(
    "-overwrite",
    "-resolution", "user",
    "-tr", resolution, resolution,
    "-tap",
    "-pixel-function", pixelf,
    "-input_file_list", paste0("./filelists/", outputname, ".txt"),
    vrt_file
  )
  result <- system2("gdalbuildvrt", args = args)
  output <- rast(vrt_file)
  writeRaster(output, paste0("./out/", outputname, ".tif"))
}
