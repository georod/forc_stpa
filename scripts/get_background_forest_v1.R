# ====================================================
# CREATE backgroung Forest and non-forest landcover
# ====================================================

# 2025-02-03
# Peter R.

# Notes
# - I need to get the N raster cells/polygons. The idea was to use the background forest map from NTEMS
# - I used the Ontario clip and clipped it with my study area
# - Then I reclasified th raster to forest ad non-fores classes
# - However, I had problems converting landcover raster into polygon using QGIS. The output polygons has many intersecting and ring polygons
# - Here I used landscapemetrics which worked nicely in the past.
# - First, I am creating ptaches and then the patches are turned into polygons. Forest and non-forest were separated and only a table for forest was created.
# - The outputs are vector geopackage files
# - The gpkg file created at the end was imported into QGIS and then an SQL dump was created.  The latter was then uploaded to Postgres using psql at Cmd prompt (not db connection prompt)
# - Note that I already had a forest layer used in Ch2.  It would have been better to use it for consistency reasons. Now my overall forest areas will be different.
# - The good think of recreating the forest layer is that my clip metrics (done in Postgis) are more accurate.
#


#=================================
# Load libraries
# ================================

library(terra)
library(sf)
library(foreach)
#library(doParallel)
#library(dplyr)
#library(sqldf)
library(raster)
library(landscapemetrics)

library(DBI)


#=================================
# File paths and folders
# ================================

outf4 <- "C:/Users/Peter R/Documents/forc_stpa/output1/gis/forest_lcover/"
shp4 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_pj_3978.shp"

r1 <- "~/data/gis/algonquin/CA_forest_VLCE2_2003_algonquin_rcl2_v1.tif"

#bboxPj <- st_read(shp4)
bboxPj <- terra::vect(shp4)
#bboxPJ

rFor <- terra::rast(r1)

rForM <- mask(rFor, bboxPj)
#plot(rForM)


# Create non-forest patches from raster
nonForPoly <- landscapemetrics::get_patches(
  rForM,
  class = "1",
  directions = 8,
  to_disk = getOption("to_disk", default = TRUE),
  return_raster = TRUE
)

# Convert to polygons
temp4 <- terra::as.polygons(terra::rast(nonForPoly[[1]][[1]]))

terra::writeVector(temp4, paste0(outf4, "non_forest_lcover_2003", ".gpkg"), overwrite=TRUE)


# Create forest pacthes from raster. Forest=2
nonForPoly <- landscapemetrics::get_patches(
  rForM,
  class = "2",
  directions = 8,
  to_disk = getOption("to_disk", default = TRUE),
  return_raster = TRUE
)

# Convert to polygons
temp4 <- terra::as.polygons(terra::rast(nonForPoly[[1]][[1]]))

# Save as gpkg
terra::writeVector(temp4, paste0(outf4, "forest_lcover_2003", ".gpkg"), overwrite=TRUE)

# The gpkg file was imported into QGIS and then an SQL dump was created.  The latter was then uploaded to Postgres using psql at Cmd prompt (not db connection prompt)
# One in Postgres I ran geometry calculations to label change polygons as protected or non protected.


# ---------------------------
# Overall Forest metrics
# ---------------------------

# How much forest area in 2003 in study area?
# No need to recalculate
# area calculate with EPSG: 3978, Canada Atlas Lambert
forestAreaHa <- as.numeric(sum(sf::st_area(sf::st_as_sf(temp4))))/10000 # in m2=13,240'868,400, in ha=1'324,087
#forestAreaHa2 <- as.numeric(sum(sf::st_area(sf::st_transform(sf::st_as_sf(temp4), "EPSG:3347"))))/10000 # in m2= in ha=1'324,087. Same as above.


# ---------------------------
# Overall protected forest metrics
# ---------------------------
# How much protected area?

#connect to db where change polygons were given protected status


con1 <- DBI::dbConnect(RPostgres::Postgres(), dbname = "resnet1", host='localhost', port=5432, user=Sys.getenv("username"), password=Sys.getenv("pwd"))


pgTabs <- c("forest_lcover_2003_pro_v3")


pgTabsL <- foreach(i=1:length(pgTabs)) %do% {
  
  st_read(con1, layer = pgTabs[i])
  #st_transform(temp1, proj1)
  
  
}


#plot(sf::st_geometry(pgTabsL[[1]]), col="green")


forestAreaHa <- as.numeric(sum(sf::st_area(sf::st_as_sf(pgTabsL[[1]]))))/10000  # 1'324,087

proforestAreaHa <- as.numeric(sum(sf::st_area(sf::st_as_sf(pgTabsL[[1]][pgTabsL[[1]]$status==1,]))))/10000 # 220,046.5

nonproforestAreaHa <- as.numeric(sum(sf::st_area(sf::st_as_sf(pgTabsL[[1]][pgTabsL[[1]]$status==0,]))))/10000 # 1'104,040
