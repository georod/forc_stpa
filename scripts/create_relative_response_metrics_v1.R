# ==============================================================================
# Calculate relative response metrics
# ==============================================================================

# 2025-03-27
# Peter R.

# NOtes:
# - Easier to do with R than with DuckDB
# - The XGBoost model should not be absolute as the negative values should help differentiate
# - I was hoping that this new metric (p1_trend_slope_rel) would help visualize better but it did it.
# - I will stop creating df2_trends_p1_vars_browning_v6.csv in future runs.

#------------------------------------------------------
# File paths and folders
# -----------------------------------------------------

#outf5 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/ver2/data/"

outf2 <- "~/forc_stpa/output1/data/csv_duckdb/" # project folder
outf3 <- "C:/Users/Peter R/Desktop/duckdb/" # Desktop
outf4 <- "C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/"  # GitHUb


#=================================
# Load libraries
# ================================

#library(terra)
#library(dplyr)

#library(sqldf)

library(foreach)


# test1 <- read.csv('C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/df2_trends_p1_vars_browning_v5.csv')
# head(test1)
# 
# hist(test1$p1_trend_slope*-1)
# 
# median(test1$p1_trend_slope)
# mean(test1$p1_trend_slope)
# IQR(test1$p1_trend_slope)
# 
# hist(((test1$p1_trend_slope-(-4.48))/1.614))
# hist(((test1$p1_trend_slope-(median(test1$p1_trend_slope)))/IQR(test1$p1_trend_slope)))
# 
# test1$p1_trend_slope_rel <- ((test1$p1_trend_slope-(median(test1$p1_trend_slope)))/IQR(test1$p1_trend_slope))
# hist(test1$p1_trend_slope_rel)
# 
# test2 <- read.csv('C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/df2_trends_p1_vars_greening_v5.csv')
# hist(log(test2$p1_trend_slope))
# 
# 
# median(test2$p1_trend_slope)
# mean(test2$p1_trend_slope)
# IQR(test2$p1_trend_slope)
# test2$p1_trend_slope_rel <- ((test2$p1_trend_slope-(median(test2$p1_trend_slope)))/IQR(test2$p1_trend_slope))
# hist(test2$p1_trend_slope_rel)


df1L <- list()

df1L[[1]] <- read.csv('C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/df2_trends_p1_vars_greening_v5.csv')
df1L[[2]] <- read.csv('C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/df2_trends_p1_vars_browning_v5.csv')

lab1 <- c("greening","browning")

foreach(i=1:length(df1L)) %do% {
  
  temp1 <- df1L[[i]]
  #median(test2$p1_trend_slope)
  #mean(test2$p1_trend_slope)
  #IQR(test2$p1_trend_slope)
  temp1$p1_trend_slope_rel <- ((temp1$p1_trend_slope-(median(temp1$p1_trend_slope)))/IQR(temp1$p1_trend_slope))

  print(dim(temp1))
  print(head(temp1[, 1:10]))
  
  write.csv(temp1, paste0(outf2, "df2_trends_p1_vars_", lab1[i], "_v6.csv"), na="", row.names = FALSE)
  write.csv(temp1, paste0(outf3, "df2_trends_p1_vars_", lab1[i], "_v6.csv"), na="", row.names = FALSE)  
  write.csv(temp1, paste0(outf4, "df2_trends_p1_vars_", lab1[i], "_v6.csv"), na="", row.names = FALSE)  
  
}

