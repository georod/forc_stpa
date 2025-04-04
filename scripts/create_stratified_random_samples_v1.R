# ==============================================================================
# Stratified random sample to check the effect of imbalanced categorcal variables
# ==============================================================================

# 2025-03-25
# Peter R.



#------------------------------------------------------
# File paths and folders
# -----------------------------------------------------

#outf5 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/ver2/data/"

outf5 <- "~/forc_stpa/data/disturbance/"


fpath10 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/output_h5p/EVI_250m/drac/rasters/EVI_negBrks_16d.tif"

outf6 <- "C:/Users/Peter R/Documents/forc_stpa/data/"

outf2 <- "~/forc_stpa/output1/data/csv_duckdb/" # project folder
outf3 <- "C:/Users/Peter R/Desktop/duckdb/" # Desktop
outf4 <- "C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/"  # GitHUb


vect0 <-vect("C:/Users/Peter R/Documents/PhD/resnet/data/gis/misc/algonquin_envelope_500m_buff_v1.shp")

r10 <- rast(fpath10) # An alternative to using r2



# # Greening
# df1 <- read.csv('C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/df2_trends_p1_vars_greening_v4.csv')
# df1 <- read.csv('C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/df2_trends_p1_vars_browning_v4.csv')
# head(df1)
# df1$canlad_factor <- as.factor(df1$canlad)
# df1$gfc_factor <- as.factor(df1$gfc)
# 
# table(df1$canlad_factor)
# table(df1$gfc_factor)
# 
# dim(df1)
# 
# unique(df1$canlad_factor)
# 
# df1Stratified <- df1 %>%
#   group_by(canlad_factor) %>%
#   sample_n(size=100)
# 
# dim(df1Stratified)

#-----------------------------
# Save as CSV for Duckdb
#-----------------------------

# Lopp version


df1L <- list()

df1L[[1]] <- read.csv('C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/df2_trends_p1_vars_greening_v4.csv')
df1L[[2]] <- read.csv('C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/df2_trends_p1_vars_browning_v4.csv')

lab1 <- c("greening","browning")

foreach(i=1:length(df1L)) %do% {
  
  df1L[[i]]$canlad_factor <- as.factor(df1L[[i]]$canlad)
  
  df1Stratified <- df1L[[i]] %>%
    group_by(canlad_factor) %>%
    sample_n(size=400)
  
  print(dim(df1Stratified))
  print(head(df1Stratified[, 1:10]))
  
  write.csv(df1Stratified, paste0(outf2, "df2_trends_p1_vars_", lab1[i], "_v4_strs1.csv"), na="", row.names = FALSE)
  write.csv(df1Stratified, paste0(outf3, "df2_trends_p1_vars_", lab1[i], "_v4_strs1.csv"), na="", row.names = FALSE)  
  write.csv(df1Stratified, paste0(outf4, "df2_trends_p1_vars_", lab1[i], "_v4_strs1.csv"), na="", row.names = FALSE)  
  
}

