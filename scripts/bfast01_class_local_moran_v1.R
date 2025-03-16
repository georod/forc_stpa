#=================================================================================
# Create LISA cluster using BFAST01 & BFAST CLASSIFY objects
#=================================================================================
# 2025-01-21
# Peter R.
# 
# - Study area: All of Algonquin Park
# - Script meant to be run locally and/or on DRAC
# - Not that the script run on DRAC has bfast01 level=0.01 and bfastClassify level=0.05
# - Here i am using objects created on DRAC using script: C:/Users/Peter R/Documents/st_trends_for_c/algonquin/version3/scripts/bfast01_class_create_slope_rasters_v1.R
# - This time the list object contains intercept and trend values
# - Chapter 3
# - Positive & negative slopes are ran together here. 
# - I assume local_moral() is Anselin's LISA

#=================================
# Load libraries
# ================================
# install.packages(c("strucchangeRcpp", "bfast"))
library(terra)
library(sf)
#library(bfast)
#install.packages("foreach")
library(foreach)
#library(doParallel)


# install.packages("sfdep")
library(sfdep)

library(dplyr)

#setwd("C:/Users/Peter R/Documents/st_trends_for_c/algonquin") # local
setwd("/home/georod/projects/def-mfortin/georod/scripts/github/forc_stpa") # DRAC

#outf4 <- "C:/Users/Peter R/Documents/forc_stpa/output1/EVI_250m/bfast01/"
outf4 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/output1/EVI_250m/bfast01/" 


frq1 <- "16d"
prefix1 <- c("EVI_")

periodLabs <- c("period1", "period2","period3","period4", "period5", "period6", "period7", "period8") 

#r2_template <- rast("C:/Users/Peter R/Documents/st_trends_for_c/algonquin/r2_template.tif")
r2_template <- rast("/home/georod/projects/def-mfortin/georod/data/forc_stpa/input1/algonquin/r2_template.tif") # DRAC


# Path to vector
#shp1 <- "./misc/shp/algonquin_envelope_500m_buff_v1.shp"
#shp1 <- "~/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1.shp"
shp1 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/input1/shp/algonquin_envelope_500m_buff_v1.shp"


#------------------------------
# List raster files 
#------------------------------
# These raster were created with bfast01_class_create_slope_rasters_v1.R (run locally)

rslopes <- list.files(outf4, pattern = '*sigslope_16d.tif$', full.names = TRUE, recursive = TRUE)
#rslopes2 <- list.files(outf4, pattern = '*sigslope_16d.tif$', full.names = FALSE, recursive = TRUE )


#-----------------------------
# Run Getis-Ord (Gr and Br together)
#-----------------------------
# This loop runs Getis-Ord star using 3 distance bands for each slope raster in each period
# Only critical threshold band is needed.
# Here I am running negative and positive slopes together.

foreach (k= 1:length(rslopes)) %do% {
  
  slopePts0 <- as.points(terra::rast(rslopes[k]), values=TRUE, na.rm=TRUE, na.all=FALSE)
  slopePts0$id <- 1:nrow(slopePts0)
  names(slopePts0) <- c("slope", "id")
  #terra::writeVector(slopepts4, paste0(outf4, periodLabs[k], "/", prefix1, "slopeptsp4", "_" , frq1, ".shp"), options="ENCODING=UTF-8", overwrite=TRUE)
  
  
  # using sfdep
  slopePts <- sf::st_as_sf(slopePts0)
  # project the object to get more robust distance bands
  slopePts <- sf::st_transform( slopePts, "EPSG:3162") # NAD83(CSRS) / Ontario MNR Lambert
  
  #slopePts <- slopePts[slopePts$slope>0, ]
  #slopePts$slope <- slopePts$slope*-1.0 # Invert sign of slope
  #slopePts$slope2 <- as.numeric(scale(slopePts$slope))
  slopePts$slope3 <- as.numeric(min(slopePts$slope)*-1 + slopePts$slope) # This is need to run neg. and pos. slopes together
  slopePts$id <- 1:nrow(slopePts)
  
  #upDist <- c(sfdep::critical_threshold(slopePts), 5000, 10000) # distance bands, may not work for all periods
  #upDist <- c(sfdep::critical_threshold(slopePts)) # distance bands
  #upDist <- c(5000, 10000) # distance bands
  upDist <- c(3500) # distance bands, 3km is a distance that works for the 4 periods
  upDistLabs <- paste0(round(upDist/1000), 'km') # distance band labels
  
  # loop for distance bands
  foreach (j= 1:length(upDist)) %do% {
    
    nb1 <- sfdep::st_dist_band(slopePts, lower = 0, upper = upDist[j])
    
    wt1 <- st_weights(nb1, style = "W", allow_zero = NULL)
    
    Gi <- sfdep::local_moran(slopePts$slope3, nb1, wt1, nsim = 999, alternative = "two.sided")
          
    Gi$id <- 1:nrow(Gi)
    
    GiSpDf <- slopePts %>% inner_join(Gi)
    
    # write files as geopackage as shapefiles truncate names
    sf::write_sf(GiSpDf, paste0(outf4, periodLabs[k], "/", prefix1, "lm_grbr4", "_" ,upDistLabs[j], "_" , frq1, ".gpkg"), overwrite=TRUE)
    
    
  }
  
}


