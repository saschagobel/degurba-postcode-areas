# ---------------------------------------------------------------------------------------
# DEGURBA POSTCODE AREAS
# Sascha Göbel
# Script for functions
# June 2021
# ---------------------------------------------------------------------------------------


# content -------------------------------------------------------------------------------
cat(underline("FUNCTIONS"),"
  drop_clusters
  get_adjacent_cells
  get_contiguous_cells
  majority_rule
  get_grid_classification_l1
  get_grid_classification_l2
  get_fua
  get_spatial_classification_l1
  get_spatial_classification_l2
  ")


#### drop_clusters ======================================================================

drop_clusters <- function(raster_layer_cluster, raster_layer_condition) {
  clusters <- raster::values(raster_layer_cluster)[which(raster_layer_condition[] == 1)] %>%
    unique()
  raster::values(raster_layer_cluster)[which(raster_layer_cluster[] %in% clusters)] <- NA
  return(raster_layer_cluster)
}


#### get_adjacent_cells =================================================================

get_adjacent_cells <- function(raster_layer_cluster, adjacency_direction) {
  # initialize layer
  raster_layer_cluster$adjacent_cells <- raster_layer_cluster %>%
    raster::setValues(NA)

  # find cells adjacent to cluster
  raster::values(raster_layer_cluster[[1]])[which(raster_layer_cluster[[1]][] == 0)] <- NA
  adjacent_cells <- raster::adjacent(x = raster_layer_cluster[[1]], 
                                     cells = which(!is.na(raster_layer_cluster[[1]][])),
                                     directions = adjacency_direction,
                                     pairs = FALSE,
                                     include = FALSE)
  raster::values(raster_layer_cluster$adjacent_cells)[adjacent_cells] <- 1 # adjacent cells including the cluster
  raster::values(raster_layer_cluster$adjacent_cells)[which(!is.na(raster_layer_cluster[[1]][]))] <- NA # restrict to adjacent cells only  
  return(raster_layer_cluster$adjacent_cells)
}


#### get_contiguous_cells ===============================================================

get_contiguous_cells <- function(raster_layer_pop, cell_rule, clump_rule, grouping_direction) {
  # group contiguous grid cells that satisfy cell rule
  raster_layer_clumps <- raster::Which(eval(cell_rule), cells = FALSE) %>%
    raster::clump(directions = grouping_direction)
  # identify groups of grid cells that satisfy clump rule
  if (is.expression(clump_rule)) {
    group_pop <- raster_layer_pop %>%
      raster::zonal(z = raster_layer_clumps,
                    fun = "sum") %>%
      as.data.frame() %>%
      dplyr::mutate(pop_thresh = ifelse(eval(clump_rule), TRUE, FALSE)) %>%
      dplyr::filter(pop_thresh == TRUE)
    output_layer <- raster::Which(raster_layer_clumps %in% group_pop$zone) %>%
      raster::clump(directions = grouping_direction)
    return(output_layer)
  } else {
    return(raster_layer_clumps)
  }
}


#### majority_rule ======================================================================

majority_rule <- function(x) {
  # if the focal cell is not adjacent (Bishop) to a group, return the focal cell as is
  # since the matrix is 3*3, the focal cell is always cell 5
  if (is.na(x[5])| x[5] != adjacent_id) {
    return(x[5])
  }
  
  # find the most frequent surrounding cell-group values
  # focal cells must be surrounded by at least five out of nine cells of a specific group 
  # to be counted towards this group
  most_freq_neighbor <- sort(table(x), decreasing = TRUE)[1]
  most_freq_neighbor_group <- as.integer(names(most_freq_neighbor))
  
  # if the most frequent neighboring cells make up the majority of the cells surrounding a 
  # focal cell and are not themselves adjacent cells, they are counted towards the groups, 
  # else return the focal cell as is
  if (most_freq_neighbor_group == adjacent_id | most_freq_neighbor < 5) {
    return(x[5])
  }
  return(most_freq_neighbor_group)
}


#### get_grid_classification_l1 =========================================================

get_grid_classification_l1 <- function(pop_grid, uninhabited_na = TRUE) {
  
  names(pop_grid) <- "pop1sqkm"
  
  # set parameters
  cell_rule_urban_centre <- expression(raster_layer_pop >= 1500) 
  cell_rule_urban_cluster <- expression(raster_layer_pop >= 300)
  clump_rule_urban_centre <- expression(sum >= 50000)
  clump_rule_urban_cluster <- expression(sum >= 5000)    
  grouping_direction_urban_centre <- 4
  grouping_direction_urban_cluster <- 8
  adjacency_direction <- "bishop" # for gap filling
  
  # get urban centres
  pop_grid$urban_centre <- get_contiguous_cells(raster_layer_pop = pop_grid$pop1sqkm,
                                                cell_rule = cell_rule_urban_centre,
                                                clump_rule = clump_rule_urban_centre,
                                                grouping_direction = grouping_direction_urban_centre)
  
  # gap filling for urban centres
  # find cells adjacent to urban centres
  pop_grid$adjacent <- get_adjacent_cells(raster_layer_cluster = pop_grid$urban_centre,
                                          adjacency_direction = adjacency_direction)
  
  # assign unique identifier for adjacent cells of urban centres
  adjacent_id <<- pop_grid$urban_centre[] %>%
    unique() %>%
    max(na.rm = TRUE) %>%
    magrittr::add(1)
  raster::values(pop_grid$urban_centre)[which(!is.na(pop_grid$adjacent[]))] <- adjacent_id
  pop_grid <- pop_grid %>%
    raster::dropLayer("adjacent")
  
  # temporarily extend grid to ensure that edges are included in computation
  orig_extent <- raster::extent(pop_grid)
  pop_grid <- pop_grid %>%
    raster::extend(c(1,1), value = NA)
  
  # apply majority rule iteratively until no more cells are added to urban centres:
  # - if at least five of the eight cells surrounding the focal cell belong to the same unique urban centre, 
  #   then that cell is also considered to belong to this urban centre. The criterion for gap filling includes 
  #   cells that are linked only on a diagonal (thus "bishop" above).
  # - implemented in function "majority_rule"
  reference <- NA
  iter <- 1
  while(!identical(reference, pop_grid$urban_centre[])) {
    reference <- pop_grid$urban_centre[]
    pop_grid$urban_centre <- raster::focal(x = pop_grid$urban_centre,
                                           w = matrix(1,nrow=3,ncol=3),
                                           fun = majority_rule)
    cat("gap filling iteration", iter, "\n")
    iter <- iter + 1
  }
  
  # restore original extent of grid and remove identifier for adjacent cells not added to urban centres
  pop_grid <- pop_grid %>%
    raster::crop(orig_extent)
  raster::values(pop_grid$urban_centre)[which(is.nan(pop_grid$urban_centre[]))] <- NA # clean up
  raster::values(pop_grid$urban_centre)[which(pop_grid$urban_centre[] == adjacent_id)] <- NA
  remove(adjacent_id, envir = globalenv())
  
  # format urban centres
  pop_grid$urban_centre <- raster::Which(pop_grid$urban_centre)
  
  # get urban clusters
  pop_grid$urban_cluster <- get_contiguous_cells(raster_layer_pop = pop_grid$pop1sqkm,
                                                 cell_rule = cell_rule_urban_cluster,
                                                 clump_rule = clump_rule_urban_cluster,
                                                 grouping_direction = grouping_direction_urban_cluster) %>%
    Which() # unclump
  
  # remove urban cluster cells if part of urban centre
  raster::values(pop_grid$urban_cluster)[which(pop_grid$urban_centre[] == 1)] <- 0
  
  # get rural grid cells
  pop_grid$rural_grid <- raster::Which(pop_grid$urban_centre == 0 &
                                         pop_grid$urban_cluster == 0, 
                                       cells = FALSE)
  
  if (uninhabited_na == TRUE) {
    raster::values(pop_grid$rural_grid)[which(is.na(pop_grid$pop1sqkm[]))] <- NA
  }
  
  # get grid classification
  pop_grid$classification_l1 <- pop_grid$pop1sqkm %>%
    raster::setValues(NA)
  values(pop_grid$classification_l1) <- ifelse(pop_grid$urban_centre[] == 1, "urban centre",
                                               ifelse(pop_grid$urban_cluster[] == 1, "urban cluster",
                                                      ifelse(pop_grid$rural_grid[] == 1, "rural cells",
                                                             NA))) %>%
    factor(levels = c("urban centre", "urban cluster", "rural cells"))
  return(pop_grid)
}


#### get_grid_classification_l2 =========================================================

get_grid_classification_l2 <- function(pop_grid, uninhabited_na = TRUE) {
  # set parameters
  cell_rule_dense <- expression(raster_layer_pop >= 1500) 
  cell_rule_semi_dense <- expression(raster_layer_pop >= 300)
  cell_rule_rural <- expression(raster_layer_pop >= 300)
  cell_rule_low_density <- expression(raster_layer_pop >= 50)
  cell_rule_very_low_density <- expression(raster_layer_pop < 50)
  clump_rule_dense <- expression(sum >= 5000 & sum < 50000)
  clump_rule_semi_dense <- expression(sum >= 5000)    
  clump_rule_rural <- expression(sum >= 500 & sum < 5000)
  grouping_direction_dense <- 4
  grouping_direction_semi_dense <- 8
  grouping_direction_rural <- 8
  adjacency_direction <- 8
  
  
  # filter urban cluster cells that are not part of an urban centre
  raster::values(pop_grid$urban_cluster)[which(pop_grid$urban_centre[] == 1)] <- 0
  
  # filter population grid for urban cluster cells
  pop_grid$pop1sqkm_urban_cluster <- pop_grid$pop1sqkm
  raster::values(pop_grid$pop1sqkm_urban_cluster)[which(pop_grid$urban_cluster[] == 0)] <- NA
  
  # get dense urban clusters
  pop_grid$dense_urban_cluster <- get_contiguous_cells(raster_layer_pop = pop_grid$pop1sqkm_urban_cluster,
                                                       cell_rule = cell_rule_dense,
                                                       clump_rule = clump_rule_dense,
                                                       grouping_direction = grouping_direction_dense)
  # get semi-dense urban clusters
  pop_grid$semi_dense_urban_cluster <- get_contiguous_cells(raster_layer_pop = pop_grid$pop1sqkm_urban_cluster,
                                                            cell_rule = cell_rule_semi_dense,
                                                            clump_rule = clump_rule_semi_dense,
                                                            grouping_direction = grouping_direction_semi_dense)
  pop_grid <- pop_grid %>%
    raster::dropLayer("pop1sqkm_urban_cluster")
  # remove semi-dense urban clusters if contiguous with dense urban clusters
  pop_grid$semi_dense_urban_cluster <- drop_clusters(raster_layer_cluster = pop_grid$semi_dense_urban_cluster,
                                                     raster_layer_condition = get_adjacent_cells(raster_layer_cluster = pop_grid$dense_urban_cluster,
                                                                                                 adjacency_direction = adjacency_direction))
  # remove semi-dense urban clusters if contiguous with urban centres
  pop_grid$semi_dense_urban_cluster <- drop_clusters(raster_layer_cluster = pop_grid$semi_dense_urban_cluster,
                                                     raster_layer_condition = get_adjacent_cells(raster_layer_cluster = pop_grid$urban_centre,
                                                                                                 adjacency_direction = adjacency_direction))
  # remove semi-dense urban clusters if within a 2km of dense urban clusters
  # "measured as outside a buffer of three grid cells of 1km2"
  pop_grid$semi_dense_urban_cluster <- drop_clusters(raster_layer_cluster = pop_grid$semi_dense_urban_cluster,
                                                     raster_layer_condition = raster::buffer(pop_grid$dense_urban_cluster,
                                                                                             width = 3000))
  # remove semi-dense urban clusters if within 2km of dense urban cluster
  # "measured as outside a buffer of three grid cells of 1km2"
  pop_grid$semi_dense_urban_cluster <- drop_clusters(raster_layer_cluster = pop_grid$semi_dense_urban_cluster,
                                                     raster_layer_condition = raster::buffer(raster::clamp(pop_grid$urban_centre, 
                                                                                                           lower = 1, 
                                                                                                           useValues = FALSE),
                                                                                             width = 3000))
  
  # get suburban or peri-urban cells
  pop_grid$suburban_cells <- pop_grid$urban_cluster
  raster::values(pop_grid$suburban_cells)[which(!is.na(pop_grid$dense_urban_cluster[]) |
                                                  !is.na(pop_grid$semi_dense_urban_cluster[]))] <- 0
  
  # format clusters
  raster::values(pop_grid$dense_urban_cluster) <- ifelse(is.na(pop_grid$dense_urban_cluster[]), 0, 1)
  raster::values(pop_grid$semi_dense_urban_cluster) <- ifelse(is.na(pop_grid$semi_dense_urban_cluster[]), 0, 1)
  
  # filter population grid for rural grid cells
  pop_grid$pop1sqkm_rural_cells <- pop_grid$pop1sqkm
  raster::values(pop_grid$pop1sqkm_rural_cells)[which(pop_grid$rural_grid[] == 0)] <- NA
  
  # get rural cluster
  pop_grid$rural_cluster <- get_contiguous_cells(raster_layer_pop = pop_grid$pop1sqkm_rural_cells,
                                                 cell_rule = cell_rule_rural,
                                                 clump_rule = clump_rule_rural,
                                                 grouping_direction = grouping_direction_rural)
  # get low-density rural cells
  pop_grid$low_density_rural_cells <- get_contiguous_cells(raster_layer_pop = pop_grid$pop1sqkm_rural_cells,
                                                           cell_rule = cell_rule_low_density,
                                                           clump_rule = NA,
                                                           grouping_direction = grouping_direction_rural) %>%
    Which() # unclump
  
  # remove low-density rural cells if part of rural cluster
  raster::values(pop_grid$low_density_rural_cells)[which(!is.na(pop_grid$rural_cluster[]))] <- 0
  
  # get very low-density rural cells 
  pop_grid$very_low_density_rural_cells <- get_contiguous_cells(raster_layer_pop = pop_grid$pop1sqkm_rural_cells,
                                                                cell_rule = cell_rule_very_low_density,
                                                                clump_rule = NA,
                                                                grouping_direction = grouping_direction_rural) %>%
    Which() # unclump
  pop_grid <- pop_grid %>%
    raster::dropLayer("pop1sqkm_rural_cells")
  
  # format clusters
  raster::values(pop_grid$rural_cluster) <- ifelse(is.na(pop_grid$rural_cluster[]), 0, 1)
  
  
  if (uninhabited_na == FALSE) {
    raster::values(pop_grid$very_low_density_rural_cells)[which(is.na(pop_grid$pop1sqkm[]))] <- 1
  }
  
  # get grid classification
  pop_grid$classification_l2 <- pop_grid$pop1sqkm %>%
    raster::setValues(NA)
  values(pop_grid$classification_l2) <- ifelse(pop_grid$urban_centre[] == 1, "urban centre",
                                               ifelse(pop_grid$dense_urban_cluster[] == 1, "dense urban cluster",
                                                      ifelse(pop_grid$semi_dense_urban_cluster[] == 1, "semi-dense urban cluster",
                                                             ifelse(pop_grid$suburban_cells[] == 1, "suburban cells",
                                                                    ifelse(pop_grid$rural_cluster[] == 1, "rural cluster",
                                                                           ifelse(pop_grid$low_density_rural_cells[] == 1, "low-density rural cells",
                                                                                  ifelse(pop_grid$very_low_density_rural_cells[] == 1, "very low-density rural cells",
                                                                                         NA))))))) %>%
    factor(levels = c("urban centre", 
                      "dense urban cluster", "semi-dense urban cluster", "suburban cells", 
                      "rural cluster", "low-density rural cells", "very low-density rural cells"))
  return(pop_grid)
}


#### get_fua_layer ======================================================================

get_fua <- function(pop_grid, fua_polygon) {
  
  # rasterize the functional urban areas
  fua_grid <-  raster::rasterize(x = fua_polygon, 
                                 y = raster::raster(raster::extent(pop_grid),
                                                    resolution = raster::res(pop_grid),
                                                    crs = raster::crs(pop_grid)))
  names(fua_grid) <- "fua"

  # add the functional urban area grid to the population grid
  fua_grid <- fua_grid %>%
    raster::addLayer(pop_grid)
  
  # filter functional urban areas with 250K inhabitants or more
  fua_pop <- fua_grid$pop1sqkm %>%
    raster::zonal(z = fua_grid$fua,
                  fun = "sum") %>%
    as.data.frame() %>%
    dplyr::mutate(pop_thresh = ifelse(sum >= 250000, TRUE, FALSE)) %>%
    dplyr::filter(pop_thresh == TRUE)
  fua_grid$fua_metro <- raster::Which(fua_grid$fua %in% fua_pop$zone)
  fua_grid <- fua_grid[[c("fua", "fua_metro")]]
  fua_grid$fua <- fua_grid$fua %>% raster::Which()
  
  return(fua_grid)
}


#### get_spatial_classification_l1 ======================================================

get_spatial_classification_l1 <- function(grid_classification, polygons, fua = FALSE) {
  
  # set expression if fua TRUE
  if (fua == TRUE) {
    fua_expr <- expression(sum(pop1sqkm[fua == 1]*coverage_fraction[fua == 1], na.rm = TRUE))
    fua_metro_expr <- expression(sum(pop1sqkm[fua_metro == 1]*coverage_fraction[fua_metro == 1], na.rm = TRUE))
  } else {
    fua_expr <- expression(NA)
    fua_metro_expr <- expression(NA)
  }
  
  # extract raster population counts and cluster types in polygons
  polygon_values <- exactextractr::exact_extract(x = grid_classification, 
                                                 y = polygons, 
                                                 progress = TRUE) %>%
    dplyr::bind_rows(.id = "id") %>%
    dplyr::mutate(id = as.integer(id))
  
  # compute population totals across and within cluster types in polygons while
  # accounting for partial polygon coverage of cells
  polygon_values <- polygon_values %>%
    dplyr::group_by(id) %>%
    dplyr::summarize(total_pop = sum(pop1sqkm*coverage_fraction, na.rm = TRUE),
                     urban_centre_pop = sum(pop1sqkm[urban_centre == 1]*coverage_fraction[urban_centre == 1], na.rm = TRUE),
                     urban_cluster_pop = sum(pop1sqkm[urban_cluster == 1]*coverage_fraction[urban_cluster == 1], na.rm = TRUE),
                     rural_grid_pop = sum(pop1sqkm[rural_grid == 1]*coverage_fraction[rural_grid == 1], na.rm = TRUE),
                     fua_pop = eval(fua_expr),
                     fua_metro_pop = eval(fua_metro_expr)) %>%
    dplyr::mutate(degurba_l1 = factor(case_when(urban_centre_pop >= total_pop*0.5 ~ "cities",
                                                urban_centre_pop < total_pop*0.5 & 
                                                  rural_grid_pop <= total_pop*0.5 ~ "towns and semi-dense areas",
                                                rural_grid_pop > total_pop*0.5 ~ "rural areas"),
                                      levels = c("cities", "towns and semi-dense areas", "rural areas")))
  if (fua == TRUE) {
    polygon_values <- polygon_values %>%
      dplyr::mutate(fua = factor(case_when(fua_pop >= total_pop*0.5 ~ "functional urban area",
                                    TRUE ~ NA_character_)),
                    fua_metro = factor(case_when(fua_metro_pop >= total_pop*0.5 ~ "metropolitan functional urban area",
                                           TRUE ~ NA_character_))) %>%
      dplyr::select(degurba_l1, fua, fua_metro)
  } else {
    polygon_values <- polygon_values %>%
      dplyr::select(degurba_l1)
  }
  return(polygon_values)
}


#### get_spatial_classification_l2 ======================================================

get_spatial_classification_l2 <- function(grid_classification, spatial_classification_l1, polygons) {
  
  # extract raster population counts and cluster types in polygons
  polygon_values <- exactextractr::exact_extract(x = grid_classification, 
                                                 y = polygons, 
                                                 progress = TRUE) %>%
    dplyr::bind_rows(.id = "id") %>%
    dplyr::mutate(id = as.integer(id))
  
  # compute population totals across and within cluster types in polygons while
  # accounting for partial polygon coverage of cells
  polygon_values <- polygon_values %>%
    dplyr::group_by(id) %>%
    dplyr::summarize(dense_urban_cluster_pop = sum(pop1sqkm[dense_urban_cluster == 1]*coverage_fraction[dense_urban_cluster == 1], na.rm = TRUE),
                     semi_dense_urban_cluster_pop = sum(pop1sqkm[semi_dense_urban_cluster == 1]*coverage_fraction[semi_dense_urban_cluster == 1], na.rm = TRUE),
                     suburban_cells_pop = sum(pop1sqkm[suburban_cells == 1]*coverage_fraction[suburban_cells == 1], na.rm = TRUE),
                     rural_cluster_pop = sum(pop1sqkm[rural_cluster == 1]*coverage_fraction[rural_cluster == 1], na.rm = TRUE),
                     low_density_rural_cells_pop = sum(pop1sqkm[low_density_rural_cells == 1]*coverage_fraction[low_density_rural_cells == 1], na.rm = TRUE),
                     very_low_density_rural_cells_pop = sum(pop1sqkm[very_low_density_rural_cells == 1]*coverage_fraction[very_low_density_rural_cells == 1], na.rm = TRUE)
                     ) %>%
    cbind(spatial_classification_l1) %>%
    dplyr::mutate(degurba_l2 = factor(case_when(degurba_l1 == "cities" ~ "cities",
                                                degurba_l1 == "towns and semi-dense areas" &
                                                  dense_urban_cluster_pop > semi_dense_urban_cluster_pop & 
                                                  dense_urban_cluster_pop + semi_dense_urban_cluster_pop > suburban_cells_pop ~ "dense towns",
                                                degurba_l1 == "towns and semi-dense areas" &
                                                  semi_dense_urban_cluster_pop > dense_urban_cluster_pop & 
                                                  dense_urban_cluster_pop + semi_dense_urban_cluster_pop > suburban_cells_pop ~ "semi-dense towns",
                                                degurba_l1 == "towns and semi-dense areas" &
                                                  suburban_cells_pop > dense_urban_cluster_pop + semi_dense_urban_cluster_pop ~ "suburban areas",
                                                degurba_l1 == "rural areas" &
                                                  rural_cluster_pop > low_density_rural_cells_pop & rural_cluster_pop > very_low_density_rural_cells_pop ~ "villages",
                                                degurba_l1 == "rural areas" &
                                                  low_density_rural_cells_pop > rural_cluster_pop & low_density_rural_cells_pop > + very_low_density_rural_cells_pop ~ "dispersed rural areas",
                                                degurba_l1 == "rural areas" &
                                                  very_low_density_rural_cells_pop > rural_cluster_pop & very_low_density_rural_cells_pop > low_density_rural_cells_pop ~ "mostly uninhabited rural areas")))
  if ("fua" %in% colnames(polygon_values)) {
    polygon_values <- polygon_values %>%
      dplyr::select(degurba_l1, degurba_l2, fua, fua_metro)
  } else {
    polygon_values <- polygon_values %>%
      dplyr::select(degurba_l1, degurba_l2)
  }
  return(polygon_values)
}