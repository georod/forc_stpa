#===============================================================================
# create disturbance rasters for Greening/Browning trends
#===============================================================================

# 2025-03-17
# Peter R.

# Aim 1: Create modified disturbance rasters for visualization purposes. See commented lines below and folder:
#    - C:\Users\Peter R\Documents\forc_stpa\data\r1Agg2018Pj.tif

# Notes:
# - The Chapter 3 version of these files were to liberal as they were meant to capture breaks (pulse disturbances)
# - The code below leaves out the adjacency function + queen contiguity
# - project is important. Now I realize that projection changes the overlap between breaks/trends and disturbances
# - Note that I am convereting 30m Landasat to 250 m rasters.  Important info is averaged away when doing so.


#=================================
# Load libraries
# ================================

library(terra)
library(dplyr)

library(sqldf)

library(foreach)


#------------------------------------------------------
# File paths and folders
# -----------------------------------------------------

#outf5 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/ver2/data/"

outf5 <- "~/forc_stpa/data/disturbance/"


fpath10 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h5p/EVI_250m/drac/rasters/EVI_negBrks_16d.tif"

outf6 <- "C:/Users/Peter R/Documents/forc_stpa/data/"

outf2 <- "~/forc_stpa/output1/data/csv_duckdb/"
outf3 <- "C:/Users/Peter R/Desktop/duckdb/"

vect0 <-vect("C:/Users/Peter R/Documents/PhD/resnet/data/gis/misc/algonquin_envelope_500m_buff_v1.shp")

r10 <- rast(fpath10) # An alternative to using r2

#----------------------
# Harvest - time series  -- Not run
#----------------------

# Original code from here: 
# C:\Users\Peter R\Documents\st_trends_for_c\algonquin\ver2\scripts\spatio-temporal_match_drivers_to_breaks_v1.R

# fpath10 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h5p/EVI_250m/drac/rasters/EVI_negBrks_16d.tif"
# 
# r1 <- rast("C:/Users/Peter R/Documents/data/gis/ont_out/ont_CA_Forest_Harvest_1985-2020.tif")
# vect0 <-vect("C:/Users/Peter R/Documents/PhD/resnet/data/gis/misc/algonquin_envelope_500m_buff_v1.shp")
# r1 <- crop(r1, project(vect0, r1)) # mask may be better here.
# r1 <-  terra::subst(r1, 0, NA)
# #plot(r1)
# 
# r1Seg <- segregate(r1, classes=c(1985:2020), keep=FALSE, other=NA, round=FALSE, digits=0)
# #plot(r1Seg[[1]])
# 
# #r1Seg <- fireSeg
# 
# r10 <- rast(fpath10)
# 
# fact <- round(dim(r1Seg)[1:2] / dim(r10)[1:2]) #NOTE: this is correct as long as the extents are equivalent (not same projection)
# 
# r1Agg <- aggregate(r1Seg, fact, sum, na.rm=TRUE)
# 
# r1AggPj <- project(r1Agg, r10,  method='near', threads=TRUE)
# #plot(r1AggPj[[1]], type="classes")
# 
# r1Res <- resample(r1AggPj, r10, method='near')
# 
# terra::ext(r1Res) <- terra::ext(r10)
# 
# # For trends, the adjacent function seems an overkill. This may explain why this factor seems so strong on the XGBoost gain plots
# cellsL <- foreach (i=1:nlyr(r1Res), .inorder=TRUE) %do%
#   adjacent(r1Res[[i]], cells=cells(r1Res[[i]]), directions="queen", pairs=FALSE, include=TRUE)
# 
# #r2Res <- r1Res
# 
# foreach (i=1:length(cellsL), .inorder=TRUE) %do%
#   {r1Res[[i]][unique(na.omit(as.vector(cellsL[[i]])))] <- 1}
# 
# r1Res
# class(r1Res)
# #plot(r2Res[[1]], col='green')
# #global(r1Res, fun="notNA")
# #global(r2Res, fun="notNA") #It works
# 
# #cells(r1Res[[1]]) # focal fire cells
# #cells(r2Res[[1]]) # focal fire cells with queen neighbors
# 
# 
# dfL1 <- foreach (i=1:nlyr(r1Res), .inorder=TRUE) %do%  {
#   
#   if (is.na(cells(r1Res[[i]])[1])) {cbind.data.frame("pix"=NA, "value"= NA, "year"= as.numeric(names(r1Res[[i]]))) } else 
#   {
#     cbind.data.frame(setNames(as.data.frame(r1Res[[i]], row.names=NULL, optional=FALSE, xy=FALSE, cells=TRUE, na.rm=NA),c("pix", "value")), "year"= as.numeric(names(r1Res[[i]])) )
#     #df0$year <- names(r2Res[[i]])
#     
#   }
# }
# 
# #head(dfL1[[1]])
# 
# #names(df0) <- c("pix", "value", "year")
# df1HarTest <- do.call(rbind, dfL1)
# #df1Har <- do.call(rbind, dfL1)
# summary(df1HarTest)
# head(df1Har)
# tail(df1Har)
# 
# #saveRDS(df1Har, paste0(outf5,"df1Har.rds"))
# df1Har <- readRDS(paste0(outf5,"df1Har.rds"))

