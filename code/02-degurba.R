# ---------------------------------------------------------------------------------------
# DEGURBA POSTCODE AREAS
# Sascha Goebel
# Script for applying degurba to grid cells and postcode areas
# June 2021
# ---------------------------------------------------------------------------------------


# imports -------------------------------------------------------------------------------
cat(underline("IMPORTS"),"
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

# exports -------------------------------------------------------------------------------
cat(underline("EXPORTS"),"
    './data/grid_classifications'
    './data/postcode_classifications'
    './data/postcode_degurba_lists/ch_postcode_degurba'
    './data/postcode_degurba_lists/de_postcode_degurba'
    './data/postcode_degurba_lists/es_postcode_degurba'
    './data/postcode_degurba_lists/fr_postcode_degurba'
    './data/postcode_degurba_lists/uk_postcode_degurba'
    ")

# content -------------------------------------------------------------------------------
cat(underline("CONTENT"),"
    Line 47 - PREPARATIONS
    Line 60 - CLASSIFY GRID CELLS
    Line 88 - CLASSIFY POSTCODE AREAS
    ")


#### PREPARATIONS =======================================================================

# clear workspace -----------------------------------------------------------------------
rm(list=ls(all=TRUE))

# set working directory -----------------------------------------------------------------
setwd("degurba-postcode-areas")

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
saveRDS(grid_classifications, "./data/grid_classifications")


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
saveRDS(postcode_classifications, "./data/postcode_classifications")

# extract classified postcode lists -----------------------------------------------------
ch_postcode_degurba <- postcode_classifications[[1]] %>%
  dplyr::select(degurba_l1:fua_metro, postcode = PLZ, supplement = ZUSZIFF)
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
