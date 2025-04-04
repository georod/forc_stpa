#===============================================================================
# Create trends & disturbance plots
#===============================================================================

# 2025-04-01
# Peter R.

# Notes: 
# - Aim: create bar plots shows the association between disturbance and trends.



#=================================
# Load libraries
# ================================

library(ggplot2)

#------------------------------------------------------
# File paths and folders
# -----------------------------------------------------

#outf5 <- "C:/Users/Peter R/Documents/st_trends_for_c/algonquin/ver2/data/"

outf1 <- "C:/Users/Peter R/Documents/forc_stpa/output1/img/"
#outf2 <- "~/forc_stpa/output1/data/csv_duckdb/" # project folder
#outf3 <- "C:/Users/Peter R/Desktop/duckdb/" # Desktop
#outf4 <- "C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/"  # GitHUb
infolder1 <- "C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/"  # GitHUb



periodYrLabs <- c('2003-2007', '2008-2012', '2013-2017', '2018-2022')

csv1 <- list.files(infolder1, pattern = '*v5.csv$', full.names = TRUE, recursive = TRUE)
csv2 <- list.files(infolder1, pattern = '*v5.csv$', full.names = FALSE, recursive = TRUE)

df1 <- foreach(i=1:length(csv1), .combine=rbind) %do% {
  
  temp1 <- read.csv(csv1[i])
  temp1 <- temp1[which(temp1$elev>0),]
  temp1 <- temp1[,c("year", "gfc")]
  temp1$gfcLab <- ifelse(temp1$gfc==0, "Undisturbed", ifelse(temp1$gfc==1, "Disturbed", "Null"))
  temp1$period <- strsplit(csv2, "_")[[i]][3]
  temp1$trend <- strsplit(csv2, "_")[[i]][5]
  temp1$periodLab <- ifelse(temp1$period=='p1', periodYrLabs[1], ifelse(temp1$period=='p2',periodYrLabs[2], ifelse(temp1$period=='p3', periodYrLabs[3],periodYrLabs[4])) )
  temp1 
  
}

#head(temp1)
#str(temp1)

head(df1)
str(df1)
unique(df1$period)


# Create plot, percent of polygons relative to trend (greening or browning) area
png(file=paste0(outf1, "trends_", "disturbance_pixels_v1", ".png"),
    units = "in",
    width = 6.5,
    height = 3.5,
    res = 300)

# Colour used in QGIS
# Use position=position_dodge()
ggplot(data=df1, aes(x=gfcLab, fill=trend)) +
  geom_bar( position=position_dodge()) + ylab("Number of pixels") + xlab("Trends and disturbance") + 
  scale_fill_manual(values=c("#b96216", "#418a1c")) +
  facet_grid(~ factor(periodLab)) + theme(legend.position="bottom") + labs(fill = "Trend type:")

dev.off()



# Create plot, percent of polygons relative to trend (greening or browning) area
png(file=paste0(outf1, "trends_", "disturbance_prop_v1", ".png"),
    units = "in",
    width = 6.5,
    height = 3.5,
    res = 300)

ggplot(data=df1, aes(x=gfcLab, fill=trend)) +
  geom_bar(position="fill") + ylab("Proportion of pixels") + xlab("Trends and disturbance") + 
  scale_fill_manual(values=c("#b96216", "#418a1c")) +
  facet_grid(~ factor(periodLab)) + theme(legend.position="bottom") + labs(fill = "Trend type:")

dev.off()