#rm(r1Agg)
#rm(r1AggPj)



#------------------------------
# Hansen's disturbance data
#------------------------------

r1 <- rast("C:/Users/Peter R/Documents/data/gis/glad/Hansen_GFC-2022-v1.10_lossyear_50N_080W.tif")
#vect0 <-vect("C:/Users/Peter R/Documents/PhD/resnet/data/gis/misc/algonquin_envelope_500m_buff_v1.shp")
r1 <- crop(r1, project(vect0, r1))
r1 <-  terra::subst(r1, 0, NA)
#plot(r1, type="classes")
r1 <- r1+2000

#global(r1, fun="notNA") #807081 3.1% cells have disturbance
#global(r1, fun="isNA") #25'994,313

r1Seg <- segregate(r1, classes=c(2001:2022), keep=FALSE, other=NA, round=FALSE, digits=0)
#plot(r1Seg[[1]])

#r1Seg <- fireSeg
#r1Seg[[36]]


fact <- round(dim(r1Seg)[1:2] / dim(r10)[1:2]) #NOTE: this is correct as long as the extents are equivalent (not same projection)

r1Agg <- aggregate(r1Seg, fact, sum, na.rm=TRUE)
#writeRaster(r1Agg[[13]], paste0(outf6, "r1Agg2013.tif"))

r1AggPj <- project(r1Agg, r10,  method='near', threads=TRUE)
#writeRaster(r1AggPj[[14]], paste0(outf6, "r1Agg2014Pj.tif"))
#writeRaster(r1AggPj[[18]], paste0(outf6, "r1Agg2018Pj.tif"))
#plot(r1AggPj[[1]], type="classes")


#cells(r1AggPj[[i]])

r1Res <- resample(r1AggPj, r10, method='near')

terra::ext(r1Res) <- terra::ext(r10)
#plot(r1Res[[1]])


dfL1 <- foreach (i=1:nlyr(r1Res), .inorder=TRUE) %do% {
  
  if (is.na(cells(r1Res[[i]])[1])) {cbind.data.frame("pix"=NA, "value"= NA, "year"= as.numeric(names(r1Res[[i]]))) } else 
  {
    cbind.data.frame(setNames(as.data.frame(r1Res[[i]], row.names=NULL, optional=FALSE, xy=FALSE, cells=TRUE, na.rm=NA),c("pix", "value")), "year"= as.numeric(names(r1Res[[i]])) )
    #df0$year <- names(r2Res[[i]])
    
  }
}



#head(dfL1[[1]])

#names(df0) <- c("pix", "value", "year")
df1Hansen <- do.call(rbind, dfL1) # This won't work given the different col names. Use SetNames
dim(df1Hansen)
#head(df1)
#df1Fire <- df1
# summary(df1Hansen)
# head(df1Hansen)
# tail(df1Hansen)
# dim(df1Hansen)

