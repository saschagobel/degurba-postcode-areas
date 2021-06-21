# The Degree of Urbanisation Classification<br />for Postcode Areas

This repository contains R code to implement level 1 and 2 of the degree of urbanisation (DEGURBA) classification (see [Dijkstra et al. 2020](https://www.sciencedirect.com/science/article/pii/S0094119020300838#cit_5) and [Eurostat 2021](https://ec.europa.eu/eurostat/en/web/products-manuals-and-guidelines/-/ks-02-20-499)) and to superimpose the grid cell classifications on postcode areas. The method is applied for five countries: France, Germany, Spain, Switzerland, and the United Kingdom.

# Data sources

The classification is based on the following data sources. Data can be downloaded with the [01-data.R](../master/code/01-data.R) script.

* [2018 GEOSTAT 1sqkm population grids](https://ec.europa.eu/eurostat/en/web/gisco/geodata/reference-data/population-distribution-demography/geostat)
* [2021 NUTS0 country border polygons](https://ec.europa.eu/eurostat/en/web/gisco/geodata/reference-data/administrative-units-statistical-units/nuts#nuts21)
* [2018 Urban audit data including functional urban areas](https://ec.europa.eu/eurostat/en/web/gisco/geodata/reference-data/administrative-units-statistical-units/urban-audit#ua18)
* Postcode boundaries for:
   * [France](https://www.data.gouv.fr/fr/datasets/fond-de-carte-des-codes-postaux/) (2014 5-digit postcodes)
   * [Germany](https://opendata-esri-de.opendata.arcgis.com/datasets/esri-de-content::postleitzahlengebiete-2018/about) (2020 5-digit postcodes)
   * [Spain](https://github.com/inigoflores/ds-codigos-postales) (2017 5-digit postcodes)
   * [Switzerland](https://opendata.swiss/de/dataset/amtliches-ortschaftenverzeichnis-mit-postleitzahl-und-perimeter) (2021 4-digit postcodes)
   * [United Kingdom](https://www.opendoorlogistics.com/downloads/) (2015 postcode sectors)

# Classification procedure

The Degree of Urbanisation offers a common classification scheme of the urban-rural continuum that facilitates cross-national comparability. It was developed by the European Commission, the Food and Agriculture Organization of the United Nations, the United Nations Human Settlements Programme, the International Labour Organisation, the Organisation for Economic Co-operation and Development, and The World Bank. The methodology is described in detail in [Eurostat 2021](https://ec.europa.eu/eurostat/en/web/products-manuals-and-guidelines/-/ks-02-20-499).

The classification is applied in two steps. First, 1sq km grid cells are classified based on population density and contiguity. Second, spatial units are classified based on the share of their population in classified grid cells. Two classification levels allow for varying granularity of the urban-rural continuum. Here is an overview of category definitions for both levels.

### Grid cell classification:

#### Level 1
1. *urban centre*: contiguous (Rook's case) grid cells with population >= 1,500 inhabitants and collectively a population >= 50,000 inhabitants. Gaps are iteratively filled afterwards, see `majority_rule()` in [functions.R](../master/code/functions.R) script.
2. *urban cluster*: contiguous (Queen's case) grid cells with population >= 300 inhabitants and collectively a population >= 5,000 inhabitants. Urban centres are removed from urban clusters afterwards.
3. rural cells: grid cells that are neither urban centres nor urban clusters.

#### Level 2
1. urban centre:
2. dense urban cluster:
3. semi-dense urban cluster
4. suburban cells:
5. rural cluster:
6. low-density rural cells:
7. very low-density rural cells:

### Spatial unit classification

#### Level 1
1. cities:
2. towns and semi-dense areas:
3. rural areas:

#### Level 2
1. cities:
2. dense towns:
3. semi-dense towns:
4. suburban areas:
5. villages
6. dispersed rural areas
7. mostly uninhabited rural areas

In addition to ...



Functional urban areas ... to account for ...



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
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/degurba_l2_grid_map.png?token=AHDPXYPXJDRQSUESSNQYCMTA2SKWW">
    <img width="400" src="maps/degurba_l2_grid_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/degurba_l2_grid_fua_map.png?token=AHDPXYPMNO4CQLITZKL4E33A2SKXY">
    <img width="400" src="maps/degurba_l2_grid_fua_map.png">
  </a>
</p>


### DEGURBA Level 1  - Postcode Areas

<p align="center">
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/degurba_l1_postcode_map.png?token=AHDPXYL5F4EVQOCNXI5B3PDA2SNLG">
    <img width="400" src="maps/degurba_l1_postcode_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/degurba_l1_postcode_fua_map.png?token=AHDPXYJGDICVA3JM77KWLPDA2SNNU">
    <img width="400" src="maps/degurba_l1_postcode_fua_map.png">
  </a>
</p>


### DEGURBA Level 2  - Postcode Areas
<p align="center">
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/degurba_l2_postcode_map.png?token=AHDPXYKRQP5O4QH3YU446KTA3F2QQ">
    <img width="400" src="maps/degurba_l2_postcode_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/degurba_l2_postcode_fua_map.png?token=AHDPXYNKNQM4522HBX4OGJLA3F2SU">
    <img width="400" src="maps/degurba_l2_postcode_fua_map.png">
  </a>
</p>

# Country-specific Postcode Area Classification

### DEGURBA Level 1

<p align="center">
  <b>France</b><br />
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/fr_degurba_l1_postcode_map.png?token=AHDPXYOU2RY7IL77ZUUOJG3A3F2WK">
    <img width="400" src="maps/fr_degurba_l1_postcode_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/fr_degurba_l1_postcode_fua_map.png?token=AHDPXYK2VXGUY3UTLQXDXU3A3F2XQ">
    <img width="400" src="maps/fr_degurba_l1_postcode_fua_map.png">
  </a>
</p>

<p align="center">
  <b>Germany</b><br />
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/de_degurba_l1_postcode_map.png?token=AHDPXYMIB4JIBV6CM2E3FW3A3F2ZA">
    <img width="400" src="maps/de_degurba_l1_postcode_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/de_degurba_l1_postcode_fua_map.png?token=AHDPXYM7QNJ5T7MPJYUAGETA3F22U">
    <img width="400" src="maps/de_degurba_l1_postcode_fua_map.png">
  </a>
</p>

<p align="center">
  <b>Spain</b><br />
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/es_degurba_l1_postcode_map.png?token=AHDPXYJ5U3YDZFQ33U4OCLTA3F26I">
    <img width="400" src="maps/es_degurba_l1_postcode_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/es_degurba_l1_postcode_fua_map.png?token=AHDPXYMVLEOA6V2SDLUDJSLA3F3AW">
    <img width="400" src="maps/es_degurba_l1_postcode_fua_map.png">
  </a>
</p>

<p align="center">
  <b>Switzerland</b><br />
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/ch_degurba_l1_postcode_map.png?token=AHDPXYM2ZURVZS7OR5LERNLA3F3FM">
    <img width="400" src="maps/ch_degurba_l1_postcode_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/ch_degurba_l1_postcode_fua_map.png?token=AHDPXYLBWQXCMFO7C5AG7XLA3F3HC">
    <img width="400" src="maps/ch_degurba_l1_postcode_fua_map.png">
  </a>
</p>

<p align="center">
  <b>United Kingdom</b> <br />
  (Excluding Northern Ireland)<br />
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/uk_degurba_l1_postcode_map.png?token=AHDPXYI6SWP3N4HXOWX6BF3A3F3IG">
    <img width="400" src="maps/uk_degurba_l1_postcode_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/uk_degurba_l1_postcode_fua_map.png?token=AHDPXYOKROM2PRTI6BGU5CTA3F3JK">
    <img width="400" src="maps/uk_degurba_l1_postcode_fua_map.png">
  </a>
</p>

### DEGURBA Level 2

<p align="center">
  <b>France</b><br />
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/fr_degurba_l2_postcode_map.png?token=AHDPXYOI7GUMXGAO7HD2SADA3F7QM">
    <img width="400" src="maps/fr_degurba_l2_postcode_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/fr_degurba_l2_postcode_fua_map.png?token=AHDPXYKHMPLEWJQFUEDC2J3A3F7SC">
    <img width="400" src="maps/fr_degurba_l2_postcode_fua_map.png">
  </a>
</p>

<p align="center">
  <b>Germany</b><br />
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/de_degurba_l2_postcode_map.png?token=AHDPXYLYFKWDLHAVYFJ4OCDA3F7ZC">
    <img width="400" src="maps/de_degurba_l2_postcode_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/de_degurba_l2_postcode_fua_map.png?token=AHDPXYL2SYJZAKDFPTAUBR3A3F73I">
    <img width="400" src="maps/de_degurba_l2_postcode_fua_map.png">
  </a>
</p>

<p align="center">
  <b>Spain</b><br />
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/es_degurba_l2_postcode_map.png?token=AHDPXYPXQTA63ZLFUGJX65DA3F74S">
    <img width="400" src="maps/es_degurba_l2_postcode_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/es_degurba_l2_postcode_fua_map.png?token=AHDPXYJX3OSVAYGGIPIOSZTA3F77I">
    <img width="400" src="maps/es_degurba_l2_postcode_fua_map.png">
  </a>
</p>

<p align="center">
  <b>Switzerland</b><br />
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/ch_degurba_l2_postcode_map.png?token=AHDPXYPP765WWI6IOPHSKADA3GAIW">
    <img width="400" src="maps/ch_degurba_l2_postcode_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/ch_degurba_l2_postcode_fua_map.png?token=AHDPXYLJMIFNHOIKLVURCP3A3GAJY">
    <img width="400" src="maps/ch_degurba_l2_postcode_fua_map.png">
  </a>
</p>

<p align="center">
  <b>United Kingdom</b> <br />
  (Excluding Northern Ireland)<br />
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/uk_degurba_l2_postcode_map.png?token=AHDPXYMEBVFLUIRN5NUUCYTA3GALE">
    <img width="400" src="maps/uk_degurba_l2_postcode_map.png">
  </a>
  <a href="https://raw.githubusercontent.com/saschagobel/degurba-postcode-areas/master/maps/uk_degurba_l2_postcode_fua_map.png?token=AHDPXYILIPM2PWPYF7BBHGDA3GAMI">
    <img width="400" src="maps/uk_degurba_l2_postcode_fua_map.png">
  </a>
</p>