#===============================================================================
# Greening, browning, & no-change data frame for XGB
#===============================================================================

# 2025-03-07

# Notes:
# - Aim: create a df with period trend data. This will be joined with breaks data from Ch. 2


# Peter R.

#=================================
# Load libraries
# ================================

library(terra)
library(dplyr)


#=================================
# File paths and folders
# ================================

outf2 <- "~/forc_stpa/output1/data/csv_duckdb/"



#------------------------------------------------------
# Read csv and rasters
#------------------------------------------------------

t0 <- terra::rast("C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h5p/EVI_250m/drac/rasters/EVI_pix_16d.tif")
t1 <- terra::rast("C:/Users/Peter R/Documents/forc_stpa/output1/pFor_stck1.tif") # 1=green, 10=brown, 2=forest, NA=non-forest; stack has 4 tifs
t2 <- terra::rast("C:/Users/Peter R/Documents/forc_stpa/output1/EVI_250m/bfast01/period1/EVI_sigslope_16d.tif") # slopes
t3 <- terra::rast("C:/Users/Peter R/Documents/forc_stpa/output1/EVI_250m/bfast01/period2/EVI_sigslope_16d.tif") # slopes
t4 <- terra::rast("C:/Users/Peter R/Documents/forc_stpa/output1/EVI_250m/bfast01/period3/EVI_sigslope_16d.tif") # slopes
t5 <- terra::rast("C:/Users/Peter R/Documents/forc_stpa/output1/EVI_250m/bfast01/period4/EVI_sigslope_16d.tif") # slopes
t6 <- terra::rast("C:/Users/Peter R/Documents/st_trends_for_c/algonquin/ver2/output/EVI_250m/gis/EVI_flag_type_sig_16d.tif")# 20-year slope

#t5 <- terra::rast("C:/Users/Peter R/Documents/forc_stpa/output1/forest_land_cover_2003_250m_v1.tif")

dim(t1)

#terra::global(t1, fun="isNA")
#terra::global(t1, fun="notNA") # 240,337; 269,279; 269,279; 271095
#terra::global(t0, fun="notNA") # 494949=481*1029

#(dim(t1)[1]*dim(t1)[2])-terra::global(t1, fun="isNA")

# Duck db CSV 
# file: C:\Users\Peter R\Desktop\duckdb\dfTemp2.csv was used as the reference table in Ch. 2.
# I 6940575 rows and 2 columns.  It has 277623 pixels repeated 25 (years 1998 to 2023)
csv1 <- read.csv("C:/Users/Peter R/Desktop/duckdb/dfTemp2.csv")
dim(csv1)
length(unique(csv1$year))
nrow(csv1)/length(unique(csv1$year))
# 277,623
length(unique(csv1$pix)) # 277,623

# stack
stacked <- c(t0,t1,t2,t3,t4,t5,t6)
#stacked <- c(t0,t1)
df <- as.data.frame(stacked, na.rm = FALSE)
names(df) <- c("pix", "p1_trend", "p2_trend","p3_trend", "p4_trend", "p1_trend_slope", "p2_trend_slope","p3_trend_slope", "p4_trend_slope", "trend_20yrs")
summary(df)
dim(df) # 494949, 5
head(df)

csv2003 <- csv1[csv1$year==2003, ] # I used 2003 as the year but it could be any year
dim(csv2003) # [1] 277623      2


df2 <- df %>% inner_join(csv2003)
dim(df2)

head(df2)


# recode values to make data more intuitive
# 1 green to 1 green (G)
# 10 brown to 2 brown (B)
# 2 non-change to 3 non-change (N)
# else 0

df2$p1_trend<- ifelse(df2$p1_trend==1, 1, ifelse(df2$p1_trend==10, 2, ifelse(df2$p1_trend==2, 3, NA)))
df2$p2_trend <- ifelse(df2$p2_trend==1, 1,ifelse(df2$p2_trend==10, 2, ifelse(df2$p2_trend==2, 3, NA)))
df2$p3_trend <- ifelse(df2$p3_trend==1, 1,ifelse(df2$p3_trend==10, 2, ifelse(df2$p3_trend==2, 3, NA)))
df2$p4_trend <- ifelse(df2$p4_trend==1, 1, ifelse(df2$p4_trend==10, 2, ifelse(df2$p4_trend==2, 3, NA)))

summary(df2)
dim(df2)
head(df2)

head(df2[which(df2$p1_trend==3),])

(df2[sample(nrow(df2), 10),])


#------------------------------------------------------
# Export data
#------------------------------------------------------

write.csv(df2, paste0(outf2, "df2_all_trends_v1.csv"), na="", row.names = FALSE)

