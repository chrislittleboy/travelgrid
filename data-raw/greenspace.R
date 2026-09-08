# code to prepare the `greenspace` dataset
# data is released from the Ordnance Survey under Open Government License


gs <- vect("./fulldata/greenspace/GB_GreenspaceSite.shp") # gets os greenspace data
gs <- crop(gs, template)
writeVector(gs, "./inst/extdata/greenspace.shp")
