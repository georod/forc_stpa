#============================================
# Extracting ClimateNA data
#============================================

# 2025-03-13
# Code Authors:
# Peter Rodriguez

# Main aim: extract data from ClimateNA and create raster objects from ClimateNA data

# Note: 
# - ClimateNA requires an elevation model to extract data
# - Also, it requires lat & lon in WGS84
# - I tried to use a bigger buffer to minimize the number of NAs but it is too much work. Also, tt takes ClimateNA a long time (3 hs) to process the data request.
# - If I have time I could try the 1000m buffer approach
# - It seems that some of the EVI breaks which can't be assigned ClimateNA data are due to the fact that the breaks are located out of the AOI
# - I used ClimateNA gui with elevation pts to extrcat climate data
# - I used Normal_1961_1990.nrm in the gui


#===================
# Libraries
#===================

#install.packages("terra")
library(terra)
library(sqldf)
library(foreach)

#==================================
# Set folder & files paths
#==================================

#setwd("C:/Users/Peter R/Documents/ClimateNA_v731") # set the ClimateNA root directory as the working directory
#exe <- "ClimateNA_v7.31.exe"

fpath10 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h5p/EVI_250m/drac/rasters/EVI_negBrks_16d.tif"

# Digital elevation model
fpath11 <- "C:/Users/Peter R/Documents/data/gis/srtm/SRTMGL1_NC.003_SRTMGL1_DEM_doy2000042_aid0001.tif"
#fpath11 <- "C:/Users/Peter R/Documents/data/gis/srtm/version2/SRTMGL1_NC.003_SRTMGL1_DEM_doy2000042_aid0001.tif" # work in progress

outf1 <- "C:/Users/Peter R/Documents/data/gis/ClimateNA_data/normals/"
#outf1 <- "C:/Users/Peter R/Documents/data/gis/ClimateNA_data/version2/"

csv1 <- read.csv("C:/Users/Peter R/Documents/data/gis/ClimateNA_data/clim_na_r_pts.csv") # This file was created already created in Ch. 2. See line: write.csv(elevDf2, file=paste0(outf1,"/clim_na_r_pts.csv"), row.names=FALSE) 


#=================================
# Load data
#=================================

r10 <- rast(fpath10)

# Approach using raster file
# elevation is at 1 arc second resolution, about 30x30 m
rElev1 <- rast(fpath11) # WGS 84 (EPSG:4326)
#global(rElev1, fun='isNA') # 7019 NAs
#plot(rElev1)
#vect0_pj <- project(vect0, rElev1)
#plot(vect0_pj, add=T, lty=2)
#rElev11 <- crop(rElev1, vect0_pj)
#global(rElev11, fun='isNA') # 1858 NAs
fact1 <- round(dim(rElev1)[1:2] / dim(r10)[1:2]) 
rElev2 <- aggregate(rElev1, fact=fact1, fun="mean", filename="C:/Users/Peter R/Documents/data/gis/srtm/srtm_dem.tif", overwrite=FALSE)
#rElev2 <- aggregate(rElev1, fact=fact1, fun="mean", overwrite=FALSE)
#global(rElev2, fun='isNA') # 0 NAs
#rElev21 <- resample(rElev1, r10, filename="C:/Users/Peter R/Documents/data/gis/srtm/srtm_dem_v21.tif", overwrite=FALSE)

#global(rElev2, fun='isNA') # has 1865 NAs which affected data extraction
#plot(rElev2)
#plot(vect0, add=T, lty=2)

#for raster data --- Did not work!
# inputFile = '/C:\\Users\\Peter R\\Documents\\data\\gis\\srtm\\srtm_dem.asc'
# outputDir = '/C:\\Users\\Peter R\\Documents\\data\\gis\\ClimateNA_data\\test1' 
# yearPeriod = '/Normal_1961_1990.nrm'
# system2(exe, args= c('/Y', yearPeriod, inputFile, outputDir)) # I removed ,wait=True
# The above did not work. I get a run time error. Perhaps the study area is to big


#----------------------------------------------------
# CREATE csv for ClimateNA GUI
#---------------------------------------------------
# -- START --
# - This code was already create in Ch. 2. No need to create CSV at the end again.
# - I only need and use elevDf1 from the code. 
# - elevDf2 can be reloaded from CSV when needed
# - This approach uses points and CSV file
# - I need elevation data then I reproject to brk to align and get cells to line up. Interpolation will take place
# - ClimateNA requires a strange format. E.g. ID2 

rElev2 <- rast("C:/Users/Peter R/Documents/data/gis/srtm/srtm_dem.tif")

