# The Degree of Urbanisation Classification<br />for Postcode Areas

This repository contains R code to implement level 1 and 2 of the degree of urbanisation (DEGURBA) classification (see Dijkstra et al 2020 and Eurostat 2021) and to superimpose the grid cell classifications on postcode areas. The procedure is applied for five countries: France, Germany, Spain, Switzerland, and the United Kingdom.

Eurostat 2021
https://ec.europa.eu/eurostat/en/web/products-manuals-and-guidelines/-/ks-02-20-499

Dijkstra et al 2020
https://www.sciencedirect.com/science/article/pii/S0094119020300838#cit_5

# Data sources

The classification is based on the following data sources. Data are downloaded with the data.R script.

2018 GEOSTAT 1sqkm population grids
https://ec.europa.eu/eurostat/en/web/gisco/geodata/reference-data/population-distribution-demography/geostat

2021 NUTS0 country border polygons
https://ec.europa.eu/eurostat/en/web/gisco/geodata/reference-data/administrative-units-statistical-units/nuts#nuts21

2018 Urban audit data including functional urban areas
https://ec.europa.eu/eurostat/en/web/gisco/geodata/reference-data/administrative-units-statistical-units/urban-audit#ua18

Postcode areas for France (), Germany (), Spain (), Switzerland (), and the United Kingdom ().


# Classification procedure

The degree of urbanisation is a classification scheme for 1sqkm grids and small spatial units. The methodology is described in detail in ... 

Level 1 ... Level 2 further ... Functional urban areas ... To superimpose on spatial units ...



# Example: Part of the Rhine-Neckar Metropolitan Region

### Population Grid
<p align="center">
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/pop_grid_map.png?token=AHDPXYME2LLX7R2QMJ5V3UDA2RPQW">
    <img width="400" src="maps/pop_grid_map.png">
  </a>
</p>

### DEGURBA Level 1 - Grid

<p align="center">
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/degurba_l1_grid_map.png?token=AHDPXYJJVY7N4QVPD77ZY5LA2SJJI">
    <img width="400" src="maps/degurba_l1_grid_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/degurba_l1_grid_fua_map.png?token=AHDPXYNW4VVHE7O4HEJ5VJ3A2SJK2">
    <img width="400" src="maps/degurba_l1_grid_fua_map.png">
  </a>
</p>

### DEGURBA Level 2  - Grid

<p align="center">
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/degurba_l1_grid_map.png?token=AHDPXYJJVY7N4QVPD77ZY5LA2SJJI">
    <img width="400" src="maps/degurba_l2_grid_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/degurba_l1_grid_fua_map.png?token=AHDPXYNW4VVHE7O4HEJ5VJ3A2SJK2">
    <img width="400" src="maps/degurba_l2_grid_fua_map.png">
  </a>
</p>


### DEGURBA Level 1  - Postcode Areas

### DEGURBA Level 2  - Postcode Areas

<p align="center">
  <img width="250" src="maps/ger.png">
  <img width="250" src="maps/ger.png">
</p>

# Country-specific Postcode Area Classification Maps

### DEGURBA Level 1

### DEGURBA Level 2