## code to prepare `demo` dataset goes here

las <- vect("./fulldata/Local_Authority_Boundaries_-_Scotland/pub_las.shp") # LA boundaries from NRS
las <- project(las, st_crs(27700)[[2]]) # projects to British National Grid
edinburgh <- las[las$local_auth == "City of Edinburgh",]
writeVector(x = edinburgh, filename = "./inst/extdata/edinburgh.shp", overwrite = TRUE)
