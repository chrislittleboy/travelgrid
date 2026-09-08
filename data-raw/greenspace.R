## code to prepare `greenspace` dataset goes here

gs <- vect("./fulldata/greenspace/GB_GreenspaceSite.shp") # gets os greenspace data
gs <- crop(gs, template)
writeVector(gs, "./inst/extdata/greenspace.shp")
