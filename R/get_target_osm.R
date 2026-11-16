get_target_osm <- function(osm, template){
  r <- rasterize(osm$amenity, template, field = -1, background = 1)
  return(r)
}
