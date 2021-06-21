# ---------------------------------------------------------------------------------------
# DEGURBA POSTCODE AREAS
# Sascha Goebel
# Script for maps
# June 2021
# ---------------------------------------------------------------------------------------


# imports -------------------------------------------------------------------------------
cat(underline("IMPORTS"),"
    './data/cntr_polygons/ch_cntr_polygon.shp'
    './data/cntr_polygons/de_cntr_polygon.shp'
    './data/cntr_polygons/es_cntr_polygon.shp'
    './data/cntr_polygons/fr_cntr_polygon.shp'
    './data/cntr_polygons/uk_cntr_polygon.shp'
    './data/grid_classifications'
    './data/postcode_classifications'
    ")

# exports -------------------------------------------------------------------------------
cat(underline("EXPORTS"),"
    './maps/pop_grid_map.png'
    './maps/degurba_l1_grid_map.png'
    './maps/degurba_l1_grid_fua_map.png'
    './maps/degurba_l2_grid_map.png'
    './maps/degurba_l2_grid_fua_map.png'
    './maps/degurba_l1_postcode_map.png'
    './maps/degurba_l1_postcode_fua_map.png'
    './maps/ch_degurba_l1_postcode_map.png'
    './maps/de_degurba_l1_postcode_map.png'
    './maps/es_degurba_l1_postcode_map.png'
    './maps/fr_degurba_l1_postcode_map.png'
    './maps/uk_degurba_l1_postcode_map.png'
    './maps/ch_degurba_l1_postcode_fua_map.png'
    './maps/de_degurba_l1_postcode_fua_map.png'
    './maps/es_degurba_l1_postcode_fua_map.png'
    './maps/fr_degurba_l1_postcode_fua_map.png'
    './maps/uk_degurba_l1_postcode_fua_map.png'
    './maps/degurba_l2_postcode_map.png'
    './maps/degurba_l2_postcode_fua_map.png'
    './maps/ch_degurba_l2_postcode_map.png'
    './maps/de_degurba_l2_postcode_map.png'
    './maps/es_degurba_l2_postcode_map.png'
    './maps/fr_degurba_l2_postcode_map.png'
    './maps/uk_degurba_l2_postcode_map.png'
    './maps/ch_degurba_l2_postcode_fua_map.png'
    './maps/de_degurba_l2_postcode_fua_map.png'
    './maps/es_degurba_l2_postcode_fua_map.png'
    './maps/fr_degurba_l2_postcode_fua_map.png'
    './maps/uk_degurba_l2_postcode_fua_map.png'
    ")

# content -------------------------------------------------------------------------------
cat(underline("CONTENT"),"
    Line 65 - PREPARATIONS
    Line 83 - SPECIFY REGIONS
    Line 145 - POPULATION DENSITY GRID MAP
    Line 176 - DEGURBA LEVEL 1 GRID MAPS
    Line 238 - DEGURBA LEVEL 2 GRID MAPS
    Line 292 - DEGURBA LEVEL 1 POSTCODE MAPS
    Line 544 - DEGURBA LEVEL 2 POSTCODE MAPS
    ")


#### PREPARATIONS =======================================================================

# clear workspace -----------------------------------------------------------------------
rm(list=ls(all=TRUE))

# set working directory -----------------------------------------------------------------
setwd("degurba-postcode-areas")

# install and load packages -------------------------------------------------------------
source("./code/packages.R")
source("./code/functions.R")

# get fonts -----------------------------------------------------------------------------
# download 'new computer modern' font and convert to true type 
# font_import() # adjust path if fonts are not imported
# loadfonts(device = "win")


#### SPECIFY REGIONS ====================================================================

# import boundary polygons for countries ------------------------------------------------
ch_cntr_polygon <- sf::st_read("data/cntr_polygons/ch_cntr_polygon.shp")
de_cntr_polygon <- sf::st_read("data/cntr_polygons/de_cntr_polygon.shp")
es_cntr_polygon <- sf::st_read("data/cntr_polygons/es_cntr_polygon.shp") %>%
  dplyr::filter(CNTR_CODE == "ES")
fr_cntr_polygon <- sf::st_read("data/cntr_polygons/fr_cntr_polygon.shp")
uk_cntr_polygon <- sf::st_read("data/cntr_polygons/uk_cntr_polygon.shp")
# remove northern ireland (no postcode areas available)
uk_cntr_polygon <- st_polygon(uk_cntr_polygon$geometry[[1]][[200]]) %>%
  st_combine() %>%
  st_union %>%
  st_set_crs(value = 3035) %>%
  st_difference(uk_cntr_polygon, .)

# set location coordinates for countries and example region -----------------------------
ch_region_locations <- maps::world.cities %>% 
  filter(country.etc == "Switzerland" & pop >= 60000) %>% 
  dplyr::select(city = name, lat = lat, lng = long, pop) %>%
  st_as_sf(coords = c('lng', 'lat')) %>%
  st_set_crs(value = 4326) %>%
  st_transform(3035)
de_region_locations <- maps::world.cities %>% 
  filter(country.etc == "Germany" & pop >= 300000) %>% 
  dplyr::select(city = name, lat = lat, lng = long, pop) %>%
  st_as_sf(coords = c('lng', 'lat')) %>%
  st_set_crs(value = 4326) %>%
  st_transform(3035)
es_region_locations <- maps::world.cities %>% 
  filter(country.etc == "Spain" & pop >= 200000) %>% 
  dplyr::select(city = name, lat = lat, lng = long, pop) %>%
  st_as_sf(coords = c('lng', 'lat')) %>%
  st_set_crs(value = 4326) %>%
  st_transform(3035)
fr_region_locations <- maps::world.cities %>% 
  filter(country.etc == "France" & pop >= 150000) %>% 
  dplyr::select(city = name, lat = lat, lng = long, pop) %>%
  st_as_sf(coords = c('lng', 'lat')) %>%
  st_set_crs(value = 4326) %>%
  st_transform(3035)
uk_region_locations <- maps::world.cities %>% 
  filter(country.etc == "UK" & pop >= 300000) %>% 
  dplyr::select(city = name, lat = lat, lng = long, pop) %>%
  st_as_sf(coords = c('lng', 'lat')) %>%
  st_set_crs(value = 4326) %>%
  st_transform(3035)
de_region_locations_ex <- maps::world.cities %>% 
  filter(country.etc == "Germany" & pop >= 35000) %>% 
  dplyr::select(city = name, lat = lat, lng = long, pop) %>%
  st_as_sf(coords = c('lng', 'lat')) %>%
  st_set_crs(value = 4326) %>%
  st_transform(3035)

# specify bounding box for example region -----------------------------------------------
de_region <- sf::st_bbox(de_cntr_polygon)
de_region <- c(de_region[1]+110000, 
               de_region[2]+200000, 
               de_region[3]-390000, 
               de_region[4]-590000)


#### POPULATION DENSITY GRID MAP ========================================================

# import population grid and crop to country boundary -----------------------------------
de_pop_grid <- readRDS("./data/grid_classifications")[[2]]$pop1sqkm
crs(de_pop_grid) <- "EPSG:3035"
de_pop_grid <- de_pop_grid %>%
  raster::crop(de_cntr_polygon) %>%
  raster::mask(de_cntr_polygon)

# build map for example region ----------------------------------------------------------
pop_grid_map <- tm_shape(de_cntr_polygon, bbox = de_region) +
  tm_borders(lwd = 0.2) +
  tm_shape(de_pop_grid, raster.downsample = FALSE) +
  tm_raster(breaks = c(1, 150, 300, 1500, 5000, 35000), title = "Population density \n(1 sq km)",
            palette = "YlOrRd") +
  tm_shape(de_cntr_polygon, bbox = de_region) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(de_region_locations_ex) +
  tm_dots(col = "black", alpha = 0.5, size = 0.25) +
  tm_text(text = "city", col = "black", fontface = "bold", size = 1.2, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("LEFT", "TOP"), 
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            legend.title.fontface = "bold",
            legend.text.size = 1,
            legend.title.size = 1.5,
            legend.bg.color = "white",
            legend.bg.alpha = 0.75)
tmap_save(tm = pop_grid_map, filename = "./maps/pop_grid_map.png", dpi = 300)


#### DEGURBA LEVEL 1 GRID MAPS ==========================================================

# import grid-level classification and fua and crop to boundary -------------------------
de_degurba_l1_grid <- readRDS("./data/grid_classifications")[[2]]$classification_l1
crs(de_degurba_l1_grid) <- "EPSG:3035"
de_degurba_l1_grid <- de_degurba_l1_grid %>%
  raster::crop(de_cntr_polygon) %>%
  raster::mask(de_cntr_polygon)
de_degurba_fua_grid <- readRDS("./data/grid_classifications")[[2]]$fua
crs(de_degurba_fua_grid) <- "EPSG:3035"
de_degurba_fua_grid <- de_degurba_fua_grid %>%
  raster::crop(de_cntr_polygon) %>%
  raster::mask(de_cntr_polygon)
de_degurba_fua_grid <- ratify(de_degurba_fua_grid$fua)
values(de_degurba_fua_grid) <- ifelse(de_degurba_fua_grid$fua[] == 1, "TRUE",
                                      NA) %>%
  factor(levels = c("TRUE"))

# build map for example region without functional urban areas ---------------------------
degurba_l1_grid_map <- tm_shape(de_cntr_polygon, bbox = de_region) +
  tm_borders(lwd = 0.2) +
  tm_shape(de_degurba_l1_grid$classification_l1, raster.downsample = FALSE) +
  tm_raster(title = "DEGURBA\nLevel 1", palette = c("#ee0300", "#ffae00", "#72b872")) +
  tm_shape(de_cntr_polygon, bbox = de_region) +
  tm_borders(lwd = 0.2) +
  tm_shape(de_region_locations_ex) +
  tm_dots(col = "black", alpha = 0.5, size = 0.25) +
  tm_text(text = "city", col = "black", fontface = "bold", size = 1.2, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("LEFT", "TOP"),
            legend.title.fontface = "bold",
            legend.text.size = 1,
            legend.title.size = 1.5,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            legend.bg.color = "white",
            legend.bg.alpha = 0.75)
tmap_save(tm = degurba_l1_grid_map, filename = "./maps/degurba_l1_grid_map.png", dpi = 300)

# build map for example region with functional urban areas ------------------------------
degurba_l1_grid_fua_map <- tm_shape(de_cntr_polygon, bbox = de_region) +
  tm_borders(lwd = 0.2) +
  tm_shape(de_degurba_l1_grid$classification_l1, raster.downsample = FALSE) +
  tm_raster(title = "DEGURBA\nLevel 1", palette = c("#ee0300", "#ffae00", "#72b872")) +
  tm_shape(de_degurba_fua_grid$fua, raster.downsample = FALSE) +
  tm_raster(palette = "red", colorNA = NULL, showNA = FALSE, alpha = 0.25,
            title = "Functional urban area") +
  tm_shape(de_cntr_polygon, bbox = de_region) +
  tm_borders(lwd = 0.2) +
  tm_shape(de_region_locations_ex) +
  tm_dots(col = "black", alpha = 0.5, size = 0.25) +
  tm_text(text = "city", col = "black", fontface = "bold", size = 1.2, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("LEFT", "TOP"),
            legend.title.fontface = "bold",
            legend.text.size = 1,
            legend.title.size = 1.5,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            legend.bg.color = "white",
            legend.bg.alpha = 0.75)
tmap_save(tm = degurba_l1_grid_fua_map, filename = "./maps/degurba_l1_grid_fua_map.png", dpi = 300)


#### DEGURBA LEVEL 2 GRID MAPS ==========================================================

# import grid-level classification and fua grid and crop to boundary --------------------
de_degurba_l2_grid <- readRDS("./data/grid_classifications")[[2]]$classification_l2
crs(de_degurba_l2_grid) <- "EPSG:3035"
de_degurba_l2_grid <- de_degurba_l2_grid %>%
  raster::crop(de_cntr_polygon) %>%
  raster::mask(de_cntr_polygon)

# build map for example region without functional urban areas ---------------------------
degurba_l2_grid_map <- tm_shape(de_cntr_polygon, bbox = de_region) +
  tm_borders(lwd = 0.2) +
  tm_shape(de_degurba_l2_grid$classification_l2, raster.downsample = FALSE) +
  tm_raster(title = "DEGURBA\nLevel 2", palette = c("#ee0300", "#632f2f", "#a1705a", "#ffae00", "#356335", "#72b872", "#c6deb1")) +
  tm_shape(de_cntr_polygon, bbox = de_region) +
  tm_borders(lwd = 0.2) +
  tm_shape(de_region_locations_ex) +
  tm_dots(col = "black", alpha = 0.5, size = 0.25) +
  tm_text(text = "city", col = "black", fontface = "bold", size = 1.2, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("LEFT", "TOP"),
            legend.title.fontface = "bold",
            legend.text.size = 1,
            legend.title.size = 1.5,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            legend.bg.color = "white",
            legend.bg.alpha = 0.75)
tmap_save(tm = degurba_l2_grid_map, filename = "./maps/degurba_l2_grid_map.png", dpi = 300)

# build map for example region with functional urban areas ------------------------------
degurba_l2_grid_fua_map <- tm_shape(de_cntr_polygon, bbox = de_region) +
  tm_borders(lwd = 0.2) +
  tm_shape(de_degurba_l2_grid$classification_l2, raster.downsample = FALSE) +
  tm_raster(title = "DEGURBA\nLevel 2", palette = c("#ee0300", "#632f2f", "#a1705a", "#ffae00", "#356335", "#72b872", "#c6deb1")) +
  tm_shape(de_degurba_fua_grid$fua, raster.downsample = FALSE) +
  tm_raster(palette = "red", colorNA = NULL, showNA = FALSE, alpha = 0.25,
            title = "Functional urban area") +
  tm_shape(de_cntr_polygon, bbox = de_region) +
  tm_borders(lwd = 0.2) +
  tm_shape(de_region_locations_ex) +
  tm_dots(col = "black", alpha = 0.5, size = 0.25) +
  tm_text(text = "city", col = "black", fontface = "bold", size = 1.2, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("LEFT", "TOP"),
            legend.title.fontface = "bold",
            legend.text.size = 1,
            legend.title.size = 1.5,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            legend.bg.color = "white",
            legend.bg.alpha = 0.75)
degurba_l2_grid_fua_map
tmap_save(tm = degurba_l2_grid_fua_map, filename = "./maps/degurba_l2_grid_fua_map.png", dpi = 300)


#### DEGURBA LEVEL 1 POSTCODE MAPS ======================================================

# import postcode-level classification for countries ------------------------------------
ch_degurba_postcode <- readRDS("./data/postcode_classifications")[[1]] %>%
  sf::st_as_sf() %>%
  dplyr::select(degurba_l1, degurba_l2, fua)
de_degurba_postcode <- readRDS("./data/postcode_classifications")[[2]] %>%
  sf::st_as_sf() %>%
  dplyr::select(degurba_l1, degurba_l2, fua)
es_degurba_postcode <- readRDS("./data/postcode_classifications")[[3]] %>%
  sf::st_as_sf() %>%
  dplyr::select(degurba_l1, degurba_l2, fua)
fr_degurba_postcode <- readRDS("./data/postcode_classifications")[[4]] %>%
  sf::st_as_sf() %>%
  dplyr::select(degurba_l1, degurba_l2, fua)
uk_degurba_postcode <- readRDS("./data/postcode_classifications")[[5]] %>%
  sf::st_as_sf() %>%
  dplyr::select(degurba_l1, degurba_l2, fua)

# build map for example region without functional urban areas ---------------------------
degurba_l1_postcode_map <- tm_shape(de_degurba_postcode, bbox = de_region) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l1", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 1",
          palette = c("#ee0300", "#ffae00", "#72b872")) +
  tm_shape(de_cntr_polygon) +
  tm_borders(lwd = 0.2) +
  tm_shape(de_region_locations_ex) +
  tm_dots(col = "black", alpha = 0.5, size = 0.25) +
  tm_text(text = "city", col = "black", fontface = "bold", size = 1.2, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("LEFT", "TOP"),
            legend.title.fontface = "bold",
            legend.text.size = 1,
            legend.title.size = 1.5,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            legend.bg.color = "white",
            legend.bg.alpha = 0.75)
tmap_save(tm = degurba_l1_postcode_map, filename = "./maps/degurba_l1_postcode_map.png", dpi = 300)

# build map for example region with functional urban areas ------------------------------
degurba_l1_postcode_fua_map <- tm_shape(de_degurba_postcode, bbox = de_region) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l1", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 1",
          palette = c("#ee0300", "#ffae00", "#72b872")) +
  tm_shape(de_degurba_postcode) +
  tm_fill(col = "fua", showNA = FALSE, colorNA = NULL, title = "Functional urban area",
          palette = "red", labels = "TRUE", alpha = 0.25) +
  tm_shape(de_cntr_polygon) +
  tm_borders(lwd = 0.2) +
  tm_shape(de_region_locations_ex) +
  tm_dots(col = "black", alpha = 0.5, size = 0.25) +
  tm_text(text = "city",  col = "black", fontface = "bold", size = 1.2, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("LEFT", "TOP"),
            legend.title.fontface = "bold",
            legend.text.size = 1,
            legend.title.size = 1.5,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            legend.bg.color = "white",
            legend.bg.alpha = 0.75)
tmap_save(tm = degurba_l1_postcode_fua_map, filename = "./maps/degurba_l1_postcode_fua_map.png", dpi = 300)

# build map for all countries without functional urban areas ----------------------------
ch_degurba_l1_postcode_map <- tm_shape(ch_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l1", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 1",
          palette = c("#ee0300", "#ffae00", "#72b872")) +
  tm_shape(ch_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(ch_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "top"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = ch_degurba_l1_postcode_map, filename = "./maps/ch_degurba_l1_postcode_map.png", dpi = 300)

de_degurba_l1_postcode_map <- tm_shape(de_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l1", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 1",
          palette = c("#ee0300", "#ffae00", "#72b872")) +
  tm_shape(de_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(de_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "bottom"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = de_degurba_l1_postcode_map, filename = "./maps/de_degurba_l1_postcode_map.png", dpi = 300)

es_degurba_l1_postcode_map <- tm_shape(es_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l1", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 1",
          palette = c("#ee0300", "#ffae00", "#72b872")) +
  tm_shape(es_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(es_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("right", "bottom"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = es_degurba_l1_postcode_map, filename = "./maps/es_degurba_l1_postcode_map.png", dpi = 300)

fr_degurba_l1_postcode_map <- tm_shape(fr_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l1", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 1",
          palette = c("#ee0300", "#ffae00", "#72b872")) +
  tm_shape(fr_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(fr_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "bottom"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = fr_degurba_l1_postcode_map, filename = "./maps/fr_degurba_l1_postcode_map.png", dpi = 300)

uk_degurba_l1_postcode_map <- tm_shape(uk_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l1", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 1",
          palette = c("#ee0300", "#ffae00", "#72b872")) +
  tm_shape(uk_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(uk_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, xmod = -0.5, ymod = 0.6, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "top"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            legend.width = 1,
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = uk_degurba_l1_postcode_map, filename = "./maps/uk_degurba_l1_postcode_map.png", dpi = 300)

# build map for all countries with functional urban areas -------------------------------
ch_degurba_l1_postcode_fua_map <- tm_shape(ch_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l1", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 1",
          palette = c("#ee0300", "#ffae00", "#72b872")) +
  tm_shape(ch_degurba_postcode) +
  tm_fill(col = "fua", showNA = FALSE, colorNA = NULL, title = "Functional urban area",
          palette = "red", labels = "TRUE", alpha = 0.25) +
  tm_shape(ch_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(ch_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "top"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = ch_degurba_l1_postcode_fua_map, filename = "./maps/ch_degurba_l1_postcode_fua_map.png", dpi = 300)

de_degurba_l1_postcode_fua_map <- tm_shape(de_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l1", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 1",
          palette = c("#ee0300", "#ffae00", "#72b872")) +
  tm_shape(de_degurba_postcode) +
  tm_fill(col = "fua", showNA = FALSE, colorNA = NULL, title = "Functional urban area",
          palette = "red", labels = "TRUE", alpha = 0.25) +
  tm_shape(de_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(de_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "bottom"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = de_degurba_l1_postcode_fua_map, filename = "./maps/de_degurba_l1_postcode_fua_map.png", dpi = 300)

es_degurba_l1_postcode_fua_map <- tm_shape(es_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l1", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 1",
          palette = c("#ee0300", "#ffae00", "#72b872")) +
  tm_shape(es_degurba_postcode) +
  tm_fill(col = "fua", showNA = FALSE, colorNA = NULL, title = "Functional urban area",
          palette = "red", labels = "TRUE", alpha = 0.25) +
  tm_shape(es_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(es_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("right", "bottom"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = es_degurba_l1_postcode_fua_map, filename = "./maps/es_degurba_l1_postcode_fua_map.png", dpi = 300)

fr_degurba_l1_postcode_fua_map <- tm_shape(fr_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l1", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 1",
          palette = c("#ee0300", "#ffae00", "#72b872")) +
  tm_shape(fr_degurba_postcode) +
  tm_fill(col = "fua", showNA = FALSE, colorNA = NULL, title = "Functional urban area",
          palette = "red", labels = "TRUE", alpha = 0.25) +
  tm_shape(fr_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(fr_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "bottom"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = fr_degurba_l1_postcode_fua_map, filename = "./maps/fr_degurba_l1_postcode_fua_map.png", dpi = 300)

uk_degurba_l1_postcode_fua_map <- tm_shape(uk_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l1", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 1",
          palette = c("#ee0300", "#ffae00", "#72b872")) +
  tm_shape(uk_degurba_postcode) +
  tm_fill(col = "fua", showNA = FALSE, colorNA = NULL, title = "Functional urban area",
          palette = "red", labels = "TRUE", alpha = 0.25) +
  tm_shape(uk_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(uk_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, xmod = -0.5, ymod = 0.6, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "top"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            legend.width = 1,
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = uk_degurba_l1_postcode_fua_map, filename = "./maps/uk_degurba_l1_postcode_fua_map.png", dpi = 300)


#### DEGURBA LEVEL 2 POSTCODE MAP =======================================================

# build map for example region without functional urban areas ---------------------------
degurba_l2_postcode_map <- tm_shape(de_degurba_postcode, bbox = de_region) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l2", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 2",
          palette = c("#ee0300", "#632f2f", "#a1705a", "#ffae00", "#356335", "#72b872", "#c6deb1")) +
  tm_shape(de_cntr_polygon) +
  tm_borders(lwd = 0.2) +
  tm_shape(de_region_locations_ex) +
  tm_dots(col = "black", alpha = 0.5, size = 0.25) +
  tm_text(text = "city", col = "black", fontface = "bold", size = 1.2, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("LEFT", "TOP"),
            legend.title.fontface = "bold",
            legend.text.size = 1,
            legend.title.size = 1.5,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            legend.bg.color = "white",
            legend.bg.alpha = 0.75)
tmap_save(tm = degurba_l2_postcode_map, filename = "./maps/degurba_l2_postcode_map.png", dpi = 300)

# build map for example region with functional urban areas ------------------------------
degurba_l2_postcode_fua_map <- tm_shape(de_degurba_postcode, bbox = de_region) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l2", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 2",
          palette = c("#ee0300", "#632f2f", "#a1705a", "#ffae00", "#356335", "#72b872", "#c6deb1")) +
  tm_shape(de_degurba_postcode) +
  tm_fill(col = "fua", showNA = FALSE, colorNA = NULL, title = "Functional urban area",
          palette = "red", labels = "TRUE", alpha = 0.25) +
  tm_shape(de_cntr_polygon) +
  tm_borders(lwd = 0.2) +
  tm_shape(de_region_locations_ex) +
  tm_dots(col = "black", alpha = 0.5, size = 0.25) +
  tm_text(text = "city", col = "black", fontface = "bold", size = 1.2, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("LEFT", "TOP"),
            legend.title.fontface = "bold",
            legend.text.size = 1,
            legend.title.size = 1.5,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            legend.bg.color = "white",
            legend.bg.alpha = 0.75)
tmap_save(tm = degurba_l2_postcode_fua_map, filename = "./maps/degurba_l2_postcode_fua_map.png", dpi = 300)

# build map for all countries without functional urban areas ----------------------------
ch_degurba_l2_postcode_map <- tm_shape(ch_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l2", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 2",
          palette = c("#ee0300", "#632f2f", "#a1705a", "#ffae00", "#356335", "#72b872", "#c6deb1")) +
  tm_shape(ch_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(ch_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "top"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = ch_degurba_l2_postcode_map, filename = "./maps/ch_degurba_l2_postcode_map.png", dpi = 300)

de_degurba_l2_postcode_map <- tm_shape(de_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l2", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 2",
          palette = c("#ee0300", "#632f2f", "#a1705a", "#ffae00", "#356335", "#72b872", "#c6deb1")) +
  tm_shape(de_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(de_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "bottom"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = de_degurba_l2_postcode_map, filename = "./maps/de_degurba_l2_postcode_map.png", dpi = 300)

es_degurba_l2_postcode_map <- tm_shape(es_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l2", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 2",
          palette = c("#ee0300", "#632f2f", "#a1705a", "#ffae00", "#356335", "#72b872", "#c6deb1")) +
  tm_shape(es_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(es_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("right", "bottom"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = es_degurba_l2_postcode_map, filename = "./maps/es_degurba_l2_postcode_map.png", dpi = 300)

fr_degurba_l2_postcode_map <- tm_shape(fr_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l2", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 2",
          palette = c("#ee0300", "#632f2f", "#a1705a", "#ffae00", "#356335", "#72b872", "#c6deb1")) +
  tm_shape(fr_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(fr_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "bottom"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = fr_degurba_l2_postcode_map, filename = "./maps/fr_degurba_l2_postcode_map.png", dpi = 300)

uk_degurba_l2_postcode_map <- tm_shape(uk_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l2", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 2",
          palette = c("#ee0300", "#632f2f", "#a1705a", "#ffae00", "#356335", "#72b872", "#c6deb1")) +
  tm_shape(uk_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(uk_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, xmod = -0.5, ymod = 0.6, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "top"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            legend.width = 1,
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = uk_degurba_l2_postcode_map, filename = "./maps/uk_degurba_l2_postcode_map.png", dpi = 300)

# build map for all countries with functional urban areas -------------------------------
ch_degurba_l2_postcode_fua_map <- tm_shape(ch_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l2", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 2",
          palette = c("#ee0300", "#632f2f", "#a1705a", "#ffae00", "#356335", "#72b872", "#c6deb1")) +
  tm_shape(ch_degurba_postcode) +
  tm_fill(col = "fua", showNA = FALSE, colorNA = NULL, title = "Functional urban area",
          palette = "red", labels = "TRUE", alpha = 0.25) +
  tm_shape(ch_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(ch_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "top"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = ch_degurba_l2_postcode_fua_map, filename = "./maps/ch_degurba_l2_postcode_fua_map.png", dpi = 300)

de_degurba_l2_postcode_fua_map <- tm_shape(de_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l2", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 2",
          palette = c("#ee0300", "#632f2f", "#a1705a", "#ffae00", "#356335", "#72b872", "#c6deb1")) +
  tm_shape(de_degurba_postcode) +
  tm_fill(col = "fua", showNA = FALSE, colorNA = NULL, title = "Functional urban area",
          palette = "red", labels = "TRUE", alpha = 0.25) +
  tm_shape(de_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(de_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "bottom"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = de_degurba_l2_postcode_fua_map, filename = "./maps/de_degurba_l2_postcode_fua_map.png", dpi = 300)

es_degurba_l2_postcode_fua_map <- tm_shape(es_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l2", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 2",
          palette = c("#ee0300", "#632f2f", "#a1705a", "#ffae00", "#356335", "#72b872", "#c6deb1")) +
  tm_shape(es_degurba_postcode) +
  tm_fill(col = "fua", showNA = FALSE, colorNA = NULL, title = "Functional urban area",
          palette = "red", labels = "TRUE", alpha = 0.25) +
  tm_shape(es_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(es_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("right", "bottom"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = es_degurba_l2_postcode_fua_map, filename = "./maps/es_degurba_l2_postcode_fua_map.png", dpi = 300)

fr_degurba_l2_postcode_fua_map <- tm_shape(fr_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l2", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 2",
          palette = c("#ee0300", "#632f2f", "#a1705a", "#ffae00", "#356335", "#72b872", "#c6deb1")) +
  tm_shape(fr_degurba_postcode) +
  tm_fill(col = "fua", showNA = FALSE, colorNA = NULL, title = "Functional urban area",
          palette = "red", labels = "TRUE", alpha = 0.25) +
  tm_shape(fr_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(fr_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, auto.placement = TRUE, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "bottom"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = fr_degurba_l2_postcode_fua_map, filename = "./maps/fr_degurba_l2_postcode_fua_map.png", dpi = 300)

uk_degurba_l2_postcode_fua_map <- tm_shape(uk_degurba_postcode) +
  tm_borders(lwd = 0.2) +
  tm_fill(col = "degurba_l2", showNA = FALSE, colorNA = NULL, title = "DEGURBA\nLevel 2",
          palette = c("#ee0300", "#632f2f", "#a1705a", "#ffae00", "#356335", "#72b872", "#c6deb1")) +
  tm_shape(uk_degurba_postcode) +
  tm_fill(col = "fua", showNA = FALSE, colorNA = NULL, title = "Functional urban area",
          palette = "red", labels = "TRUE", alpha = 0.25) +
  tm_shape(uk_cntr_polygon) +
  tm_borders(lwd = 0.2, col = "black") +
  tm_shape(uk_region_locations) +
  tm_dots(col = "black", alpha = 0.25, size = 0.25) +
  tm_text(text = "city", fontface = "bold",col = "white", size = 0.8, xmod = -0.5, ymod = 0.6, fontfamily = "NewComputerModern10") +
  tm_layout(legend.position = c("left", "top"),
            legend.text.size = 0.8,
            legend.title.fontfamily = "NewComputerModern10",
            legend.text.fontfamily = "NewComputerModern10",
            legend.width = 1,
            inner.margins = c(0.05, 0.05, 0.05, 0.05),
            bg.color = "gray")
tmap_save(tm = uk_degurba_l2_postcode_fua_map, filename = "./maps/uk_degurba_l2_postcode_fua_map.png", dpi = 300)
