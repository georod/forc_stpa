#=================================================================================
# Spatio-temporal Pattern Analysis - Create Plots 3 (trend slopes)
#=================================================================================
# 2025-02-07
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


# install.packages("sfdep")
#library(sfdep)

library(ggplot2)
library(dplyr)

#setwd("C:/Users/Peter R/Documents/st_trends_for_c/algonquin") # local
setwd("/home/georod/projects/def-mfortin/georod/scripts/github/forc_stpa") # DRAC

outf4 <- "C:/Users/Peter R/Documents/forc_stpa/output1/EVI_250m/bfast01/"
#outf4 <- "/home/georod/projects/def-mfortin/georod/data/forc_stpa/output1/EVI_250m/bfast01/" 

outf1 <- "C:/Users/Peter R/Documents/forc_stpa/output1/img/"


frq1 <- "16d"
prefix1 <- c("EVI_")

periodLabs <- c("period1", "period2","period3","period4", "period5", "period6", "period7", "period8") 

r2_template <- rast("C:/Users/Peter R/Documents/st_trends_for_c/algonquin/r2_template.tif")
#r2_template <- rast("/home/georod/projects/def-mfortin/georod/data/forc_stpa/input1/algonquin/r2_template.tif") # DRAC

# rotected and non-protected forests
#  1=protected; 2=non-protected, forest n=241378. This number matches that found in my Ch. 2 summary tables
fpath3 <- "~/st_trends_for_c/algonquin/version3/gis/protected_forests_v1.tif"


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

# # Get slopes for non-pro forest
# proFor1 <- terra::subst(proFor, 2, NA)
# rslopesNonPro <- terra::mask(rast(rslopes[[1]]), proFor1) # loop it
# plot(rslopesNonPro, col=rainbow(10) ) 
# 
# # Get slopes for pro forest
# proFor2 <- terra::subst(proFor, 1, NA)
# rslopesPro <- terra::mask(rast(rslopes[[1]]), proFor2)
# plot(rslopesPro, col=rainbow(10) ) 


#-------------------------------------------------------
# Labels needed for files, folders, plots, etc.
#-------------------------------------------------------

# labels for plots
chPerLabs <- c("Period 1 vs. 2", "Period 2 vs. 3", "Period 3 vs. 4")

# labels for folder & files names
trendLabs <- c("greening", "browning")

trendChangeLabs <- c("cont", "disa", "expn", "genr", "stbl")

periodYrLabs <- c('2003-2007', '2008-2012', '2013-2017', '2018-2022')
periodYrLabs2 <- c('Period 1 vs. 2', 'Period 2 vs. 3', 'Period 3 vs. 4')
periodYrLabs3 <- c('1 vs. 2', '2 vs. 3', '3 vs. 4')
periodLabs <- 1:4

statusLab <- c("Non-protected", "Protected")


statusLab2 <- c("Non-protected", "Non-protected","Protected", "Protected")
slopeLabs2 <- c("Positive","Negative", "Positive", "Negative")


#---------

rslopesStatusL <- foreach (i= 1:length(rslopes)) %do% {
  
  # Get slopes for non-pro forest
  proFor1 <- terra::subst(proFor, 2, NA)
  rslopesNonPro <- terra::mask(rast(rslopes[[i]]), proFor1) # loop it
  #plot(rslopesNonPro, col=rainbow(10) ) 
  rslopesNonProPos <- terra::ifel(rslopesNonPro <0, NA, rslopesNonPro)
  rslopesNonProNeg <- terra::ifel(rslopesNonPro >0, NA, rslopesNonPro)
  
  
  # Get slopes for pro forest
  proFor2 <- terra::subst(proFor, 1, NA)
  rslopesPro <- terra::mask(rast(rslopes[[i]]), proFor2)
  #plot(rslopesPro, col=rainbow(10) )
  rslopesProPos <- terra::ifel(rslopesPro <0, NA, rslopesPro)
  rslopesProNeg <- terra::ifel(rslopesPro >0, NA, rslopesPro)
  
  slopeTabsL <- list(rslopesNonProPos, rslopesNonProNeg, rslopesProPos, rslopesProNeg)
  
  # loop for distance bands
  foreach (j= 1:4, .combine = rbind) %do% {
    
    temp1 <- as.data.frame(slopeTabsL[[j]], cell=TRUE, na.rm=TRUE)
    names(temp1) <- c("cell", "value")
    temp1$period <-periodLabs[i] 
    temp1$status <- statusLab2[j]
    temp1$slope <- slopeLabs2[j] 
    temp1$period2 <- periodYrLabs[i]
    temp1
    
    
    # write files as geopackage as shapefiles truncate names
    #sf::write_sf(GiSpDf, paste0(outf4, periodLabs[k], "/", prefix1, "lm_grbr4", "_" ,upDistLabs[j], "_" , frq1, ".gpkg"), overwrite=TRUE)
    
    
  }
  
  #periodDF$period <- periodLabs[i] 
  #periodDF$period2 <- periodYrLabs[i] 
  #periodDf
  
}

rslopesStatus <- do.call(rbind, rslopesStatusL)



# --------------------------------------
# create plots
# --------------------------------------

# some colours
# br & gr: c("#b96216", "#418a1c")
# brown & pastel blue: c("#cb863d", "#6ea3db")
# colors from stamp map. orange & lemon green: c("#f28304","#7ee61")

#-------------------------------
# Create plot of negative slopes
png(file=paste0(outf1, "br_slope", "_pro_status_v1", ".png"),
    units = "in",
    width = 7,
    height = 3.5,
    res = 300)

theme_set(theme_bw())

ggplot(rslopesStatus[rslopesStatus$slope=='Negative',], aes(x=status, y=log(value*-1), group=status)) + 
  geom_boxplot(aes(fill=status), varwidth = TRUE)  + #  notch=TRUE
   ylab("log(|EVI negative slope|)") + xlab("Protection status") + 
  scale_fill_manual(values=c("#6ea3db","#7ee61c")) + 
   facet_grid(.~ period2) + theme(legend.position = "none") 

dev.off()


#--------------------
# CReate plot of Positive slopes
png(file=paste0(outf1, "gr_slope", "_pro_status_v1", ".png"),
    units = "in",
    width = 7,
    height = 3.5,
    res = 300)

theme_set(theme_bw())

ggplot(rslopesStatus[rslopesStatus$slope=='Positive',], aes(x=status, y=log(value), group=status)) + 
  geom_boxplot(aes(fill=status), varwidth = TRUE)  + #  notch=TRUE
  ylab("log(EVI positive slope)") + xlab("Protection status") + 
  scale_fill_manual(values=c("#6ea3db","#7ee61c")) + 
  facet_grid(.~ period2) + theme(legend.position = "none") 

dev.off()