#df1Hansen[df1Hansen$pix==22303,]

saveRDS(df1Hansen, paste0(outf5,"df1Hansen.rds"))
#df1Hansen <- readRDS(paste0(outf5,"df1Hansen.rds"))

write.csv(df1Hansen, file=paste0(outf5,"df1Hansen.csv"), row.names=FALSE, na="")

# dim(df1Hansen) # 292271, 3
# 
# df1HansenTrend[df1HansenTrend$pix==22303, ] # This good
# 
# dfTest <- as.data.frame(r1Res, cells=TRUE, na.rm = FALSE)
# head(dfTest)
# dim(dfTest)
# dfTest[dfTest$cell==22303,]
# 
# dfTest <- as.data.frame(r1AggPj, cells=TRUE, na.rm = FALSE)
# dfTest[dfTest$cell==22303,]


#-----------------------------------------
# Fire + Harvest Guidon et al. (2017) data
#------------------------------------------

# No need to create Guindon again but below are the steps used

# Run my algorithm on Guidon's data 

r1 <- rast("C:/Users/Peter R/Documents/data/gis/CanLaD/CanLaD_20151984_latest_YRT2.tif")
#vect0 <-vect("C:/Users/Peter R/Documents/PhD/resnet/data/gis/misc/algonquin_envelope_500m_buff_v1.shp")
r1 <- crop(r1, project(vect0, r1))
r1 <-  terra::subst(r1, 0, NA)
#plot(r1)

#r1Seg <- segregate(r1, classes=c(1985:2020), keep=FALSE, other=NA, round=FALSE, digits=0) # Fire, harvest, 
r1Seg <- segregate(r1, classes=c(1985:2015), keep=FALSE, other=NA, round=FALSE, digits=0) # Why only up to 2015? Mistake? NOpe if looking at Guindon.
#plot(r1Seg[[1]])

#r1Seg <- fireSeg
#r1Seg[[36]]

fact <- round(dim(r1Seg)[1:2] / dim(r10)[1:2]) #NOTE: this is correct as long as the extents are equivalent (not same projection)

r1Agg <- aggregate(r1Seg, fact, sum, na.rm=TRUE)

r1AggPj <- project(r1Agg, r10,  method='near', threads=TRUE)
#plot(r1AggPj[[1]], type="classes")


#cells(r1AggPj[[i]])

r1Res <- resample(r1AggPj, r10, method='near')

terra::ext(r1Res) <- terra::ext(r10)


dfL1 <- foreach (i=1:nlyr(r1Res), .inorder=TRUE) %do% {
  
  if (is.na(cells(r1Res[[i]])[1])) {cbind.data.frame("pix"=NA, "value"= NA, "year"= as.numeric(names(r1Res[[i]]))) } else 
  {
    cbind.data.frame(setNames(as.data.frame(r1Res[[i]], row.names=NULL, optional=FALSE, xy=FALSE, cells=TRUE, na.rm=NA),c("pix", "value")), "year"= as.numeric(names(r1Res[[i]])) )
    #df0$year <- names(r2Res[[i]])
    
  }
}


#head(dfL1[[1]])

#names(df0) <- c("pix", "value", "year")

df1Guidon <- do.call(rbind, dfL1) 
dim(df1Guidon)
#summary(df1Guidon)
#head(df1Guidon)
#tail(df1Guidon)

saveRDS(df1Guidon, paste0(outf5,"df1Guidon.rds"))
#df1Guidon <- readRDS(paste0(outf5,"df1Guidon.rds"))

#df1Guidon[df1Guidon$pix==22303, ] # This is good
write.csv(df1Guidon, file=paste0(outf5,"df1Guidon.csv"), row.names=FALSE, na="")


#-----------------------------------------
# Harvest NTEMS (30x30) data
#------------------------------------------

