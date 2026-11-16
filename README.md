
<!-- README.md is generated from README.Rmd. Please edit that file -->

# travelgrid

<img src="man/figures/travelgrid_hex_sticker.png" align="right" width="150"/>

<!-- badges: start -->

[![R-CMD-check](https://github.com/chrislittleboy/travelgrid/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/chrislittleboy/travelgrid/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of travelgrid is to measure the time taken to travel somewhere
through a landscape. It is fast, scalable, and is built to handle
many-to-many least-cost travel time computation where the built
environment and topography matter. The functions in the package allow
for extracting the necessary input data: elevation maps, building
footprints, and road networks, from open public data sources. These can
be combined with any shapefile containing “destinations”. This might,
for example, be hospitals or other medical practices if you are
assessing the proximity of public health infrastructure. Or schools, for
determining school catchment areas within cities.

## Installation

You can install the development version of travelgrid like so:

``` r
remotes::install_github("chrislittleboy/travelgrid")
```

## Input data

Users can download and use data from anywhere in the world. Throughout
this explainer we illustrate the method with data specific to Edinburgh
in Scotland.

Road and building footprint data for Edinburgh downloaded directly from
Open Street Maps. We also require a Digital Elevation Model, which can
be downloaded using the *elevatr* package.

``` r
library(travelgrid)
library(terra)
#> terra 1.9.50
edinburgh <- retrieve_edinburgh()
template <- rast(edinburgh, res = 15)
dem <- get_dem(edinburgh, template)
#> Mosaicing & Projecting
#> Note: Elevation units are in meters.
osm <- get_osm(system.file("extdata", "edinburgh.shp", package = "travelgrid"))
#> The input place was matched with Scotland.
#> The chosen file was already detected in the download directory. Skip downloading.
#> Starting with the vectortranslate operations on the input file!
#> 0...10...20...30...40...50...60...70...80...90...100 - done.
#> Warning in CPL_gdalvectortranslate(source, destination, options, oo, doo, :
#> GDAL Message 1: Non closed ring detected. To avoid accepting it, set the
#> OGR_GEOMETRY_ACCEPT_UNCLOSED_RING configuration option to NO
#> Warning in CPL_gdalvectortranslate(source, destination, options, oo, doo, :
#> GDAL Message 1: Non closed ring detected. To avoid accepting it, set the
#> OGR_GEOMETRY_ACCEPT_UNCLOSED_RING configuration option to NO
#> Warning in CPL_gdalvectortranslate(source, destination, options, oo, doo, :
#> GDAL Message 1: Non closed ring detected. To avoid accepting it, set the
#> OGR_GEOMETRY_ACCEPT_UNCLOSED_RING configuration option to NO
#> Finished the vectortranslate operations on the input file!
#> Reading query `SELECT * FROM multipolygons WHERE building IS NOT NULL'
#> from data source `/home/chris/.local/share/R/osmextract/geofabrik_scotland-latest.gpkg' 
#>   using driver `GPKG'
#> Simple feature collection with 186852 features and 25 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -3.451079 ymin: 55.81914 xmax: -3.074061 ymax: 56.01379
#> Geodetic CRS:  WGS 84
#> Starting with the vectortranslate operations on the input file!
#> 0...10...20...30...40...50...60...70...80...90...100 - done.
#> Finished the vectortranslate operations on the input file!
#> Reading query `
#>     SELECT *
#>     FROM lines
#>     WHERE highway IS NOT NULL
#>   '
#> from data source `/home/chris/.local/share/R/osmextract/geofabrik_scotland-latest.gpkg' 
#>   using driver `GPKG'
#> Simple feature collection with 61973 features and 10 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: -3.490315 ymin: 55.79268 xmax: -3.055897 ymax: 56.02276
#> Geodetic CRS:  WGS 84
roads <- osm$network
buildings <- osm$buildings
```

``` r
plot(dem, main = "Elevation")
plot(edinburgh, col = NA, border = "red", add = TRUE)
```

<img src="man/figures/README-sourcedataplot-1.png" alt="" width="100%" />

``` r
plot(roads, main = "Roads")
```

<img src="man/figures/README-sourcedataplot-2.png" alt="" width="100%" />

``` r
plot(buildings, main = "Buildings")
```

<img src="man/figures/README-sourcedataplot-3.png" alt="" width="100%" />

## Built environment

Our travel time algorithm assumes that people cannot travel through
buildings, but that they might travel at a different speed if they are
on a road. The *get_built_environment* function extracts this
information from the road and building footprint data. A template grid
is created with a specified resolution, here set at 10m. Pixels with
buildings covering them are set a NA value. Pixels with a road and a
building covering them are set as a road so that travel through the
pixel is possible. Pixels with just a road are assigned a value of
*road_travel*. Pixels with neither a road or a building are assigned a
value of *off_road_travel*. Defaults set both values so that walking
speeds are determined purely by the slope and Tobler’s hiking function.

``` r
built_environment <- get_built_environment(buildings = buildings,
                                           roads = roads,
                                           template = template)

built_environment_off_road_adjustment <- get_built_environment(
                                           buildings = buildings,
                                           roads = roads,
                                           template = template,
                                           road_travel = 1,
                                           non_road_travel = 2)

plot(built_environment, maxcell = 1000000, main = "Built Environment")
```

<img src="man/figures/README-built_environment-1.png" alt="" width="100%" />

``` r
plot(built_environment_off_road_adjustment, maxcell = 1000000, main = "Built environment, with faster walking speeds on roads")
```

<img src="man/figures/README-built_environment-2.png" alt="" width="100%" />

## Grids and performance

To allow for memory safety, and parellisation, the processing is done by
taking regular grids over the environment. A *gridsize* is defined, here
it is 2.5km. The landscape is divided into regular squares of
2.5km<sup>2</sup>, each given a unique *id*.

``` r
gridsize <- 5000
grid <- make_grid(edinburgh, gridsize)
plot(grid, main = "Computation grid")
plot(edinburgh, add= TRUE)
```

<img src="man/figures/README-grid-1.png" alt="" width="100%" />

## Destinations

Destinations are defined using polygon data. Two helper functions are
included, to transform polygon input data into the required format. With
the *get_target_multisource* function, a list of files which can be read
using *terra*’s *vect* function is supplied. With the
*get_target_onesource* function, a single *SpatVector* is supplied.
These are classified spatially using the same template as the built
environment. If a pixel contains a target, it is set to -1, otherwise it
is set to 1. This is illustrated for Edinburgh using bluespace
(combining Scotland Environmental Protection Agency data on coasts,
rivers, estuaries and UK Lakes data on lochs) and greenspace (using data
supplied by the UK Ordnance Survey).

``` r

bluespace_sources <- list.files("./inst/extdata/bluespace", full.names = TRUE)
bluespace_sources <- bluespace_sources[which(tools::file_ext(bluespace_sources) == "shp")]
bluespace <- get_target_multisource(bluespace_sources, template)

greenspace_source <- vect("./inst/extdata/greenspace.shp") # gets os greenspace data
greenspace <- get_target_onesource(greenspace_source, template)

plot(bluespace, main = "Blue space")
```

<img src="man/figures/README-targets-1.png" alt="" width="100%" />

``` r
plot(greenspace, main = "Green space")
```

<img src="man/figures/README-targets-2.png" alt="" width="100%" />

## Friction

The seconds to cross a pixel are calculated using data on the the built
environment and the DEM. People are assumed to walk at a speed according
to Tobler’s hiking function. Friction values represent the number of
seconds it takes to travel 1 meter, based on the slope. These speeds are
adjusted based on the built environment.

``` r

wd <- tempdir()
writeVector(grid, paste0(wd, "/grid.shp"), overwrite = TRUE)
writeRaster(built_environment, paste0(wd, "/be.tif"), overwrite = TRUE)
writeRaster(dem, paste0(wd, "/dem.tif"), overwrite = TRUE)

friction_grid <- lapply(FUN = get_friction,
                        X = 1:nrow(grid),
                        grid_file = paste0(wd, "/grid.shp"),
                        gridsize = gridsize,
                        resolution = xres(template),
                        built_environment_file = paste0(wd, "/be.tif"),
                        dem_file = paste0(wd, "/dem.tif"),
                        dir = wd)

friction <- trim(mosaic(sprc(list.files(file.path(wd, "frictiontiles"), full.names = TRUE))))
built_environment <- resample(built_environment, friction)
writeRaster(friction, file.path(wd, "friction.tif"), overwrite = TRUE)
writeRaster(built_environment, file.path(wd, "be.tif"), overwrite = TRUE)

friction_with_buildings <- get_building_friction(
  built_environment_file = file.path(wd, "be.tif"),
  friction_file = file.path(wd, "friction.tif")
)
plot(trim(friction_with_buildings), main = "Friction with buildings")
```

<img src="man/figures/README-friction-1.png" alt="" width="100%" />

## Travel times

Travel time from any point on the surface to our targets is calculated
by combining information on targets with the friction grid. Here is a
travelgrid showing the travel time (in seconds) to green spaces and blue
spaces in Edinburgh. All areas within 15 minutes walk are plotted.

Warnings are produced whenever there is no target within a friction
grid. Grids are expanded by 50% of the grid size parameter to reduce
spatial edge effects. A grid size of 2.5km<sup>2</sup> guarantees that,
on the flat, any target within 15 minutes will be reached. For problems
where targets are sparse, and precision for long travel times is
important, users should define a larger grid size.

``` r

writeRaster(bluespace, file.path(wd, "bs.tif"), overwrite = TRUE)
writeRaster(greenspace, file.path(wd, "gs.tif"), overwrite = TRUE)
writeRaster(friction_with_buildings, file.path(wd, "fb.tif"), overwrite = TRUE)
list.files(wd)
#>  [1] "be.tif"                "bs.tif"                "dem.tif"              
#>  [4] "fb.tif"                "file1c0d911bc7579.tif" "file1c0d913abc43f.tif"
#>  [7] "file1c0d91cc73b5.tif"  "file1c0d9390529f5.tif" "file1c0d94218c664.tif"
#> [10] "file1c0d943199fd.tif"  "file1c0d946bf3a1d.tif" "file1c0d957c50ab8.tif"
#> [13] "file1c0d95dc5dfa7.tif" "file1c0d9676e0a54.tif" "file1c0d96cad028e.tif"
#> [16] "friction.tif"          "frictiontiles"         "frictiontiles_built"  
#> [19] "grid.cpg"              "grid.dbf"              "grid.prj"             
#> [22] "grid.shp"              "grid.shx"              "gs.tif"
bluespace_travel_grid <- get_travel_time(
  target_file = file.path(wd, "bs.tif"), 
  friction_file =  file.path(wd, "fb.tif"))
greenspace_travel_grid <- get_travel_time(
  target_file = file.path(wd, "gs.tif"), 
  friction_file = file.path(wd, "fb.tif"))

plot(bluespace_travel_grid, range = c(0,900), main = "Travel time to blue spaces")
```

<img src="man/figures/README-travel-1.png" alt="" width="100%" />

``` r
plot(greenspace_travel_grid, range = c(0,900), main = "Travel time to green spaces")
```

<img src="man/figures/README-travel-2.png" alt="" width="100%" />

## Usability

The package has been designed to take widely available open data, and to
produce travel grids at a high spatial resolution. Our worked example
could be used to inform planning decisions for local parks, or social
proscribing. But the code is flexible to any target of interest
(schools, hospitals, cinemas, etc.) over any area.
