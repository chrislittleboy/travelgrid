## code to prepare bluespace raw data goes here

bluespace_sources <- list.files("./fulldata/bluespace", full.names = TRUE)
bluespace_sources <- bluespace_sources[which(tools::file_ext(bluespace_sources) %in% c("shp", "gdb"))]
bluespace_sources <- bluespace_sources[substr(basename(bluespace_sources), 1,5) != "lochs"]
sapply(bluespace_sources, function(x){
  bs <- vect(x)
  bs <- crop(bs, template)
  writeVector(x = bs, filename = paste0("./inst/extdata/bluespace/", tools::file_path_sans_ext(basename(x)), ".shp"), overwrite = TRUE)
})
