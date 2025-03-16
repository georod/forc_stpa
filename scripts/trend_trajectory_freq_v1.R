#===============================================================================
# Greening and browning pixel and patch trajectories
#===============================================================================

# 2025-02-04
# Peter R.

#=================================
# Load libraries
# ================================

library(terra)
library(sf)
library(foreach)
#library(doParallel)
#library(DBI)
#library(dplyr)
#library(sqldf)
#library(raster)
#library(landscapemetrics)

library(ggplot2)
library(tidyr)
# 
# library(plyr)


#=================================
# File paths and folders
# ================================

#setwd("C:/Users/Peter R/Documents/st_trends_for_c/algonquin")
setwd("C:/Users/Peter R/Documents/forc_stpa/") # local
#setwd("~/projects/def-mfortin/georod/scripts/github/forc_stpa") # drac

dataf <- "~/projects/def-mfortin/georod/data/forc_stpa" # data folder


#infolder1 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h1yr/EVI_250m/bfast01/" # local
#infolder1 <- "~/forc_stpa/output1/change_poly"
infolder1 <- "C:/Users/Peter R/Documents/forc_stpa/output1/"
#infolder1 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/algonquin/output1/" # DRAC

#infolder2 <- "C:/Users/Peter R/Documents/forc_stpa/output1/"
#infolder2 <- "C:/Users/Peter R/Documents/forc_stpa/input1/"


# outf2 <- "C:/Users/Peter R/Documents/forc_stpa/output1/"
# outf3 <- "C:/Users/Peter R/Documents/forc_stpa/output1/gis/"
# outf4 <- "C:/Users/Peter R/Documents/forc_stpa/output1/data/"
# outf5 <- "C:/Users/Peter R/Documents/forc_stpa/output1/img/"

outf1 <- "C:/Users/Peter R/Documents/forc_stpa/output1/img/"
#outf1 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/algonquin/output1/"


# Study area bounding box
#shp1 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_pj.shp"  # This is in MODIS sinu projection
#shp1 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/algonquin/input1/shp/algonquin_envelope_500m_buff_v1_pj.shp"  # This is in MODIS sinu projection # DRAC
#shp1 <- "~/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1.shp"
#shp2 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/study_area_subset_v3.shp" # EPSG:3347

shp1 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_pj.shp"  # This is in MODIS sinu projection # local

# protected area shp
#shp2 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/ver2/data/gis/shp/cpcad_dec2020_clipped2.shp"

# Forest & non-forest in study area crop raster (bigger extent than study area)

shp4 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_pj_3978.shp"

# forest area. This did not work.
#rFor <- readRDS("~/st_trends_for_c/algonquin/output_h5p/NDVI_250m/r1Br.rds")
#plot(rFor[[1]])
#rm(rFor)

#writeRaster(rFor[[1]], paste0("C:/Users/Peter R/Documents/forc_stpa/output1/", "forest_footprint_v1.tif")) # Using NDVI

# Database connection to Postgres
#con1 <- DBI::dbConnect(RPostgres::Postgres(), dbname = "resnet1", host='localhost', port=5432, user=Sys.getenv("username"), password=Sys.getenv("pwd"))

#DBI::dbDisconnect(con1)


# Forest files
fpath2 <- "~/data/gis/algonquin/CA_forest_VLCE2_2003_algonquin_rcl2_v1.tif"  # this file was created in QGIS using a 30m lcover

# To get protected status, I will need to do the analysis twice: one for protected and the other non-protected
# Redo trajectory with this which seems better and I have used in previous chapter. Maybe not?
#  1=protected; 2=non-protected, forest n=241378. This number matches that found in my Ch. 2 summary tables
fpath3 <- "~/st_trends_for_c/algonquin/version3/gis/protected_forests_v1.tif" # 250m resolution
# Here is the 250 m one created below. No need to recreate
# 1=non-forest; 2=forest, forest n=240088
fpath4 <- paste0("C:/Users/Peter R/Documents/forc_stpa/output1/", "forest_land_cover_2003_250m_v1.tif") 



