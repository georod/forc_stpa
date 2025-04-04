#===============================================================================
# Chapter 3 - Relationship between forest age & EVI
#===============================================================================
# 2025-03-07
# Peter R.

#  - Notes:
#   - After chatting with MJF, I create the plot below to understand the 
#     relationship between forest age and EVI. SO far this is for 2011 only
#   - There is evidence for a non-linear relationship with a peak at about 115 yrs
#   - If forest age was the main driver of the pattern, then I would expect that most 
#     of the pixels be older than 100. However, the media forest age is 90 years.
#   - Further, although the pattern detect may explain some of the 20 year trend Ns,
#     this does not explain (yet) why most of the 5-year trends are Ns as well.
#   - 5-year periods seem too little time to show the effect of forest age on greening.
#   - I used ChatGPT to develop some of the code


#=================================
# Load libraries
# ================================
library(terra)


#=================================
# File paths and folders
# ================================
outf1 <- "C:/Users/Peter R/Documents/forc_stpa/output1/img/"

# load bbox

bbox <- terra::vect("C:/Users/Peter R/Documents/st_trends_for_c/shp/algonquin_envelope_500m_buff_v1_3347.shp")

# Load rasters
raster1 <- terra::rast("C:/Users/Peter R/Documents/data/gis/modis/algonquin_v2/modistsp/VI_16Days_250m_v61/EVI/MOD13Q1_EVI_2011_161.tif")

raster1 <- terra::rast("C:/Users/Peter R/Documents/data/gis/modis/algonquin_v2/modistsp/VI_16Days_250m_v61/EVI/MOD13Q1_EVI_2019_161.tif")


raster2 <- terra::rast("C:/Users/Peter R/Documents/data/gis/algonquin/beaudoin2011_stand_age_v1.tif")


# "C:\Users\Peter R\Documents\data\gis\ont_out\ont_CA_forest_age_2019.tif"

raster2 <- terra::rast("~/st_trends_for_c/algonquin/ver2/data/gis/raster/ont_CA_forest_age_2019_masked1.tif")


# Projection
raster1 <- terra::project(raster1, "EPSG:3347")
raster2 <- terra::project(raster2, "EPSG:3347")

# Resample
raster2_resampled <- resample(raster2, raster1, method = "bilinear")


#
raster1 <- terra::ifel(raster1 < 1000, NA, raster1)
raster2_resampled <- terra::ifel(raster2_resampled < 1, NA, raster2_resampled)

# Crop and mask rasters using the study area polygon
raster1_crop <- mask(crop(raster1, bbox ), bbox)
raster2_crop <- mask(crop(raster2_resampled, bbox ), bbox)


# Stack cropped rasters and convert to a data frame
stacked <- c(raster1_crop, raster2_crop)
df <- as.data.frame(stacked, na.rm = TRUE)
summary(df)

# Compute correlation
correlation <- cor(df[,1], df[,2], use = "complete.obs")
correlation #; 0.00028

names(df) <- c("EVI", "Forest Age")

plot(df$`Forest Age`, df$EVI)
#plot(df$EVI, df$`Forest Age`)

#plot(8048-df$EVI, df$`Forest Age`)



dfSample <- df[sample(nrow(df), 1000),]
names(dfSample) <- c("EVI", "Forest Age")
#head(dfSample)

#plot(dfSample$`Forest Age`, dfSample$EVI)

# Print result
print(correlation)

library(ggplot2)
ggplot() + geom_point(aes(dfSample$`Forest Age`,dfSample$EVI)) + 
  geom_smooth(aes(dfSample$`Forest Age`,dfSample$EVI), method="lm", se=F)

png(file=paste0(outf1, "evi_forest_age_2011_v1", ".png"),
    units = "in",
    width = 6,
    height = 3.5,
    res = 300)

ggplot() + geom_point(aes(dfSample$`Forest Age`,dfSample$EVI)) + 
  geom_smooth(aes(dfSample$`Forest Age`,dfSample$EVI), method="gam", se=F) + xlab("Forest age in 2011 (years)") + ylab("EVI in mid-June 2011")

dev.off()

# But does this mean pixel trends follow this pattern given that they only cover 20 years?
# median: 90.2
# mean: 89.2
# 3rd Q: 100.7
hist(raster2_crop)
summary(raster2_crop)
# median: 90.2
# mean: 89.2
# 3rd Q: 100.7

# The plot for 2019 show almost no correlation, Linear model used instead

png(file=paste0(outf1, "evi_forest_age_2019_v1", ".png"),
    units = "in",
    width = 6,
    height = 3.5,
    res = 300)

ggplot() + geom_point(aes(dfSample$`Forest Age`,dfSample$EVI)) + 
  geom_smooth(aes(dfSample$`Forest Age`,dfSample$EVI), method="lm", se=F) + xlab("Forest age in 2019 (years)") + ylab("EVI in mid-June 2019")

dev.off()



#-----------------------------------------------------------
# MJ asked that I create reclassified maps of forest age
#-----------------------------------------------------------

rforAge2019 <- terra::rast("~/st_trends_for_c/algonquin/ver2/data/gis/raster/ont_CA_forest_age_2019_masked1.tif")
rforAge2011  <- terra::rast("C:/Users/Peter R/Documents/data/gis/algonquin/beaudoin2011_stand_age_v1.tif")
rforAge2001  <- terra::rast("C:/Users/Peter R/Documents/data/gis/algonquin/beaudoin2001_stand_age_v1.tif")

# Forest Age 2019
rforAge2019
summary(rforAge2019)
spatSample(rforAge2019, 10)

fact <- round(dim(rforAge2019)[1:2] / dim(rforAge2011)[1:2]) # high resolution raster / low resolution raster. Proj does not need to be the same but shoudl be equivalent extents

rforAge2019Agg <- aggregate(rforAge2019, fact, modal, na.rm=T) # na.rm=T is key because terra is couting NAs. Better use fun="modal"


# Reclassification matrix
# 20 yr age classes
m12 <-  c(0, 20, 1,
          20, 40, 2,
          40, 60, 3,
          60, 80, 4,
          80, 100, 5,
          100, 120, 6,
          120, 140, 7,
          140, 200, 8) # This is in fact the class 140+, after classifying 130+


rclM12 <- matrix(m12, ncol=3, byrow=TRUE)

rforAge2011 <- classify(rforAge2011, rclM12, include.lowest=FALSE)

plot(rforAge2011)

rforAge2001 <- classify(rforAge2001, rclM12, include.lowest=FALSE)


rforAge2019Agg <- classify(rforAge2019Agg, rclM12, include.lowest=FALSE)
rforAge2019_30m <- classify(rforAge2019, rclM12, include.lowest=FALSE)


fpath1 <- "~/st_trends_for_c/algonquin/version3/gis/"


writeRaster(rforAge2, paste0(fpath1,"reclass_forest_age_2011_v1.tif"), overwrite=T)

writeRaster(rforAge2001, paste0(fpath1,"reclass_forest_age_2001_v1.tif"), overwrite=T)

writeRaster(rforAge2019_30m, paste0(fpath1,"reclass_forest_age_2019_30m_v1.tif"), overwrite=T)