elevPts <- as.points(rElev2, values=TRUE, na.rm=FALSE, na.all=FALSE) # WGS84
class(elevPts)
head(elevPts)
summary(elevPts)
dim(elevPts)
#plot(elevPts)
elevDf1 <- as.data.frame(elevPts, row.names=NULL, optional=FALSE, geom="XY")
head(elevDf1)
summary(elevDf1)
dim(elevDf1)
names(elevDf1) <- c("el", "long", "lat")
elevDf1$ID <- 1:nrow(elevDf1)
elevDf1$ID2 <- "."
dim(elevDf1)
elevDf2 <- elevDf1[!is.na(elevDf1$el),c(4,5,3,2,1)]
head(elevDf2)
dim(elevDf2)
summary(elevDf2)
#write.csv(elevDf2[1:50,], file=paste0(outf1,"/test.csv"), row.names=FALSE)
#write.csv(elevDf2, file=paste0(outf1,"/test.csv"), row.names=FALSE) 
write.csv(elevDf2, file=paste0(outf1,"/clim_na_r_pts.csv"), row.names=FALSE) 

# -- END --

#---------------------------------------------------------
# -- START --
# This code is not needed. Code left here as a reminder
# This only worked for normal values
# inputFile = '/C:\\Users\\Peter R\\Documents\\data\\gis\\ClimateNA_data\\test.csv'
# outputFile = '/C:\\Users\\Peter R\\Documents\\data\\gis\\ClimateNA_data\\test_normal.csv'
# outputFile = '/C:\\Users\\Peter R\\Documents\\data\\gis\\ClimateNA_data\\test_hist.csv'
# yearPeriod = '/Normal_1961_1990.nrm'
# yearPeriod = '/Year_1901.ann'
# system2(exe, args= c('/Y', yearPeriod, inputFile, outputFile)) # , wait=True

#dfClim <- read.csv(paste0(outf1,"test_normal.csv"))
#dfClim <- read.csv(paste0(outf1,"test_hist.csv"))
#dfClim <- read.csv(paste0(outf1,"test_2000-2005Y.csv"))  # Multiple years in one csv. Only can be done with ClimateNA GUI
# -- END --



#------------------------------------
# Load CSV produced by ClimateNA GUI
#------------------------------------
#dfClim <- read.csv(paste0(outf1,"test_1998-2021Y.csv"))  # Multiple years in one csv. Only can be done with ClimateNA GUI
dfClim <- read.csv(paste0(outf1,"clim_na_r_pts_Normal_1961_1990SY.csv"))  # Multiple years in one csv. Only can be done with ClimateNA GUI
#historical data is about 2GB in size. I need to subset it
dim(dfClim)
head(dfClim)
tail(dfClim)

#Using historical time series, select one var across all years and turn this into a stack

#yearLab <- 1998:2005
#yearLab <- 2006:2013
#yearLab <- 2014:2021 # Climate NA only goes to 2021
#yearLab <- 1998:2021
yearLab <- 1990 # The real year is a period 1961-1990. But I used 1990 to make querying easier


# Code used in Ch. 2 but not need in climate normals workflow as it has no year column
# climL <- foreach (i=yearLab) %do% {
#             
#                 dfClim[dfClim$Year==i,c(1:2,6:7,11, 29, 30)]  
#   
#                             }
# 
# length(climL)
# head(climL[[1]])
# tail(climL[[1]])


# dfClim1 <- dfClim[,c(1,2,6:7,11)]
# str(dfClim1)
# head(dfClim1)
# tail(dfClim1)
# summary(dfClim1)


# names(dfClim)[-c(1:5)]
# vars1 <- paste0("t2.",names(dfClim)[-c(1:5)])
# vars2 <- names(dfClim)[-c(1:5)]
# vars2 <- vars2[1:5]

#dfClim1 <- do.call(rbind, climL) # Used in Ch. 2. Not needed for climate normals
dfClim1 <- dfClim
dfClim1$Year <- 1990 # 30-year climate normal

# dim(dfClim1)
# str(dfClim1)
# head(dfClim1)
# tail(dfClim1)
# summary(dfClim1)

# fields names for calling out with sqldf
#vars1 <- paste0("t2.",names(dfClim1)[-c(2,3)]) # Ch. 2
vars1 <- paste0("t2.",names(dfClim1)[-c(2:4)]) # Here I remove ID2, lat, lon and elevation


# ----------------------------------
# Load ClimateNA input CSV
#-----------------------------------
# clim_na_r_pts.csv was used to extract ClimateNA values using app's gui.
# elevDf1 is created above and has the correct dimensions needed for the code below