#------------------------------------------------------
# Trend polygons to raster
#------------------------------------------------------

# This can be done at the pixel level using raster or at the patch level using the spatial tables

#===================================
# Read data

files1 <- list.files(path=infolder1, recursive = TRUE, pattern = '\\.tif$', full.names=TRUE)

files1 <- files1[grep("v2", files1, fixed=T)]

#periodLabs <- c("period1", "period2","period3","period4", "period5", "period6", "period7", "period8") 
periodLabs <- c("period1", "period2","period3","period4") 

# Trend raster for each of the 4 periods
r1 <- terra::rast(files1)



# ---------------------
# Read in Land cover
# ---------------------
# Some of this code comes from C:\Users\Peter R\Documents\st_trends_for_c\algonquin\ver2\scripts\R_git\trend_breaks_create_ts_evi_v4.R

# Read land cover 2003

#rLc2 <- terra::rast(fpath2)
rLc2 <- terra::rast(fpath3) # has correct projection and extension

#rLc <- crop(rLc, project(vpolyList1[[1]],crs(rLc) )) # project vector rather than raster

# Reclassify Land cover to keep only forest
#LcType1 <- read.csv(fpath4)

#rclM2 <- as.matrix(LcType1[,c(1,3)]) # Note: I am also including wetland-treed
#rLc2 <- classify(rLc,rclM2)
#rm(rLc)


#-------------------------------
# Mask out non-forest pixels
#-------------------------------

# rLc3 <- project(rLc2, crs(r1[[1]]),  method='near', threads=TRUE)
# #rm(rLc2)
# 
# rLc3 <- resample(rLc3 , r1[[1]], method='near', threads=TRUE) # Is there a better method? I only have 1 and 0's here. method='q3' produces the same results
# 
# terra::ext(rLc3) <- terra::ext(r1[[1]])
# 
# rFor <- mask(rLc3, vect(shp1))
#rm(rLc3)

rFor <- rLc2

#plot(rFor)
#plot(vect(shp1), add=TRUE)

#writeRaster(rFor, paste0("C:/Users/Peter R/Documents/forc_stpa/output1/", "forest_land_cover_2003_250m_v1.tif"), overwrite=TRUE) 

# change non-forest to NA
rFor2 <- terra::subst(rFor, 1, NA)
rFor2 <- terra::subst(rFor, 1, 2)
#plot(rFor2, col="green")
#plot(vect(shp1), add=TRUE)

#test
#writeRaster(terra::merge(r1[[1]], rFor2),  paste0("C:/Users/Peter R/Documents/forc_stpa/output1/", "for_p1_merge.tif"), overwrite=TRUE )




# Merge Greening, Browning and forest (non-changing)
p1rFor <- terra::merge(terra::merge(r1[[1]], r1[[2]]+9), rFor2)
p2rFor <- terra::merge(terra::merge(r1[[3]], r1[[4]]+9), rFor2)
p3rFor <- terra::merge(terra::merge(r1[[5]], r1[[6]]+9), rFor2)
p4rFor <- terra::merge(terra::merge(r1[[7]], r1[[8]]+9), rFor2)

# checks
freq(p1rFor)
sum(freq(p1rFor)[,3]) #240383; with 2nd forest raster:242125
freq(r1[[1]]) # 11671
freq(r1[[2]]) # 10393
freq(rFor2) # 240088; with 2nd forest raster: 241378
global(rFor2, fun="isNA") # 254861; with 2nd forest raster: 253571
global(p1rFor, fun="isNA") # 254566; with 2nd forest raster: 252824

freq(p2rFor)
sum(freq(p2rFor)[,3]) # 240920; with 2nd forest raster: 243923
freq(r1[[3]]) # 81020
freq(r1[[4]]) # 1851
freq(rFor2) # ; 2nd: 241378
global(rFor2, fun="isNA") # 254861; with 2nd forest raster: 253571
global(p2rFor, fun="isNA") # 254029; with 2nd forest raster: 251026

