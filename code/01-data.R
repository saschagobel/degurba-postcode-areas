# ---------------------------------------------------------------------------------------
# DEGURBA POSTCODE AREAS
# Sascha Goebel
# Script for downloading and processing data
# June 2021
# ---------------------------------------------------------------------------------------


# downloads and imports -----------------------------------------------------------------
cat(underline("DOWNLOADS AND IMPORTS"),"
    './data/cntr_polygons/NUTS_RG_01M_2021_3035_LEVL_0.shp'
    './data/pop_grid/JRC_1K_POP_2018.tif'
    './data/fua_polygons/URAU_RG_01M_2018_3035_FUA.shp'
    './data/postcode_areas/PLZO_PLZ.shp'
    './data/postcode_areas/OSM_PLZ_072019.shp'
    './data/postcode_areas/codigos_postales.shp'
    './data/postcode_areas/codes_postaux_region.shp'
    './data/postcode_areas/Sectors.shp'
    ")

# exports -------------------------------------------------------------------------------
cat(underline("EXPORTS"),"
    './data/cntr_polygons/ch_cntr_polygon.shp'
    './data/cntr_polygons/de_cntr_polygon.shp'
    './data/cntr_polygons/es_cntr_polygon.shp'
    './data/cntr_polygons/fr_cntr_polygon.shp'
    './data/cntr_polygons/uk_cntr_polygon.shp'
    './data/pop_grid/ch_pop_grid.tif'
    './data/pop_grid/de_pop_grid.tif'
    './data/pop_grid/es_pop_grid.tif'
    './data/pop_grid/fr_pop_grid.tif'
    './data/pop_grid/uk_pop_grid.tif'
    './data/fua_polygons/ch_fua_polygons.shp'
    './data/fua_polygons/de_fua_polygons.shp'
    './data/fua_polygons/es_fua_polygons.shp'
    './data/fua_polygons/fr_fua_polygons.shp'
    './data/fua_polygons/uk_fua_polygons.shp'
    './data/postcode_areas/ch_postcode_polygons.shp'
    './data/postcode_areas/de_postcode_polygons.shp'
    './data/postcode_areas/es_postcode_polygons.shp'
    './data/postcode_areas/fr_postcode_polygons.shp'
    './data/postcode_areas/uk_postcode_polygons.shp'
    ")

# content -------------------------------------------------------------------------------
cat(underline("CONTENT"),"
    Line 53 - PREPARATIONS
    Line 73 - DOWNLOAD POPULATION GRID, BOUNDARY, FUNCTIONAL URBAN AREA, AND POSTCODE DATA
    Line 189 - PROCESS BOUNDARY, POPULATION GRID, FUNCTIONAL URBAN AREA, AND POSTCODE DATA
    ")


#### PREPARATIONS =======================================================================

# clear workspace -----------------------------------------------------------------------
rm(list=ls(all=TRUE))

# set working directory -----------------------------------------------------------------
setwd("degurba-postcode-areas")

# install and load packages -------------------------------------------------------------
source("./code/packages.R")
source("./code/functions.R")

# create data folder
path <- file.path("data")
if (!dir.exists(path)) {
  path %>%
    dir.create(recursive = TRUE)
}


#### DOWNLOAD POPULATION GRID, BOUNDARY, FUNCTIONAL URBAN AREA, AND POSTCODE DATA =======

# download latest (2018) GEOSTAT 1sqkm population grid ----------------------------------
path <- file.path("./data","pop_grid")
if (!dir.exists(path)) {
  path %>%
    dir.create(recursive = TRUE)
}
if (!file.exists(paste0(path, "/JRC_1K_POP_2018.tif"))) {
  download.file(url = "https://ec.europa.eu/eurostat/cache/GISCO/geodatafiles/JRC_GRID_2018.zip", 
                destfile = paste0(path, "/geostat-2018.zip"))
  unzip(zipfile = paste0(path, "/geostat-2018.zip"),
        files = "JRC_1K_POP_2018.tif",
        exdir = path)
  file.remove(paste0(path, "/geostat-2018.zip"))
}

# download latest NUTS0 country polygons ------------------------------------------------
path <- file.path("./data","cntr_polygons")
if (!dir.exists(path)) {
  path %>%
    dir.create(recursive = TRUE)
}
if (!file.exists(paste0(path, "/NUTS_RG_01M_2021_3035_LEVL_0.shp"))) {
  download.file(url = "https://gisco-services.ec.europa.eu/distribution/v2/nuts/download/ref-nuts-2021-01m.shp.zip",
                destfile = paste0(path, "/countries-2020.zip"))
  unzip(zipfile = paste0(path, "/countries-2020.zip"),
        files = "NUTS_RG_01M_2021_3035_LEVL_0.shp.zip",
        exdir = path)
  unzip(zipfile = paste0(path, "/NUTS_RG_01M_2021_3035_LEVL_0.shp.zip"),
        exdir = path) 
  file.remove(c(paste0(path,"/countries-2020.zip"), paste0(path, "/NUTS_RG_01M_2021_3035_LEVL_0.shp.zip")))
}

# download (2018) functional urban area polygons ----------------------------------------
path <- file.path("./data","fua_polygons")
if (!dir.exists(path)) {
  path %>%
    dir.create(recursive = TRUE)
}
if (!file.exists(paste0(path, "/URAU_RG_01M_2018_3035_FUA.shp"))) {
  download.file(url = "https://gisco-services.ec.europa.eu/distribution/v2/urau/download/ref-urau-2018-01m.shp.zip",
                destfile = paste0(path, "/fua-2018.zip"))
  unzip(zipfile = paste0(path, "/fua-2018.zip"),
        files = "URAU_RG_01M_2018_3035_FUA.shp.zip",
        exdir = path)
  unzip(zipfile = paste0(path, "/URAU_RG_01M_2018_3035_FUA.shp.zip"),
        exdir = path) 
  file.remove(c(paste0(path,"/fua-2018.zip"), paste0(path, "/URAU_RG_01M_2018_3035_FUA.shp.zip")))
}

# download latest available postcode area data ------------------------------------------
# switzerland
path <- file.path("./data","postcode_areas")
if (!dir.exists(path)) {
  path %>%
    dir.create(recursive = TRUE)
}
if (!file.exists(paste0(path, "/PLZO_PLZ.shp"))) {
  download.file(url = "http://data.geo.admin.ch/ch.swisstopo-vd.ortschaftenverzeichnis_plz/PLZO_SHP_LV95.zip", 
                destfile = paste0(path, "/ch_postcodes.zip"),
                mode = "wb")
  unzip(zipfile = paste0(path, "/ch_postcodes.zip"),
        files = paste0("PLZO_SHP_LV95/PLZO_PLZ.", c("dbf", "prj", "shp", "shx")),
        junkpaths = TRUE,
        exdir = path)
  file.remove(paste0(path, "/ch_postcodes.zip"))
}

# germany
if (!file.exists(paste0(path, "/OSM_PLZ_072019.shp"))) {
  download.file(url = "https://opendata.arcgis.com/api/v3/datasets/5b203df4357844c8a6715d7d411a8341_0/downloads/data?format=shp&spatialRefId=4326", 
                destfile = paste0(path, "/de_postcodes.zip"),
                mode = "wb")
  unzip(zipfile = paste0(path, "/de_postcodes.zip"),
        exdir = path)
  file.remove(paste0(path, "/de_postcodes.zip"))
}

# spain
if (!file.exists(paste0(path, "/codigos_postales.shp"))) {
  download.file(url = "https://codeload.github.com/inigoflores/ds-codigos-postales/zip/refs/heads/master", 
                destfile = paste0(path, "/es_postcodes.zip"),
                mode = "wb")
  unzip(zipfile = paste0(path, "/es_postcodes.zip"),
        files = paste0("ds-codigos-postales-master/data/codigos_postales/codigos_postales.", c("dbf", "prj", "shp", "shx")),
        junkpaths = TRUE,
        exdir = path)
  file.remove(paste0(path, "/es_postcodes.zip"))
}

# france
if (!file.exists(paste0(path, "/codes_postaux_region.shp"))) {
  download.file(url = "http://www.geoclip.fr/data/codes_postaux_V5.zip", 
                destfile = paste0(path, "/fr_postcodes.zip"),
                mode = "wb")
  unzip(zipfile = paste0(path, "/fr_postcodes.zip"),
        files = paste0("codes_postaux_region.", c("dbf", "prj", "shp", "shx")),
        junkpaths = TRUE,
        exdir = path)
  file.remove(paste0(path, "/fr_postcodes.zip"))
}

# united kingdom
if (!file.exists(paste0(path, "/Sectors.shp"))) {
  download.file(url = "https://www.opendoorlogistics.com/wp-content/uploads/Data/UK-postcode-boundaries-Jan-2015.zip",
                destfile = paste0(path, "/uk_postcodes.zip"),
                mode = "wb")
  unzip(zipfile = paste0(path, "/uk_postcodes.zip"),
        files = paste0("Distribution/Sectors.", c("dbf", "prj", "shp", "shx")),
        junkpaths = TRUE,
        exdir = path)
  file.remove(paste0(path, "/uk_postcodes.zip"))
}


#### PROCESS BOUNDARY, POPULATION GRID, FUNCTIONAL URBAN AREA, AND POSTCODE DATA ========

# import country polygons ---------------------------------------------------------------
cntr_polygon <- sf::st_read("data/cntr_polygons/NUTS_RG_01M_2021_3035_LEVL_0.shp")

# crop country polygons to europe -------------------------------------------------------
cntr_polygon_extent <- sf::st_bbox(cntr_polygon)
cntr_polygon <- cntr_polygon %>%
  sf::st_crop(xmin = cntr_polygon_extent[[1]]*-0.8, 
              xmax = cntr_polygon_extent[[3]]*0.8, 
              ymin = cntr_polygon_extent[[2]], 
              ymax = cntr_polygon_extent[[4]])

# extract country polygons for selected countries ---------------------------------------
ch_cntr_polygon <- cntr_polygon %>%
  dplyr::filter(CNTR_CODE == "CH") %>%
  dplyr::select(CNTR_CODE)
de_cntr_polygon <- cntr_polygon %>%
  dplyr::filter(CNTR_CODE == "DE") %>%
  dplyr::select(CNTR_CODE)
es_cntr_polygon <- cntr_polygon %>%
  dplyr::filter(CNTR_CODE %in% c("ES","PT")) %>%
  dplyr::select(CNTR_CODE)
fr_cntr_polygon <- cntr_polygon %>%
  dplyr::filter(CNTR_CODE == "FR") %>%
  dplyr::select(CNTR_CODE)
uk_cntr_polygon <- cntr_polygon %>%
  dplyr::filter(CNTR_CODE == "UK") %>%
  dplyr::select(CNTR_CODE)

# save country-specific polygons --------------------------------------------------------
sf::write_sf(ch_cntr_polygon, "./data/cntr_polygons/ch_cntr_polygon.shp")
sf::write_sf(de_cntr_polygon, "./data/cntr_polygons/de_cntr_polygon.shp")
sf::write_sf(es_cntr_polygon, "./data/cntr_polygons/es_cntr_polygon.shp")
sf::write_sf(fr_cntr_polygon, "./data/cntr_polygons/fr_cntr_polygon.shp")
sf::write_sf(uk_cntr_polygon, "./data/cntr_polygons/uk_cntr_polygon.shp")

# import population grid ----------------------------------------------------------------
pop_grid <- raster::raster("./data/pop_grid/JRC_1K_POP_2018.tif")
crs(pop_grid) <- "EPSG:3035"

# crop population grid to extent of selected countries ----------------------------------
ch_pop_grid <- ch_cntr_polygon %>%
  raster::crop(x = pop_grid)
de_pop_grid <- de_cntr_polygon %>%
  raster::crop(x = pop_grid)
es_pop_grid <- es_cntr_polygon %>%
  raster::crop(x = pop_grid)
fr_pop_grid <- fr_cntr_polygon %>%
  raster::crop(x = pop_grid)
uk_pop_grid <- uk_cntr_polygon %>%
  raster::crop(x = pop_grid)

# save country-specific population grids ------------------------------------------------
raster::writeRaster(x = ch_pop_grid, filename = "./data/pop_grid/ch_pop_grid.tif")
raster::writeRaster(x = de_pop_grid, filename = "./data/pop_grid/de_pop_grid.tif")
raster::writeRaster(x = es_pop_grid, filename = "./data/pop_grid/es_pop_grid.tif")
raster::writeRaster(x = fr_pop_grid, filename = "./data/pop_grid/fr_pop_grid.tif")
raster::writeRaster(x = uk_pop_grid, filename = "./data/pop_grid/uk_pop_grid.tif")

# import fua polygons -------------------------------------------------------------------
fua_polygons <- sf::st_read("data/fua_polygons/URAU_RG_01M_2018_3035_FUA.shp")

# extract polygons for selected and neighboring countries -------------------------------
ch_fua_polygons <- fua_polygons %>%
  dplyr::filter(CNTR_CODE %in% c("CH", "F", "IT", "DE", "AT", "LI")) %>%
  dplyr::select(URAU_CODE)
de_fua_polygons <- fua_polygons %>%
  dplyr::filter(CNTR_CODE %in% c("DE", "NL", "DK", "PL", "AT", "CH",
                                 "BE", "F", "LU", "CZ")) %>%
  dplyr::select(URAU_CODE)
es_fua_polygons <- fua_polygons %>%
  dplyr::filter(CNTR_CODE %in% c("ES", "F", "PT", "AD")) %>%
  dplyr::select(URAU_CODE)
fr_fua_polygons <- fua_polygons %>%
  dplyr::filter(CNTR_CODE %in% c("F", "BE", "DE", "CH",
                                 "MC", "AD", "LU", "IT", "ES")) %>%
  dplyr::select(URAU_CODE)
uk_fua_polygons <- fua_polygons %>%
  dplyr::filter(CNTR_CODE %in% c("UK", "IE")) %>%
  dplyr::select(URAU_CODE)

# save country-specific fua polygons ----------------------------------------------------
sf::write_sf(ch_fua_polygons, "./data/fua_polygons/ch_fua_polygons.shp")
sf::write_sf(de_fua_polygons, "./data/fua_polygons/de_fua_polygons.shp")
sf::write_sf(es_fua_polygons, "./data/fua_polygons/es_fua_polygons.shp")
sf::write_sf(fr_fua_polygons, "./data/fua_polygons/fr_fua_polygons.shp")
sf::write_sf(uk_fua_polygons, "./data/fua_polygons/uk_fua_polygons.shp")

# import and reproject postcode polygons ------------------------------------------------
ch_postcode_polygons <- sf::st_read("data/postcode_areas/PLZO_PLZ.shp") %>%
  sf::st_transform(3035)
de_postcode_polygons <- sf::st_read("data/postcode_areas/OSM_PLZ_072019.shp") %>%
  sf::st_transform(3035)
es_postcode_polygons <- sf::st_read("data/postcode_areas/codigos_postales.shp") %>%
  sf::st_transform(3035)
fr_postcode_polygons <- sf::st_read("data/postcode_areas/codes_postaux_region.shp") %>%
  sf::st_transform(3035)
uk_postcode_polygons <- sf::st_read("data/postcode_areas/Sectors.shp") %>%
  sf::st_transform(3035)

# crop postcode polygons to europe (where required) -------------------------------------
es_postcode_polygons <- es_postcode_polygons %>%
  sf::st_crop(es_cntr_polygon)

# combine postcode polygons (where required) --------------------------------------------
es_postcode_polygons <- es_postcode_polygons %>% 
  group_by(COD_POSTAL) %>%
  summarise(geometry = st_union(geometry))

# save postcode polygons ----------------------------------------------------------------
sf::write_sf(ch_postcode_polygons, "./data/postcode_areas/ch_postcode_polygons.shp")
sf::write_sf(de_postcode_polygons, "./data/postcode_areas/de_postcode_polygons.shp")
sf::write_sf(es_postcode_polygons, "./data/postcode_areas/es_postcode_polygons.shp")
sf::write_sf(fr_postcode_polygons, "./data/postcode_areas/fr_postcode_polygons.shp")
sf::write_sf(uk_postcode_polygons, "./data/postcode_areas/uk_postcode_polygons.shp")
