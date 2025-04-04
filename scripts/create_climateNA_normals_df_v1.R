#===============================================================================
# ClimateNA normals (1960-1990) data frame for XGB
#===============================================================================

# 2025-03-13

# Notes:
# - Aim: create a df with new ClimateNA vars (climate normals). This will be joined with duckdb CSV from Chapter 2.
# - The outputs of this code become inputs for the duckdb workflow which joins different CSVs together.
# - The normal CSV created below should be useful for all periods. That is, I do not have to create period specific tables.


# Peter R.

#=================================
# Load libraries
# ================================

library(terra)
library(dplyr)


#=================================
# File paths and folders
# ================================
infolder1 <- "C:/Users/Peter R/Documents/data/gis/ClimateNA_data/normals/" 
#outf1 <- "C:/Users/Peter R/Documents/data/gis/ClimateNA_data/normals/" 
outf2 <- "~/forc_stpa/output1/data/csv_duckdb/"
outf3 <- "C:/Users/Peter R/Desktop/duckdb/"


#------------------------------------------------------
# Read csv and rasters
#------------------------------------------------------

t0 <- terra::rast("C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h5p/EVI_250m/drac/rasters/EVI_pix_16d.tif")

rClimNA <- list.files(infolder1, pattern = '*.tif$', full.names = TRUE, recursive = TRUE)

t1 <- terra::rast(rClimNA)
names(t1) <- c("CMI_sm","DD5_wt","MAP","MAT")


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
stacked <- c(t0,t1)
#stacked <- c(t0,t1)
df <- as.data.frame(stacked, na.rm = FALSE)
#names(df) <- c("pix", "p1_trend", "p2_trend","p3_trend", "p4_trend", "p1_trend_slope", "p2_trend_slope","p3_trend_slope", "p4_trend_slope", "trend_20yrs")
names(df) <- c("pix","cmi_sm_nor","dd5_wt_nor","map_nor","mat_nor")
summary(df)
dim(df) # 494949, 5
head(df)
tail(df)

csv2003 <- csv1[csv1$year==2003, ] # I used 2003 as the year but it could be any year, what I need is a single set of pixels
dim(csv2003) # [1] 277623      2


df2 <- df %>% inner_join(csv2003)
dim(df2) # 277623, 6

head(df2)
summary(df2)

hist(df2$cmi_sm_nor)

# After exploring the df with Python Jupyter notebook). I realized that cmi_sm_norm has many records with values -0.1 > x < 0 .1.
# This means that some relative measures become huge outliers. I will recode these values so that there is a cap at +- 0.1. This
# turns our to be about 60 times the normal value. The other vars seem ok.
# If I just drop these values, I will drop several hundred.  Also, cmi_sm seems to be important as it pops up in the VIF analysis

# 2025-03-21: Update I am using absolute change metrics instead of relative change metrics give the issue of outliers mentioned above.

# recode cms_sm_nor, cap at +- 0.1
dim(df2[which(df2$cmi_sm_nor >= -0.1 & df2$cmi_sm_nor <= 0.1),]) # 4707
hist(df2[which(df2$cmi_sm_nor >= -0.1 & df2$cmi_sm_nor <= 0.1), "cmi_sm_nor"])

df2$cmi_sm_nor2 <- ifelse(df2$cmi_sm_nor >= -0.1 & df2$cmi_sm_nor <= 0, -0.01, ifelse(df2$cmi_sm_nor > 0 & df2$cmi_sm_nor <= 0.1, 0.01, df2$cmi_sm_nor))

hist(df2$cmi_sm_nor2)
summary(df2)

head(df2[which(df2$cmi_sm_nor>= -0.1 & df2$cmi_sm_nor <= 0.1),], 20)
hist(df2[which(df2$cmi_sm_nor2 >= -0.1 & df2$cmi_sm_nor2 <= 0.1), "cmi_sm_nor2"])

#------------------------------------------------------
# Export data
#------------------------------------------------------

write.csv(df2, paste0(outf2, "df2_climate_normals30_v1.csv"), na="", row.names = FALSE)

df2 <- read.csv( paste0(outf2, "df2_climate_normals30_v1.csv"))
head(df2)
summary(df2)



# ChatGPT code
# Example Data
# df <- data.frame(
#   Location = c("A", "B", "C", "D"),
#   CMI_Normal = c(0.5, -0.2, 0.05, -1.5),   # Climate normal (1961-1990)
#   CMI_Contemporary = c(1.2, 0.8, 0.6, -0.5) # Contemporary CMI (2003-2022)
# )
# 
# # Define epsilon (small constant for stability)
# epsilon <- 0.1
# 
# # Compute stabilized relative CMI
# df$Relative_CMI <- (df$CMI_Contemporary - df$CMI_Normal) / 
#   pmax(abs(df$CMI_Normal), epsilon)
# 
# # Print results
# print(df)
# 
# 
# 
# #
# epsilon <- 0.1
# df2$cmi_sm_nor3 <- pmax(abs(df2$cmi_sm_nor), epsilon)
# summary(abs(df2$cmi_sm_nor))
# summary(df2)

write.csv(df2, paste0(outf2, "df2_climate_normals30_v1.csv"), na="", row.names = FALSE)

write.csv(df2, paste0(outf3, "df2_climate_normals30_v1.csv"), na="", row.names = FALSE)
