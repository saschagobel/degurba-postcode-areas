# ---------------------------------------------------------------------------------------
# DEGURBA POSTCODE AREAS
# Sascha Göbel
# Script for applying degurba to grid cells and postcode areas
# June 2021
# ---------------------------------------------------------------------------------------


# imports -------------------------------------------------------------------------------
cat(underline("IMPORTS"),"
    ''
    ")

# exports -------------------------------------------------------------------------------
cat(underline("EXPORTS"),"
    ''
    ")

# content -------------------------------------------------------------------------------
cat(underline("CONTENT"),"
  PREPARATIONS
  CLASSIFY GRID CELLS
  CLASSIFY POSTCODE AREAS
    ")


#### PREPARATIONS =======================================================================

# clear workspace -----------------------------------------------------------------------
rm(list=ls(all=TRUE))

# set working directory -----------------------------------------------------------------
setwd("D://projects/rude/")

# install and load packages -------------------------------------------------------------
source("./code/packages.R")
source("./code/functions.R")



#### CLASSIFY GRID CELLS ================================================================

# import country-specific population grids ----------------------------------------------
pop_grids <- list.files(path = "./data/pop_grid/", 
                        pattern = "pop_grid.tif", 
                        full.names = TRUE) %>%
  purrr::map(raster::raster)

# get grid classification for degurba level 1 and 2 -------------------------------------
grid_classifications <- pop_grids %>%
  purrr::map(get_grid_classification_l1) %>%
  purrr::map(get_grid_classification_l2)

# import country-specific functional urban area polygons --------------------------------
fua_polygons <- list.files(path = "./data/fua_polygons/", 
                        pattern = "fua_polygons.shp", 
                        full.names = TRUE) %>%
  purrr::map(sf::st_read)

# get functional urban areas and append to classification -------------------------------
grid_classifications <- grid_classifications %>%
  purrr::map2(.y = fua_polygons, .f = get_fua) %>%
  purrr::map2(.x = grid_classifications, .f = raster::addLayer)

# save grid classifications -------------------------------------------------------------
path <- file.path("./data","grid_classifications")
if (!dir.exists(path)) {
  path %>%
    dir.create(recursive = TRUE)
}
file_names <- paste0(c("ch", "de", "es", "fr", "uk"), "_grid_classifications.grd")
if (any(!file.exists(paste0(path, "/", file_names)))) {
  grid_classifications %>%
    purrr::map2(.y = paste0(path, "/", file_names),
                .f = raster::writeRaster)
}


#### CLASSIFY POSTCODE AREAS ============================================================

# import country-specific postcode area polygons ----------------------------------------
postcode_polygons <- list.files(path = "./data/postcode_areas/", 
                           pattern = "postcode_polygons.shp", 
                           full.names = TRUE) %>%
  purrr::map(sf::st_read)

# get postcode classification for degurba level 1 and 2 ---------------------------------
postcode_classifications <- grid_classifications %>%
  purrr::map2(.y = postcode_polygons, .f = get_spatial_classification_l1, fua = TRUE) %>%
  mapply(FUN = get_spatial_classification_l2, grid_classification = grid_classifications,
         polygons = postcode_polygons, spatial_classification_l1 = ., SIMPLIFY = FALSE) %>%
  purrr::map2(.y = postcode_polygons, .f = cbind)

# save postcode classifications ---------------------------------------------------------
path <- file.path("./data","postcode_classifications")
if (!dir.exists(path)) {
  path %>%
    dir.create(recursive = TRUE)
}
file_names <- paste0(c("ch", "de", "es", "fr", "uk"), "_postcode_classifications")
if (any(!file.exists(paste0(path, "/", file_names)))) {
  postcode_classifications %>%
    purrr::map2(.y = paste0(path, "/", file_names),
                .f = saveRDS)
}

# extract classified postcode lists -----------------------------------------------------
ch_postcode_degurba <- postcode_classifications[[1]] %>%
  dplyr::select(degurba_l1:fua_metro, postcode = PLZ)
de_postcode_degurba <- postcode_classifications[[2]] %>%
  dplyr::select(degurba_l1:fua_metro, postcode = plz)
es_postcode_degurba <- postcode_classifications[[3]] %>%
  dplyr::select(degurba_l1:fua_metro, postcode = COD_POSTAL)
fr_postcode_degurba <- postcode_classifications[[4]] %>%
  dplyr::select(degurba_l1:fua_metro, postcode = ID)
uk_postcode_degurba <- postcode_classifications[[5]] %>%
  dplyr::select(degurba_l1:fua_metro, postcode = name)

# save classified postcode lists --------------------------------------------------------
path <- file.path("./data","postcode_degurba_lists")
if (!dir.exists(path)) {
  path %>%
    dir.create(recursive = TRUE)
}
saveRDS(ch_postcode_degurba, paste0(path, "/", "ch_postcode_degurba"))
saveRDS(de_postcode_degurba, paste0(path, "/", "de_postcode_degurba"))
saveRDS(es_postcode_degurba, paste0(path, "/", "es_postcode_degurba"))
saveRDS(fr_postcode_degurba, paste0(path, "/", "fr_postcode_degurba"))
saveRDS(uk_postcode_degurba, paste0(path, "/", "uk_postcode_degurba"))
