#=================================================================================
# Create Getis-Ord cluster using BFAST01 & BFAST CLASSIFY objects
#=================================================================================
# 2025-01-11
# Peter R.
# 
# - Study area: All of Algonquin Park
# - Script meant to be run locally and/or on DRAC
# - Not that the script run on DRAC has bfast01 level=0.01 and bfastClassify level=0.05
# - Here i am using objects created on DRAC using script: C:/Users/Peter R/Documents/st_trends_for_c/algonquin/version3/scripts/bfast01_class_create_slope_rasters_v1.R
# - This time the list object contains intercept and trend values
# - Chapter 3

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
#install.packages("remotes")
#library(remotes)

#library(sqldf)
#library(ggplot2)

#install.packages("stlplus")
#library(stlplus)

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
# Run Getis-Ord
#-----------------------------
# This loop runs Getis-Ord star using 3 distance bands for each slope raster in each period

 foreach (k= 1:4) %do% {
  
  slopePts0 <- as.points(terra::rast(rslopes[k]), values=TRUE, na.rm=TRUE, na.all=FALSE)
  slopePts0$id <- 1:nrow(slopePts0)
  names(slopePts0) <- c("slope", "id")
  #terra::writeVector(slopepts4, paste0(outf4, periodLabs[k], "/", prefix1, "slopeptsp4", "_" , frq1, ".shp"), options="ENCODING=UTF-8", overwrite=TRUE)
  
  
  # using sfdep
  slopePts <- sf::st_as_sf(slopePts0)
  
  slopePts <- slopePts[slopePts$slope>0, ]
  #slopePts$slope <- slopePts$slope*-1.0 # Invert sign of slope
  slopePts$id <- 1:nrow(slopePts)
  
  upDist <- c(sfdep::critical_threshold(slopePts), 5000, 10000) # distance bands, may not work for all periods
  #upDist <- c(sfdep::critical_threshold(slopePts)) # distance bands
  #upDist <- c(5000, 10000) # distance bands
  upDistLabs <- paste0(round(upDist/1000), 'km') # distance band labels
  
  # loop for distance bands
  foreach (j= 1:length(upDist)) %do% {
    
    nb1 <- sfdep::st_dist_band(slopePts, lower = 0, upper = upDist[j])
    
    Gi <- sfdep::local_gstar_perm(slopePts$slope, nb1, nsim = 999, alternative = "two.sided")
    Gi$id <- 1:nrow(Gi)
    
    GiSpDf <- slopePts %>% inner_join(Gi)
    
    # write files as geopackage as shapefiles truncate names
    sf::write_sf(GiSpDf, paste0(outf4, periodLabs[k], "/", prefix1, "gi_gr", "_" ,upDistLabs[j], "_" , frq1, ".gpkg"), overwrite=TRUE)
    
    
  }
  
}


 foreach (k= 1:4) %do% {
  
  slopePts0 <- as.points(terra::rast(rslopes[k]), values=TRUE, na.rm=TRUE, na.all=FALSE)
  slopePts0$id <- 1:nrow(slopePts0)
  names(slopePts0) <- c("slope", "id")
  #terra::writeVector(slopepts4, paste0(outf4, periodLabs[k], "/", prefix1, "slopeptsp4", "_" , frq1, ".shp"), options="ENCODING=UTF-8", overwrite=TRUE)
  
  
  # using sfdep
  slopePts <- sf::st_as_sf(slopePts0)
  
  slopePts <- slopePts[slopePts$slope<0, ]
  slopePts$slope <- slopePts$slope*-1.0 # Invert sign of slope
  slopePts$id <- 1:nrow(slopePts)
  
  upDist <- c(sfdep::critical_threshold(slopePts), 5000, 10000) # distance bands
  #upDist <- c(sfdep::critical_threshold(slopePts)) # distance bands
  #upDist <- c(50000, 100000) # distance bands
  upDistLabs <- paste0(round(upDist/1000), 'km') # distance band labels
  
  # loop for distance bands
  foreach (j= 1:length(upDist)) %do% {
    
    nb1 <- sfdep::st_dist_band(slopePts, lower = 0, upper = upDist[j])
    
    Gi <- sfdep::local_gstar_perm(slopePts$slope, nb1, nsim = 999, alternative = "two.sided")
    Gi$id <- 1:nrow(Gi)
    
    GiSpDf <- slopePts %>% inner_join(Gi)
    
    # write files as geopackage as shapefiles truncate names
    sf::write_sf(GiSpDf, paste0(outf4, periodLabs[k], "/", prefix1, "gi_br", "_" ,upDistLabs[j], "_" , frq1, ".gpkg"), overwrite=TRUE)
    
    
  }
  
}


#-----------------------------
# Create plots
#-----------------------------

# Ref:
# https://rpubs.com/heatherleeleary/hotspot_getisOrd_tut

# Note: This may work better with polygons and fewer records.
# Not run yet

# Create a new data frame called 'tes_hot_spots"
# GiL1[[1]] |> 
#   # with the columns 'gi' and 'p_folded_sim"
#   # 'p_folded_sim' is the p-value of a folded permutation test
#   select(gi_star, p_folded_sim) |> 
#   dplyr::mutate(
#     # Add a new column called "classification"
#     classification = case_when(
#       # Classify based on the following criteria:
#       gi_star > 0 & p_folded_sim <= 0.01 ~ "Very hot",
#       gi_star > 0 & p_folded_sim <= 0.05 ~ "Hot",
#       gi_star > 0 & p_folded_sim <= 0.1 ~ "Somewhat hot",
#       gi_star < 0 & p_folded_sim <= 0.01 ~ "Very cold",
#       gi_star < 0 & p_folded_sim <= 0.05 ~ "Cold",
#       gi_star < 0 & p_folded_sim <= 0.1 ~ "Somewhat cold",
#       TRUE ~ "Insignificant"
#     ),
#     # Convert 'classification' into a factor for easier plotting
#     classification = factor(
#       classification,
#       levels = c("Very hot", "Hot", "Somewhat hot",
#                  "Insignificant",
#                  "Somewhat cold", "Cold", "Very cold")
#     )
#   ) |> 
#   # Visualize the results with ggplot2
#   ggplot(aes(fill = classification)) +
#   geom_sf(color = "black", lwd = 0.1) +
#   scale_fill_brewer(type = "div", palette = 5) +
#   theme_void() +
#   labs(
#     fill = "Hot Spot Classification",
#     title = "Forest EVI 5-year trends"
#   )