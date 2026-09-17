# code to prepare bluespace raw data goes here
# data is from SEPA, and is released under an open government license

bluespace_sources <- list.files("/home/chris/Documents/software/travelgrid/fulldata/bluespace", full.names = TRUE)
bluespace_sources <- bluespace_sources[which(tools::file_ext(bluespace_sources) == "gdb")]
template <- retrieve_dem()
sapply(bluespace_sources, function(x){
  bs <- vect(x)
  bs <- crop(bs, template)
  writeVector(x = bs, filename = paste0("./inst/extdata/bluespace/", tools::file_path_sans_ext(basename(x)), ".shp"), overwrite = TRUE)
})
