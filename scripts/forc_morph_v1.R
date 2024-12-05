#=================================================================================
# Forest Carbon Spationtemporal pattern analysis (STPA))
#=================================================================================

# 2024-07-20
# Peter R.

# Notes
# - Here I use forest EVI trend rastera to to see how 3-D analyses of raster cubes can be used to shed light on carbon dynamics.
# - This is for Chapter 3. 
# - I will be using an updated work flow which inlcudes GitHub, DRAC, JupyterLab, Python and R.
# - I need to create the spatiotemporal cubes before I can run Morph
# - Are extents the same? Do some stats.
# - ONly forest chnage vs no chnage is done here so far.
# - I couldn't get it to plot the cubus (voxels). Eventhough I used a very small subset.



#=================================
# Load libraries
# ================================

library(terra)
library(sf)
library(foreach)
library(doParallel)

#install.packages("morph")
library(morph)

#=================================
# File paths and folders
# ================================


#setwd("~/projects/def-mfortin/georod/scripts/forc_trends") # github folder
setwd("../")

#dataf <- "~/projects/def-mfortin/georod/data" # data folder
dataf <- "~/data/gis"

# EVI trends
fpath2 <- "~/data/gis/ont_out/ont_CA_forest_VLCE2_2003.tif"

# Path to vectors
#shp1 <- "./misc/shp/algonquin_envelope_500m_buff_v1.shp"
shp1 <- "~/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1.shp"
bbox2 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/study_area_subset_v3.shp"

# CSV to reclassify land cover values to keep only forest pixels
# fpath4 <- "~/projects/def-mfortin/georod/data

fpath3 <- "~/st_trends_for_c/algonquin/ver2/data/gis/raster/EVI_flag_type_sig_16d_masked1.tif"

fpath4 <- "~/st_trends_for_c/algonquin/ver2/data/gis/raster/EVI_flag_type_sig_16d_masked1.tif"

# Output & input folders
#outf3 <- paste0(dataf, "/forc_trends_pj/algonquin/output_h5p/NDVI_250m/bfast/")  
inf3 <- "~/st_trends_for_c/algonquin/version3/gis/"

#outf3 <-


#-------------------
# Read data
#-------------------

#rTrend <- rast(fpath4)

r5 <- rast(paste0(inf3,"forest_lc_2003.tiff"))


#--------------------
  # Read in vector
  # transform shp1 to raster projection
  vpolyList1 <- list()
  
  for (y in 1:length(shp1)) {
    
    temp1 <- vect(st_read(shp1[y]))
    vpolyList1[[y]] <- project(temp1,r5)
    
  }


# create loop
rChL <- foreach (k= 1:4) %do% {

rTemp1 <- rast(paste0("C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h1yr/EVI_250m/bfast01/period", k, "/EVI_flag_type_sig_16d.tif"))


m <- c(1,8, 2) # All pixels thant changed turn them into 2s
#m <- c(1, 7, NA) # For greening
rclmat <- matrix(m, ncol=3, byrow=TRUE)

rTemp2 <- classify(rTemp1 , rclmat, include.lowest=TRUE)
#plot(rCh, col="red")
#freq(rCh)

#rGreen <- classify(rTrend, rclmat, include.lowest=TRUE)
#rGreen2 <- subst(rGreen, 8, 2)
#freq(rGreen2)

r6 <- resample(r5, rTemp2, method='near')
freq(r6)
#plot(r6)

# Raster with values fro MSPA algorithm
rTemp3 <- mask(r6, rTemp2, inverse=TRUE, updatevalue=2) 

m2 <- c(1,0,2,1)
rclmat2 <- matrix(m2, ncol=2, byrow=TRUE)
rTemp3 <- classify(rTemp3, rclmat2)

mask(rTemp3, vpolyList1[[1]])


}

#plot(rChL[[1]])
#plot(vpolyList1[[1]], add=TRUE)
freq(rast(rChL))

# reclass date into change and no change pixels.
# First, I need to merged trends and forest pixels

# r5 is the forest cover for 2003. It was recreated here
# C:/Users/Peter R/Documents/st_trends_for_c/algonquin/version3/scripts/recreate_forest_pixels_mask_v1.R


#-------------------
# Convert raster to array fro the package Morph
#-------------------

#- Notes:
# - The original raster extent is to big and the function stals.
# - Here, I clip the original raster to cover a samller portion of the study area. Hopefully, this works better.It work with a 10 x 10 km study area (..._v3). It took about 15 minutes. The plot or arraytrim fucntion did not work.


bbox2Pj <- project(vect(bbox2), rast(rChL))

rChL2 <- crop(rast(rChL), bbox2Pj)

global(rChL2, fun='isNA')

# It seems NAs are an issue. Le's reclassify these values
rChL3 <- subst(rChL2, NA, 0)

global(rChL3, fun='isNA')

array1 <- as.array(rChL3)
dim(array1)
str(array1)

array2 <- arraytrim(array1)
dim(array2)
str(array2)

#array1Out <- morph3d(array1, PLOT=FALSE, FINALPLOT=TRUE)
array1Out <- morph3d(array1, PLOT=FALSE, FINALPLOT=FALSE)
str(array1Out)

array1Out$Summary

morph3dplot(data = array1Out, CELLID = TRUE, LEGEND = FALSE, ORIGTRANSP = TRUE)


#data("LEdemo")
#str(LEdemo)

#LEdemoOut <- morph3d(LEdemo, PLOT=FALSE, FINALPLOT=FALSE)
#str(LEdemoOut)

#LEdemoOut <- morph3d(LEdemo, PLOT=FALSE, FINALPLOT=TRUE)