r1 <- rast("C:/Users/Peter R/Documents/data/gis/ont_out/ont_CA_Forest_Harvest_1985-2020.tif")
#vect0 <-vect("C:/Users/Peter R/Documents/PhD/resnet/data/gis/misc/algonquin_envelope_500m_buff_v1.shp")
r1 <- crop(r1, project(vect0, r1))
r1 <-  terra::subst(r1, 0, NA)
#plot(r1)

r1Seg <- segregate(r1, classes=c(1985:2020), keep=FALSE, other=NA, round=FALSE, digits=0)
#plot(r1Seg[[1]])

#r1Seg <- fireSeg

r10 <- rast(fpath10)

fact <- round(dim(r1Seg)[1:2] / dim(r10)[1:2]) #NOTE: this is correct as long as the extents are equivalent (not same projection)

r1Agg <- aggregate(r1Seg, fact, sum, na.rm=TRUE)

r1AggPj <- project(r1Agg, r10,  method='near', threads=TRUE)
#plot(r1AggPj[[1]], type="classes")

r1Res <- resample(r1AggPj, r10, method='near')

terra::ext(r1Res) <- terra::ext(r10)


dfL1 <- foreach (i=1:nlyr(r1Res), .inorder=TRUE) %do% {
  
  if (is.na(cells(r1Res[[i]])[1])) {cbind.data.frame("pix"=NA, "value"= NA, "year"= as.numeric(names(r1Res[[i]]))) } else 
  {
    cbind.data.frame(setNames(as.data.frame(r1Res[[i]], row.names=NULL, optional=FALSE, xy=FALSE, cells=TRUE, na.rm=NA),c("pix", "value")), "year"= as.numeric(names(r1Res[[i]])) )
    #df0$year <- names(r2Res[[i]])
    
  }
}



#head(dfL1[[1]])

#names(df0) <- c("pix", "value", "year")
df1Har <- do.call(rbind, dfL1) # This won't work given the different col names. Use SetNames
dim(df1Har)
summary(df1Har)
head(df1Har)
tail(df1Har)


#saveRDS(df1Har, paste0(outf5,"df1Har.rds"))
df1Har <- readRDS(paste0(outf5,"df1Har.rds"))

write.csv(df1Har, file=paste0(outf5,"df1Har.csv"), row.names=FALSE, na="")


#-----------------------------------------
# Disturbance polygons I data
#------------------------------------------

# Here I focus only on insects

#------------------
# Insects - Vectors to complete all years (?)
#------------------

fpath11 <- "C:/Users/Peter R/Documents/st_trends_for_c/shp/insect_algonquin_v2.shp"

insc1 <- vect(fpath11)

insc1 <- project(insc1, r10)

insc1 <- crop(insc1, r10)

inscYr <- sort(unique(insc1$EVENT_YEAR))
#inscYr <- inscYr[16:19]
#inscYr <- inscYr

rInscL <- list()

for (i in 1:length(inscYr))
{
  vect1 <- insc1[which(insc1$EVENT_YEAR == inscYr[i]), ]
  rInscL[[i]] <- rasterize(vect1, r10, field="EVENT_YEAR", background=NA, touches=TRUE,
                           update=FALSE, sum=FALSE, cover=FALSE)
  
}

#length(rInscL)
#class(rInscL[[1]])
#(rInscL[[1]])


#rInsc <- rast(rInscL)
#nlyr(rInsc)
#rm(rInscL)
#rInsc[[23]]

rInscL2 <- foreach (i=1:length(rInscL), .inorder=TRUE) %do%
  {ifel(rInscL[[i]] > 0, 1, rInscL[[i]])}

#rInscL2[[23]]
#rm(rInsc)
#rm(rInsc2)



#rInscL has year as value, rInscL2 has 1 as value. Thus, both are needed.
dfL1 <- foreach (i=1:length(rInscL2), .inorder=TRUE) %do% {
  if (is.na(cells(rInscL2[[i]])[1])) {cbind.data.frame("pix"=NA, "value"= NA, "year"= minmax(rInscL[[i]])[1] ) } else 
  {
    cbind.data.frame(setNames(as.data.frame(rInscL2[[i]], row.names=NULL, optional=FALSE, xy=FALSE, cells=TRUE, na.rm=NA),c("pix", "value")), "year"= minmax(rInscL[[i]])[1] )
    #df0$year <- names(r2Res[[i]])
  }
}