# here separate the year

ClimPts1L <- foreach (i=yearLab) %do% {
  
  dfClim2 <- sqldf(paste0("SELECT t1.id, t1.long, t1.lat, ", paste(vars1, collapse = ", "), " FROM elevDf1 t1 LEFT JOIN (SELECT * FROM dfClim1 WHERE Year=",i, ") t2 ON t1.ID=t2.ID"))
  
  #vect(dfClim2$Year==i, geom=c("long", "lat"), crs="EPSG:4326", keepgeom=FALSE)
  vect(dfClim2, geom=c("long", "lat"), crs="EPSG:4326", keepgeom=FALSE)
 
  
}


# lapply(ClimPts1L, dim)
# class(ClimPts1L)
# length(ClimPts1L)
# class(ClimPts1L[[1]])
# dim(ClimPts1L[[1]])
# names(ClimPts1L[[1]])
# head(ClimPts1L[[1]])
# tail(ClimPts1L[[1]])
# ClimPts1L[[1]][sample(nrow(ClimPts1L[[1]]),10),1:10]
# summary(ClimPts1L[[1]])

# ----------------------------------
# Rasterize climate points
# ----------------------------------

# Variable names to be rasterized
#vars2 <- names(ClimPts1L[[1]])[-c(1:4)] # remove ID & remove MAT & MAP as these rasters have already been created previously

# Given that from Ch. 2 I already know what variables I will use, I will only rasterize this small subset namely: DD5_wt, CMI_sm.
# I will also rasterize temp and precipitation just in case

#vars2 <- names(ClimPts1L[[1]])[-c(1:3,89)] # remove IDs, elevation & Year
vars2 <- names(ClimPts1L[[1]])[c(28,62,64,68)]


# Create climate rasters  
  foreach (i=1:length(ClimPts1L)) %do% {
  
              foreach (j=1:length(vars2)) %do% {
  
                  temp1 <- rasterize(ClimPts1L[[i]], rElev2,  fun="mean", field=vars2[j]) 
  
                  project(temp1, r10, method='bilinear', threads=TRUE, filename=paste0(outf1, "clim_na","_" ,vars2[j], "_", yearLab[i],".tif"), overwrite=F)
  
              }
  
  }
  

#length(rClimL)
#length(rClimL[[1]])
#(rClimL[[1]])

#rast("~/data/gis/ClimateNA_data/normals/clim_na_CMI_sm_1990.tif") # Tif seems ok


#---------------------------------------------
# Calculate study area normals
#---------------------------------------------

# - In order to get regional (study area) metrics. I can estimate the mean, median, etc.
# - Then I can compare raster values to the pixel median/mean and regional median/mean
# - I will get the stats from the raster created above
# - I will mask the rast with study area bbox before create stats just to be more precise. However, it seems the mask is not needed given that I used the correct raster template above (r10)
# - Note that although the name of the file states 1990, the data represent normals from 1961 to 1990.
# - I have copy/paste summaries in EXcel. See trends_summary_tabs_v1.xlsx
  
#shp1 <- "~/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_pj.shp"
  
#bbox_pj <- vect(shp1)  

# DDR_wt
rdd5_wt <- rast("~/data/gis/ClimateNA_data/normals/clim_na_DD5_wt_1990.tif")
plot(rdd5_wt)
plot(bbox_pj, add=TRUE)
#summary(mask(rdd5_wt, bbox_pj))
table(summary(rdd5_wt))

# CMI_sm
rcmi_sm <- rast("~/data/gis/ClimateNA_data/normals/clim_na_CMI_sm_1990.tif")
summary(rcmi_sm)

# CMI_sm
rcmi_sm <- rast("~/data/gis/ClimateNA_data/normals/clim_na_CMI_sm_1990.tif")
summary(rcmi_sm)

# Map
rmap <- rast("~/data/gis/ClimateNA_data/normals/clim_na_map_1990.tif")
summary(rmap)

# Mat
rmat <- rast("~/data/gis/ClimateNA_data/normals/clim_na_mat_1990.tif")
summary(rmat)

# Min.   	 1st Qu.	 Median 	 Mean   	 3rd Qu.	 Max.   
# DD5_wt	3	3	4	3.75	4	6
# CMI_sm	-7.1	-3.3	-1.82	-2.18	-0.96	0.85
# MAT	2.74	3.47	3.69	3.79	4.1	5.1
# MAP	816.4	878.3	927.6	923.8	966.6	1025
