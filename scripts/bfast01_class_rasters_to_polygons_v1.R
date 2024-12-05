#=================================================================================
# Spatio-temporal Pattern Analysis 
#=================================================================================
# 2024-07-30
# Peter R.

#  - Notes:
#   - This code is part of my Thesis Chapter 3
#   - Aim: Create trend patch polygons from trend class rasters (5-year periods)
#   - The code is for running locally (not DRAC). 2024-11-05: Now it works on DRAC too
#   - The main strategy:  Raster -> polygons
#   - There are 8 different types of trend classes
#   - We are looking at 4 periods: 2003-2007, 2008-2012, 2013-2017 & 2018-2022
#   - Some trend classes are not available for all periods. Mostly only classes 1 & 2 when using 5-year periods.

start.time <- Sys.time()
start.time


#=================================
# Load libraries
# ================================

library(terra)
library(sf)
library(foreach)
library(doParallel)
#library(dplyr)
#library(sqldf)



#=================================
# File paths and folders
# ================================

#setwd("C:/Users/Peter R/Documents/st_trends_for_c/algonquin")
#setwd("C:/Users/Peter R/Documents/forc_stpa/") #local

setwd("~/projects/def-mfortin/georod/scripts/github/forc_stpa") # github folder
#setwd("C:/Users/Peter R/Documents/st_trends_for_c/algonquin")

dataf <- "~/projects/def-mfortin/georod/data/forc_stpa" # data folder


#infolder1 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h1yr/EVI_250m/bfast01/" # local
infolder1 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/algonquin/output_h1yr/EVI_250m/" # DRAC

#outf1 <- "C:/Users/Peter R/Documents/forc_stpa/output1/"
outf1 <- "C:/Users/Peter R/Documents/forc_stpa/output1/"


# Study area bounding box
#shp1 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_pj.shp"  # This is in MODIS sinu projection # local
shp1 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/input1/shp/algonquin_envelope_500m_buff_v1_pj.shp"  # This is in MODIS sinu projection # DRAC

#shp2 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/study_area_subset_v3.shp" # EPSG:3347


#===================================
# Read data

files1 <- list.files(path=infolder1, recursive = TRUE, pattern = '\\.tif$', full.names=TRUE)

files1 <- files1[-grep("pix", files1, fixed=T)]

#periodLabs <- c("period1", "period2","period3","period4", "period5", "period6", "period7", "period8") 
periodLabs <- c("period1", "period2","period3","period4") 

# Trend raster for each of the 4 periods
r1 <- terra::rast(files1)

#Matrices to reclassify raster
mL <- list()
mL[[1]] <- c(1,1,1, 2,8, NA)
mL[[2]] <- c(1,1,NA, 2, 2, 1, 3,8, NA)
mL[[3]] <- c(1,2,NA, 3, 3, 1, 4,8, NA)
mL[[4]] <- c(1,3,NA, 4, 4, 1, 5,8, NA)
mL[[5]] <- c(1,4,NA, 5, 5, 1, 6,8, NA)
mL[[6]] <- c(1,5,NA, 6, 6, 1, 7,8, NA)
mL[[7]] <- c(1,6,NA, 7, 7, 1, 8,8, NA)
mL[[8]] <- c(1,7,NA, 8,8, 1)


# read bbox
#bbox <- vect(shp1)
bbox <- terra::project(vect(shp1), r1)
#bbox <- terra::project(vect(shp2), r1)

#freq(mask(r1[[k]], bbox))

# K=period, i=trend classes
rPoly <- foreach (k= 1:4) %do% {

dir.create(paste0(outf1,periodLabs[k]))
  
temp1 <- terra::crop(r1[[k]], bbox)
temp1 <- terra::mask(temp1, bbox)
  
  foreach (i=1:8) %do% {
    
    rclmat1 <- matrix(mL[[i]], ncol=3, byrow=TRUE)
    temp2  <- terra::classify(temp1[[1]], rclmat1, right=NA) # closed on right and left.
    
    temp3 <- terra::patches(temp2, directions=4, zeroAsNA=FALSE, allowGaps=TRUE)
    temp4 <- terra::as.polygons(temp3)
    temp4$period <- k
    temp4$type <- i
    
    writeVector(temp4, paste0(outf1, periodLabs[k], "/", prefix1,i, "_" , frq1, ".shp"), overwrite=TRUE)
    
    temp4
    
  }
}

#freq(temp4)


#-----------------------------------
# Check some objects
#dim(rPoly[[1]][[2]])
#head(rPoly[[1]][[1]])
#tail(rPoly[[1]][[2]])

#plot(rPoly[[1]][[2]], col="green")


#----------------------------------
# # Create plots
# # Period labels for plotting
# periodLabs2 <- c("Period 1", "Period 2","Period 3","Period 4") 
# #Trend labels
# trendLabs <- c("Greening (Gr)", "Browning (Br)", "Greening with pb", "Browning with nb", "Interruption: Gr with nb",
#                "Interruption: Br with pb", "Reversal: GrBr", "Reversal: BrGr")
# 
# #(1) monotonic increase, (2) monotonic decrease, (3) monotonic
# #increase (with positive break), (4) monotonic decrease (with negative break), (5)
# #interruption: increase with negative break, (6) interruption: decrease with positive
# #break, (7) reversal: increase to decrease, (8) reversal: decrease to increase
# 
# 
# parameter <- par(mfrow=c(2,2)) #set up the plotting space
# parameter <- plot(rPoly[[1]][[1]], col="green", 
#                    main=paste(periodLabs2[1], ", " , trendLabs[1] )) 
# parameter <- plot(rPoly[[2]][[1]], col="green", 
#                   main=paste( periodLabs2[2], ", " , trendLabs[1] )) 
# parameter <- plot(rPoly[[3]][[1]], col="green", 
#                  main=paste(periodLabs2[3], ", " , trendLabs[1] )) 
# parameter <- plot(rPoly[[4]][[1]], col="green", 
#                   main=paste(periodLabs2[4], ", " , trendLabs[1] )) 
# 
# parameter <- plot(rPoly[[1]][[2]], col="brown", 
#                   main=paste(periodLabs2[1], ", " , trendLabs[1] )) 
# parameter <- plot(rPoly[[2]][[2]], col="brown", 
#                   main=paste( periodLabs2[2], ", " , trendLabs[1] )) 
# parameter <- plot(rPoly[[3]][[2]], col="brown", 
#                   main=paste(periodLabs2[3], ", " , trendLabs[1] )) 
# parameter <- plot(rPoly[[4]][[2]], col="brown", 
#                   main=paste(periodLabs2[4], ", " , trendLabs[1] )) 