#head(dfL1[[23]]) # year=2020

#names(df0) <- c("pix", "value", "year")
df1Insc <- do.call(rbind, dfL1)
#summary(df1Insc)
#head(df1Insc)
#tail(df1Insc)
dim(df1Insc) # [1] 113474      3

#saveRDS(df1Insc, paste0(outf5,"df1Insc.rds"))
#df1Insc <- readRDS(paste0(outf5,"df1Insc.rds"))

#write.csv(df1Insc, file=paste0(outf5,"df1Insc.csv"), row.names=FALSE, na="")



#-----------------------------------------
# Abiotic disturbance polygons data
#------------------------------------------

fpath11 <- ("~/data/gis/Forest_Abiotic_Damage_Event/Forest_Abiotic_Damage_Event.shp") # These data were not used in Ch.2 (20-year breaks/trends)

abio <- vect(fpath11)
#head(abio )
#table(abio$ABIOTIC_EV)

abio2 <- project(abio, r10)
abio2 <- crop(abio2, r10)
#head(abio2)
#plot(abio2)

abioYr <- sort(unique(abio2$YEAR_OF_EV))
#inscYr <- inscYr[16:19]
#inscYr <- inscYr

rAbioL <- list()

for (i in 1:length(abioYr))
{
  vect1 <- abio2[which(abio2$YEAR_OF_EV == abioYr[i]), ]
  rAbioL[[i]] <- rasterize(vect1, r10, field="YEAR_OF_EV", background=NA, touches=TRUE,
                           update=FALSE, sum=FALSE, cover=FALSE)
  
}

#rAbioL[[19]]

rAbioL2 <- foreach (i=1:length(rAbioL), .inorder=TRUE) %do%
  {ifel(rAbioL[[i]] > 0, 1, rAbioL[[i]])}

#plot(rAbioL[[10]], col="green")
#length(rAbioL)
#rAbioL2[[19]]
#rm(rInsc)
#rm(rInsc2)

#rm(rInscL2)
#rAbioL2
  
#rInscL has year as value, rInscL2 has 1 as value. Thus, both are needed.
dfL1 <- foreach (i=1:length(rAbioL2), .inorder=TRUE) %do% {
  if (is.na(cells(rAbioL2[[i]])[1])) {cbind.data.frame("pix"=NA, "value"= NA, "year"= minmax(rAbioL[[i]])[1] ) } else 
  {
    cbind.data.frame(setNames(as.data.frame(rAbioL2[[i]], row.names=NULL, optional=FALSE, xy=FALSE, cells=TRUE, na.rm=NA),c("pix", "value")), "year"= minmax(rAbioL[[i]])[1] )
    #df0$year <- names(r2Res[[i]])
  }
}


#head(dfL1[[19]])

#names(df0) <- c("pix", "value", "year")
df1Abio <- do.call(rbind, dfL1)
#summary(df1Abio)
#head(df1Abio)
#tail(df1Abio)
# dim(df1Abio) # [1] 188690      3
table(df1Abio$year) 


saveRDS(df1Abio, paste0(outf5,"df1Abio.rds"))
#df1Abio <- readRDS(paste0(outf5,"df1Abio.rds"))

write.csv(df1Abio, file=paste0(outf5,"df1Abio.csv"), row.names=FALSE, na="")


#------------------------------------------------------
# Crete CSV for duckdb
#------------------------------------------------------

# Notes
# - Insects and abiotic disturbance come from vector data which has been rasterized to 250 m.
# - For this reason, the min/max value is 1. This means pixel had a disturbance event. 
# - Thus, insects and abiotic represent a conservative estimate.  Some small/complex polygons may have not been rasterize.

# Read RDS files created above