freq(p3rFor)
sum(freq(p3rFor)[,3]) # 240414; 242146
freq(r1[[5]])
freq(r1[[6]])
freq(rFor2) #  240088
global(rFor2, fun="isNA") # 254861
global(p3rFor, fun="isNA") # 254535

freq(p4rFor)
sum(freq(p4rFor)[,3]) # 240414; 244233
freq(r1[[7]])
freq(r1[[8]])
freq(rFor2) #  240088
global(rFor2, fun="isNA") # 254861
global(p4rFor, fun="isNA") # 253799





#p1rFor <- terra::app(terra::sds(r1[[1]], rFor2), fun="first")

r_stack <- c(p1rFor , p2rFor , p3rFor, p4rFor)  # terra uses `c()` to combine layers

#writeRaster(r_stack, paste0("C:/Users/Peter R/Documents/forc_stpa/output1/", "pFor_stck1.tif"), overwrite=TRUE) #Stack works, checked with QGIS

# Convert the raster stack to a matrix where each row corresponds to a pixel
#pixel_values <- as.data.frame(values(r_stack))

pixel_values <- as.data.frame(r_stack, xy=TRUE, cells=TRUE, na.rm=FALSE)

# Add a pixel ID column
pixel_values$pixel_ID <- seq_len(nrow(pixel_values))
#head(pixel_values)
#pixel_values[500:700,]


# Move pixel_ID to the first column for clarity
#pixel_values <- pixel_values[, c("pixel_ID", names(pixel_values)[-length(names(pixel_values))])]


#names(pixel_values) <- c("rowid","period1", "period2", "period3", "period4")

names(pixel_values) <- c("cell","x", "y" , "period1", "period2", "period3", "period4", "rowid")

# Print first few rows to check
#head(pixel_values, 500)
#pixel_values[600:700,]

#pixel_values[11283,]

# recode values

pixel_values$period1Lab <- ifelse(pixel_values$period1==1, 'G', ifelse(pixel_values$period1==10, 'B', ifelse(pixel_values$period1==2, 'N', '')))
pixel_values$period2Lab <- ifelse(pixel_values$period2==1, 'G', ifelse(pixel_values$period2==10, 'B', ifelse(pixel_values$period2==2, 'N', '')))
pixel_values$period3Lab <- ifelse(pixel_values$period3==1, 'G', ifelse(pixel_values$period3==10, 'B', ifelse(pixel_values$period3==2, 'N', '')))
pixel_values$period4Lab <- ifelse(pixel_values$period4==1, 'G', ifelse(pixel_values$period4==10, 'B', ifelse(pixel_values$period4==2, 'N', '')))

pixel_values$trajectory <- paste0(pixel_values$period1Lab, pixel_values$period2Lab, pixel_values$period3Lab, pixel_values$period4Lab)

#pixel_values$trajectory <- ifelse(pixel_values$trajectory=='NANANANA', NA, pixel_values$trajectory)

pixel_values$trajectory2 <- grepl('NA', pixel_values$trajectory)
#names(pixel_values)

trajDf <- as.data.frame(table(pixel_values[which(pixel_values$trajectory2==FALSE), 13]))
names(trajDf) <- c("trajectory", "freq")
head(trajDf)

# I save this as pdf used Rstudion gui and then edited using Adobe Illustrator to change the colours
# should to the PDF version below
png(file=paste0(outf1, "trend_", "trajectory1_v2", ".png"),
    units = "in",
    width = 6,
    height = 3.5,
    res = 300)

theme_set(theme_bw())

ggplot(trajDf[trajDf$freq>=500,],aes(x=factor(trajectory),y=freq))+
  geom_col(color='black',fill='gray')+
  xlab('Pixel trend trajectory') + ylab('Frequency (>500)') + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

dev.off()


