# ---------------------------------------------------------------------------------------
# DEGURBA POSTCODE AREAS
# Sascha Göbel
# Script for packages
# June 2021
# ---------------------------------------------------------------------------------------


#### INSTALL AND LOAD PACKAGES ==========================================================

# install pacman package if not installed -----------------------------------------------
suppressWarnings(if (!require("pacman")) install.packages("pacman"))

# load packages and install if not installed --------------------------------------------
pacman::p_load(dplyr,
               magrittr,
               purrr,
               crayon,
               extrafont,
               sf,
               tmap,
               raster,
               exactextractr,
               install = TRUE,
               update = FALSE)


# show loaded packages ------------------------------------------------------------------
cat("loaded packages\n")
print(pacman::p_loaded())
