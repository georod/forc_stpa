# 2025-03-07

# - Can I reliably match trend data to break dataframe created in Chapter 2. 
# - The matching will be ideal as I wouldn't not need to create a climate df from scratch

# - all raster below have dim= 481x1029 whihc reflect orginal raster SINU size
# - the different notNA values for different rasters may reflect the different bbox shp used to mask the rasters
# - The question is:  Does pixID=x in one raster correspond to the same pixID=x in another raster of the same dimension?
# - I need to do tests to make sure this is the case. If not, I run the risk of messing up the joins between the 
#   breaks+climate CSV from Ch. 2 and trend data from Ch. 3

t0 <- terra::rast("C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h5p/EVI_250m/drac/rasters/EVI_pix_16d.tif")

t1 <- terra::rast("C:/Users/Peter R/Documents/forc_stpa/output1/for_p1_merge.tif")

t2 <- terra::rast("D:/data/ClimateNA_data/version2/clim_na_bFFP_2000.tif")
t3 <- terra::rast("C:/Users/Peter R/Documents/data/gis/srtm/output/clim_na_elevation.tif")

t4 <- terra::rast("C:/Users/Peter R/Documents/forc_stpa/output1/forest_land_cover_2003_250m_v1.tif")

dim(t1)

terra::global(t1, fun="isNA")
terra::global(t1, fun="notNA") # 240,337; 269,279; 269,279; 271095
terra::global(t0, fun="notNA") # 494949=481*1029

(dim(t1)[1]*dim(t1)[2])-terra::global(t1, fun="isNA")

# Duck db CSV has
# file: C:\Users\Peter R\Desktop\duckdb\dfTemp2.csv

csv1 <- read.csv("C:/Users/Peter R/Desktop/duckdb/dfTemp2.csv")
dim(csv1)
length(unique(csv1$year))
nrow(csv1)/length(unique(csv1$year))
# 277,623
length(unique(csv1$pix)) # 277,623

# stack
stacked <- c(t0,t1,t2,t3,t4)
df <- as.data.frame(stacked, na.rm = FALSE)
names(df) <- c("pix", "p1_merge", "bFFP_2000", "elev", "forest")
summary(df)
dim(df) # 494949, 5
head(df)

df[which(df$pix==494431),]
df[which(df$pix==493403),]
df[which(df$pix==494486),]
df[which(df$pix==252695),]
df[which(df$pix==16432),]
df[which(df$pix==430694),] # This is a break (any) file:///C:/Users/Peter%20R/Documents/st_trends_for_c/algonquin/output_h5p/EVI_250m/drac/rasters/EVI_anybrk_16d.tif

# The above shows that although the nonNA number of cells differs, the pix IDs line up nicely
# I should be able to used the df above and left join break & climate data to create a nice df for XGB
# On MOnday I will do a multinomial model using p1 as predictor of p2 trend (G, B or N)
# On Monday also get a random sample of pixels to see the effect of EVI & forest age.