# Fires were not created as there are very few fires in study area

df1Hansen <- readRDS(paste0(outf5,"df1Hansen.rds"))
df1Guidon <- readRDS(paste0(outf5,"df1Guidon.rds"))
df1Harv <- readRDS(paste0(outf5,"df1Har.rds"))
df1Insc <- readRDS(paste0(outf5,"df1Insc.rds"))
df1Abio <- readRDS(paste0(outf5,"df1Abio.rds"))



# Duck db CSV 
# file: C:\Users\Peter R\Desktop\duckdb\dfTemp2.csv was used as the reference table in Ch. 2.
# It has 6940575 rows and 2 columns.  It has 277623 pixels repeated 25 (years 1998 to 2023)
csv1 <- read.csv("C:/Users/Peter R/Desktop/duckdb/dfTemp2.csv")
dim(csv1)
length(unique(csv1$year))
nrow(csv1)/length(unique(csv1$year))
# 277,623
#length(unique(csv1$pix)) # 277,623

# stack
#stacked <- c(t0,t1)
#stacked <- c(t0)
#df <- as.data.frame(stacked, na.rm = FALSE)
#names(df) <- c("pix", "p1_trend", "p2_trend","p3_trend", "p4_trend", "p1_trend_slope", "p2_trend_slope","p3_trend_slope", "p4_trend_slope", "trend_20yrs")
#names(df) <- c("pix","cmi_sm_nor","dd5_wt_nor","map_nor","mat_nor")
# names(df) <- c("pix")
# summary(df)
# dim(df) # 494949, 5
# head(df)
# tail(df)

#csv2003 <- csv1[csv1$year==2003, ] # I used 2003 as the year but it could be any year, what I need is a single set of pixels
#dim(csv2003) # [1] 277623      2


# dim(df1Hansen[df1Hansen$year<2008, ])
# df3 <- df %>% left_join(df1Hansen[ df1Hansen$year<=2007 & df1Hansen$year<=2007, ])
# dim(df3) # 277623, 6



#df4 <- csv2003 %>% left_join(df1Hansen)
#head(df4)
#dim(df4)
#dim(csv2003)

# csv2 <- csv1 %>%  left_join(df1Hansen, by = c("pix" = "pix", "year" = "year"))
# dim(csv2)
# head(csv2)
# 
# csv2 <- csv2 %>%  left_join(df1Guidon, by = c("pix" = "pix", "year" = "year"))
# names(csv2) <- c("pix","year" ,"gfc","canlad")
# summary(csv2)


csv2 <- csv1 %>%  left_join(df1Hansen, by = c("pix" = "pix", "year" = "year")) %>%  
                  left_join(df1Guidon, by = c("pix" = "pix", "year" = "year")) %>%  
                  left_join(df1Harv, by = c("pix" = "pix", "year" = "year")) %>%  
                  left_join(df1Insc, by = c("pix" = "pix", "year" = "year")) %>%  
                  left_join(df1Abio, by = c("pix" = "pix", "year" = "year"))

names(csv2) <- c("pix","year" ,"gfc","canlad", "harv", "insc", "abio")
summary(csv2)

dim(csv2)
head(csv2)

sum(csv2$insc, na.rm = T)
sum(csv2$abio, na.rm = T)
sum(csv2$gfc, na.rm = T)
sum(csv2$canlad, na.rm = T)
sum(csv2$harv, na.rm = T)

sum(df1Hansen$value)
dim(df1Hansen)

sum(df1Guidon$value)
dim(df1Guidon)

sum(df1Harv$value)
dim(df1Harv)

sum(df1Insc$value)
dim(df1Insc)

sum(df1Abio$value)
dim(df1Abio)

#plot(add=T)

#-----------------------------
# Save as CSV for Duckdb
#-----------------------------

write.csv(csv2, paste0(outf2, "df2_dist_for_trends_v1.csv"), na="", row.names = FALSE)
write.csv(csv2, paste0(outf3, "df2_dist_for_trends_v1.csv"), na="", row.names = FALSE)

