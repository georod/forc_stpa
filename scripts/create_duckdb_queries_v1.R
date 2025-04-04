# ==============================================================================
# Create queries for executing with DuckDB
# ==============================================================================

# 2025-03-29
# Peter R.

# Notes:
# - My Python Anaconda installation won't install DuckDb. SO here I use the R duckdb package instead
# - I could not get duckdb to install on Windows. However, I will use R to programatically create SQL files to run with duckdb CLI




# =================================
# Load libraries
# =================================

#install.packages("duckdb") # did not fully install
#library(terra)
#library(dplyr)

#library(sqldf)

library(foreach)


# =================================
# Folder and file paths
# =================================

setwd("C:/Users/Peter R/Desktop/duckdb/trends/")

outf2 <- "~/forc_stpa/output1/data/csv_duckdb/" # project folder
outf3 <- "C:/Users/Peter R/Desktop/duckdb/trends/" # Desktop
outf4 <- "C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/"  # GitHUb


# =================================
# Read CSVs
# =================================

# Create labels and variables

periodLabs1 <- c("period1", "period2","period3","period4") 
trendLabs1 <- c("greening","browning")


period_start_year <- c(2003, 2008, 2013, 2018)
period_end_year <- c(2007, 2012, 2017, 2022) 

lag3_period_start_year <- c(2000, 2005, 2010, 2015)

lag2_period_start_year <- lag3_period_start_year+1 

lag1_period_start_year <- lag3_period_start_year+2

#lag_end_year <- start_year #c(2003, 2008, 2013, 2018)

lag3Labs1 <- c("p1_lag3", "p2_lag3", "p3_lag3", "p4_lag3")
lag2Labs1 <- c("p1_lag2", "p2_lag2", "p3_lag2", "p4_lag2")
lag1Labs1 <- c("p1_lag1", "p2_lag1", "p3_lag1", "p4_lag1")


# -------------------------------------------------------
# Create template df on which to link/join other vars
# -------------------------------------------------------

# Notes:
#  - The join by year is not really needed as I am selected out single year records to start.
#  - This is in essence the template df to which period specific data frames will be joined.
#  - See below for the joining of all separate pieces
#  - df2_all_trends_v1.csv has all trends running wide.
#  - df2_all_pts_v3.csv was created in Chapter 2



foreach(i=1:length(periodLabs1)) %do%  {
  
# 1. Trends data with climate data for trend start year.  Climate data here is not quite useful. See other queries for more useful df.
trendCsv <- paste0("COPY (SELECT t1.*, t2.p1_trend, t2.p2_trend, t2.p3_trend, t2.p4_trend, t2.p1_trend_slope, t2.p2_trend_slope, t2.p3_trend_slope, t2.p4_trend_slope, t2.trend_20yrs FROM (SELECT pix, year, for_age, for_con, for_pro, elev, cmi_sm, cmi_sm_lag1, cmi_sm_lag2, cmi_sm_lag3, dd5_wt, dd5_wt_lag1, dd5_wt_lag2, dd5_wt_lag3 FROM 'df2_all_pts_v3.csv' WHERE year=",period_start_year[i]," ) t1 JOIN './trends/df2_all_trends_v1.csv' t2 ON t1.pix=t2.pix) TO './trends/df2_trends_p", i,"_", period_start_year[i], "_v1.csv' (HEADER);")


# 2. Average of 3-year lag (2000-2002, 2005-2007, 2010-2012, 2015-2017)
avgLagsCsv <-  paste0("COPY (SELECT pix, '3-year lag' AS label, avg(for_age) as avg_for_age, avg(for_con) as avg_for_con, avg(cmi_sm) AS avg_cmi_sm, avg(dd5_wt) AS avg_dd5_wt, min(cmi_sm) AS min_cmi_sm, min(dd5_wt) AS min_dd5_wt, max(cmi_sm) AS max_cmi_sm, max(dd5_wt) AS max_dd5_wt FROM (SELECT pix, year, for_age, for_con, for_pro, elev, cmi_sm, cmi_sm_lag1, cmi_sm_lag2, cmi_sm_lag3, dd5_wt, dd5_wt_lag1, dd5_wt_lag2, dd5_wt_lag3 FROM 'df2_all_pts_v3.csv' WHERE year >=", lag3_period_start_year[i], "and year <", lag1_period_start_year[i], ") t0 GROUP BY pix) TO './trends/df2_trends_", lag3Labs1[i], "_avg_v1.csv' (HEADER);")


# 3. Periods 3-year lag deltas (2000-2003)
lag3CSV <- paste0("COPY (SELECT t1.pix, 1 AS period, 'lag3-delta' AS label, round(t2.for_age-t1.for_age,3) AS delta_for_age_lag3, round(t2.for_con-t1.for_con,3) AS delta_for_con_lag3, round(t2.cmi_sm-t1.cmi_sm,3) AS delta_cmi_sm_lag3, round(t2.dd5_wt-t1.dd5_wt,3) AS delta_dd5_wt_lag3, round((t2.for_age-t1.for_age)/t1.for_age*100,3) AS deltap_for_age_lag3, round((t2.for_con-t1.for_con)/t1.for_con*100,3) AS deltap_for_con_lag3, round((t2.cmi_sm-t1.cmi_sm)/t1.cmi_sm*100,3) AS deltap_cmi_sm_lag3, round((t2.dd5_wt-t1.dd5_wt)/t1.dd5_wt,3) AS deltap_dd5_wt_lag3 FROM (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year =", lag3_period_start_year[i], ") t1 JOIN (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year = ",period_start_year[i],") t2 ON t1.pix=t2.pix) TO './trends/df2_trends_p", i,"_delta_lag3_v1.csv' (HEADER);")

  
# 4. Periods 2-year lag deltas (2001-2003)
lag2CSV <- paste0("COPY (SELECT t1.pix, 1 AS period, 'lag2-delta' AS label, round(t2.for_age-t1.for_age,3) AS delta_for_age_lag2, round(t2.for_con-t1.for_con,3) AS delta_for_con_lag2, round(t2.cmi_sm-t1.cmi_sm,3) AS delta_cmi_sm_lag2, round(t2.dd5_wt-t1.dd5_wt,3) AS delta_dd5_wt_lag2, round((t2.for_age-t1.for_age)/t1.for_age*100,3) AS deltap_for_age_lag2, round((t2.for_con-t1.for_con)/t1.for_con*100,3) AS deltap_for_con_lag2, round((t2.cmi_sm-t1.cmi_sm)/t1.cmi_sm*100,3) AS deltap_cmi_sm_lag2, round((t2.dd5_wt-t1.dd5_wt)/t1.dd5_wt,3) AS deltap_dd5_wt_lag2 FROM (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year =", lag2_period_start_year[i],") t1 JOIN (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year =", period_start_year[i],") t2 ON t1.pix=t2.pix) TO './trends/df2_trends_p",i, "_delta_lag2_v1.csv' (HEADER);")


# 5. Periods 1-year lag deltas (2002-2003)
lag1CSV <- paste0("COPY (SELECT t1.pix, 1 AS period, 'lag1-delta-p1' AS label, round(t2.for_age-t1.for_age,3) AS delta_for_age_lag1, round(t2.for_con-t1.for_con,3) AS delta_for_con_lag1, round(t2.cmi_sm-t1.cmi_sm,3) AS delta_cmi_sm_lag1, round(t2.dd5_wt-t1.dd5_wt,3) AS delta_dd5_wt_lag1, round((t2.for_age-t1.for_age)/t1.for_age*100,3) AS deltap_for_age_lag1, round((t2.for_con-t1.for_con)/t1.for_con*100,3) AS deltap_for_con_lag1, round((t2.cmi_sm-t1.cmi_sm)/t1.cmi_sm*100,3) AS deltap_cmi_sm_lag1, round((t2.dd5_wt-t1.dd5_wt)/t1.dd5_wt,3) AS deltap_dd5_wt_lag1 FROM (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt,  FROM 'df2_all_pts_v3.csv' WHERE year =", lag1_period_start_year[i], ") t1 JOIN (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year =", period_start_year[i], ") t2 ON t1.pix=t2.pix) TO './trends/df2_trends_p", i, "_delta_lag1_v1.csv' (HEADER);")


# 6. Change/delta metrics, year 2 minus year 1. Add relative delta. 
#    Note: for period 4, the max forest age is year=2021. I adjust the sql file manually.
deltasCSV <- paste0("COPY (SELECT t1.pix, 1 AS period, 'delta-p1' AS label, round(t2.for_age-t1.for_age,3) AS delta_for_age, round(t2.for_con-t1.for_con,3) AS delta_for_con, round(t2.cmi_sm-t1.cmi_sm,3) AS delta_cmi_sm, round(t2.dd5_wt-t1.dd5_wt,3) AS delta_dd5_wt, round((t2.for_age-t1.for_age)/t1.for_age*100,3) AS deltap_for_age, round((t2.for_con-t1.for_con)/t1.for_con*100,3) AS deltap_for_con, round((t2.cmi_sm-t1.cmi_sm)/t1.cmi_sm*100,3) AS deltap_cmi_sm, round((t2.dd5_wt-t1.dd5_wt)/t1.dd5_wt*100,3) AS deltap_dd5_wt, round(t2.map-t1.map,3) AS delta_map, round(t2.mat-t1.mat,3) AS delta_mat, round((t2.map-t1.map)/t1.map*100,3) AS deltap_map, round((t2.mat-t1.mat)/t1.mat*100,3) AS deltap_mat FROM (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt, map, mat FROM 'df2_all_pts_v3.csv' WHERE year = ",period_start_year[i],") t1 JOIN (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt, map, mat FROM 'df2_all_pts_v3.csv' WHERE year = ",period_end_year[i],") t2 ON t1.pix=t2.pix) TO './trends/df2_trends_p", i ,"_delta_v2.csv' (HEADER);")


# 7. Disturbance data
distCSV <- paste0("COPY ( SELECT pix, period, fire, harv, insc, gfc, canlad, abio, sum_gfc, sum_canlad, sum_harv, CASE WHEN gfc > 0 THEN 1 ELSE 0 END AS gfc_bin , CASE WHEN canlad > 0 THEN 1 ELSE 0 END AS canlad_bin, CASE WHEN harv > 0 THEN 1 ELSE 0 END AS harv_bin , CASE WHEN insc > 0 THEN 1 ELSE 0 END AS insc_bin, CASE WHEN abio > 0 THEN 1 ELSE 0 END AS abio_bin FROM (SELECT pix, 1 AS period, null AS fire, count(harv) AS harv, count(insc) AS insc, count(abio) AS abio, count(gfc) AS gfc, count(canlad) AS canlad, sum(gfc) AS sum_gfc, sum(canlad) AS sum_canlad, sum(harv) AS sum_harv FROM (SELECT pix, year, cast(gfc AS integer) gfc, cast(canlad AS integer) canlad , cast(harv AS integer) harv, cast(insc AS integer) insc, cast(abio AS integer) abio FROM './trends/df2_dist_for_trends_v1.csv' WHERE year >=", period_start_year[i]," and year <=",  period_end_year[i], ") t0 GROUP BY pix) t1) TO './trends/df2_trends_p",i,"_dist_v1.csv' (HEADER);")


# 8. -- #Summary negative breaks
negBrksCSV <- paste0("COPY (SELECT pix, 1 AS period, count(brk) as count_brk, round(sum(magnitude),3) AS sum_brk_magnitude, round(avg(magnitude),3) AS avg_brk_magnitude  FROM (SELECT pix, year, brk, magnitude, fire_year, harv_year, insc_year, hansen_year, canlad_year FROM 'df2_all_pts_v3.csv' WHERE year >= ", period_start_year[i], " and year <=", period_end_year[i], " AND magnitude<0) t0 GROUP BY pix) TO './trends/df2_trends_p", i, "_brk_neg_v1.csv' (HEADER);")

# 9. -- #Summary positive breaks
posBrksCSV <-  paste0("COPY (SELECT pix, 1 AS period, count(brk) as count_brk, round(sum(magnitude),3) AS sum_brk_magnitude, round(avg(magnitude),3) AS avg_brk_magnitude  FROM (SELECT pix, year, brk, magnitude, fire_year, harv_year, insc_year, hansen_year, canlad_year FROM 'df2_all_pts_v3.csv' WHERE year >=", period_start_year[i], "and year <= ",period_end_year[i], "AND magnitude>0) t0 GROUP BY pix) TO './trends/df2_trends_p",i, "_brk_pos_v1.csv' (HEADER);")


# 10. Window functions: range, coefficient of variation, Quartile based Coefficient of Variation
winCSV <- paste0("COPY (SELECT pix, 1 AS period, round(avg(for_age),3) as avg_for_age, round(avg(for_con),3) as avg_for_con, round(avg(cmi_sm),3) AS avg_cmi_sm, round(avg(dd5_wt),3) AS avg_dd5_wt, min(cmi_sm) AS min_cmi_sm, min(dd5_wt) AS min_dd5_wt, max(cmi_sm) AS max_cmi_sm, max(dd5_wt) AS max_dd5_wt, round(avg(map),3) AS avg_map, round(avg(mat),3) AS avg_mat, min(map) AS min_map, min(mat) AS min_mat, max(map) AS max_map, max(mat) AS max_mat, round(sum(map),3) as sum_map, round(stddev_pop(for_age),3) as sd_for_age, round(stddev_pop(for_con),3) as sd_for_con, round(stddev_pop(cmi_sm),3) AS sd_cmi_sm, round(stddev_pop(dd5_wt),3) AS sd_dd5_wt, round(stddev_pop(map),3) AS sd_map, round(stddev_pop(mat),3) AS sd_mat,round(median(for_age),3) as med_for_age, round(median(for_con),3) as med_for_con, round(median(cmi_sm),3) AS med_cmi_sm, round(median(dd5_wt),3) AS med_dd5_wt, round(median(map),3) AS med_map, round(median(mat),3) AS med_mat,round(quantile_cont(for_age,0.25),3) as q1_for_age, round(quantile_cont(for_con,0.25),3) as q1_for_con, round(quantile_cont(cmi_sm,0.25),3) AS q1_cmi_sm, round(quantile_cont(dd5_wt,0.25),3) AS q1_dd5_wt, round(quantile_cont(map,0.25),3) AS q1_map, round(quantile_cont(mat,0.25),3) AS q1_mat, round(quantile_cont(for_age,0.75),3) as q3_for_age, round(quantile_cont(for_con,0.75),3) as q3_for_con, round(quantile_cont(cmi_sm,0.75),3) AS q3_cmi_sm, round(quantile_cont(dd5_wt,0.75),3) AS q3_dd5_wt, round(quantile_cont(map,0.75),3) AS q3_map, round(quantile_cont(mat,0.75),3) AS q3_mat FROM (SELECT pix, year, for_age, for_con, for_pro, elev, cmi_sm, cmi_sm_lag1, cmi_sm_lag2, cmi_sm_lag3, dd5_wt, dd5_wt_lag1, dd5_wt_lag2, dd5_wt_lag3, map, mat FROM 'df2_all_pts_v3.csv' WHERE year >=", period_start_year[i], "and year <=", period_end_year[i], ") t0 GROUP BY pix) TO './trends/df2_trends_p",i, "_misc_win_v1.csv' (HEADER);")


# 11. 5-year relative metrics (pixel level). Not too useful in this context as only 5 data point but calculated anyway.
rel1CSV <- paste0("COPY (SELECT pix, period, round((max_cmi_sm-min_cmi_sm)/avg_cmi_sm,3) as cmi_sm_nrange, round((max_dd5_wt-min_dd5_wt)/avg_dd5_wt,3) as dd5_wt_nrange, round(min_cmi_sm/avg_cmi_sm,3) AS min_cmi_sm_rel, round(max_cmi_sm/avg_cmi_sm,3) AS max_cmi_sm_rel, round(min_dd5_wt/avg_dd5_wt,3) AS min_dd5_wt_rel, round(max_dd5_wt/avg_dd5_wt,3) AS max_dd5_wt_rel,round((max_map-min_map)/avg_map,3) as map_nrange, round((max_mat-min_mat)/avg_mat,3) as mat_nrange, round(min_map/avg_map,3) AS min_map_rel, round(max_map/avg_map,3) AS max_map_rel, round(min_mat/avg_mat,3) AS min_mat_rel, round(max_mat/avg_mat,3) AS max_mat_rel, round((sd_cmi_sm/(avg_cmi_sm*-1)),3) as cmi_sm_cv, round(sd_dd5_wt/avg_dd5_wt,3) as dd5_wt_cv, round((q3_cmi_sm-q1_cmi_sm)/(q3_cmi_sm+q1_cmi_sm),3) as cmi_sm_cqv, round((q3_dd5_wt-q1_dd5_wt)/(q3_dd5_wt+q1_dd5_wt),3) as dd5_wt_cqv FROM './trends/df2_trends_p", i,"_misc_win_v1.csv') TO './trends/df2_trends_p", i,"_misc_norrel_v1.csv' (HEADER);")


# 12. 5-year window metrics with 30-year normal (pixel level) data. Only absolute change for CMI and DD5 is calculated. Note: percent relative metrics for CMI produce quite big numbers.
rel2CSV <- paste0("COPY (SELECT t1.pix, t1.period, round((max_cmi_sm-min_cmi_sm)/cmi_sm_nor3,3) as cmi_sm_nrange30, round(min_cmi_sm/cmi_sm_nor3,3) AS min_cmi_sm_rel30, round(max_cmi_sm/cmi_sm_nor3,3) AS max_cmi_sm_rel30, round((max_dd5_wt-min_dd5_wt)/dd5_wt_nor,3) as dd5_wt_nrange30, round(min_dd5_wt/dd5_wt_nor,3) AS min_dd5_wt_rel30, round(max_dd5_wt/dd5_wt_nor,3) AS max_dd5_wt_rel30, round((max_map-min_map)/map_nor,3) as map_nrange30, round(min_map/map_nor,3) AS min_map_rel30, round(max_map/map_nor,3) AS max_map_rel30, round((max_mat-min_mat)/mat_nor,3) as mat_nrange30, round(min_mat/mat_nor,3) AS min_mat_rel30, round(max_mat/mat_nor,3) AS max_mat_rel30, ((avg_cmi_sm-cmi_sm_nor)) AS cmi_sm_rel30, ((avg_dd5_wt-dd5_wt_nor)) AS dd5_wt_rel30 FROM './trends/df2_trends_p",i,"_misc_win_v1.csv' t1 JOIN './trends/df2_climate_normals30_v1.csv' t2 ON t1.pix=t2.pix) TO './trends/df2_trends_p",i,"_misc_nor30_v3.csv' (HEADER);")

# 13. 5-year data window values (aggregated/summary) together with 30-year normals for the entire study area (regional median). One value per metric per study region. Median were calcualted in R.
rel3CSV <- paste0("COPY (SELECT pix, period, round((max_cmi_sm-min_cmi_sm)/abs(-2.18),3) as cmi_sm_nrange30_reg, round(min_cmi_sm/abs(-2.18),3) AS min_cmi_sm_rel30_reg, round(max_cmi_sm/abs(-2.18),3) AS max_cmi_sm_rel30_reg, round((max_dd5_wt-min_dd5_wt)/3.75,3) as dd5_wt_nrange30_reg, round(min_dd5_wt/3.75,3) AS min_dd5_wt_rel30_reg, round(max_dd5_wt/3.75,3) AS max_dd5_wt_rel30_reg, round((max_map-min_map)/923.8,3) as map_nrange30_reg, round(min_map/923.8,3) AS min_map_rel30_reg, round(max_map/923.8,3) AS max_map_rel30_reg, round((max_mat-min_mat)/3.79,3) as mat_nrange30_reg, round(min_mat/3.79,3) AS min_mat_rel30_reg, round(max_mat/3.79,3) AS max_mat_rel30_reg, 
      round((avg_cmi_sm - (-2.18)),3) AS cmi_sm_rel30_reg, round((avg_dd5_wt-3.75),3) AS dd5_wt_rel30_reg, round(((avg_cmi_sm - (-2.18))/abs(-2.18)) * 100,3) AS cmi_sm_rel30p_reg, round(((avg_dd5_wt-3.75)/3.75)*100,3) AS dd5_wt_rel30p_reg FROM './trends/df2_trends_p", i,"_misc_win_v1.csv') TO './trends/df2_trends_p", i, "_misc_nor30_reg_v1.csv' (HEADER);")

# Output queries into a .sql file for executing with Duckdb
#writeLines( c(templateCsv, avgLagsCsv, lag3CSV, lag2CSV, lag1CSV, deltasCSV, distCSV, negBrksCSV, posBrksCSV, winCSV,
#rel1CSV, rel2CSV, rel3CSV), paste0(outf3,"duck_query",i,".sql"))

writeLines( c(trendCsv, avgLagsCsv, lag3CSV, lag2CSV, lag1CSV, deltasCSV, distCSV, negBrksCSV, posBrksCSV, winCSV,
              rel1CSV, rel2CSV, rel3CSV), paste0(outf3,"duck_query_p",i,".sql"))

#writeLines( c(templateCsv ), paste0(outf3,"duck_query",i,".sql")) 
  
}



# -----------------------------------
# Joing all sepate CSVs together
#------------------------------------


foreach(i=1:length(periodLabs1)) %do%  {

allCSV <- paste0("COPY (
  SELECT t0.pix, t0.year, t0.for_age AS for_age_",period_start_year[i],", t0.for_con AS for_con_",period_start_year[i],", t0.for_pro, t0.elev, t0.p", i, "_trend, round(t0.p", i, "_trend_slope, 3) AS p", i, "_trend_slope, t0.trend_20yrs, t15.gfc_tsince_p",i," AS gfc_tsince, t15.gfc_wsum_p",i," AS gfc_wsum, t15.gfc_csum_p",i," AS gfc_csum, t1.delta_for_age_lag3, t1.delta_for_con_lag3, t1.delta_cmi_sm_lag3, t1.delta_dd5_wt_lag3, t1.deltap_for_age_lag3, t1.deltap_for_con_lag3, t1.deltap_cmi_sm_lag3, t1.deltap_dd5_wt_lag3,
  t2.avg_for_age, t2.avg_for_con, t2.avg_cmi_sm, t2.avg_dd5_wt, t2.min_cmi_sm, t2.min_dd5_wt, t2.max_cmi_sm, t2.max_dd5_wt, 
  t10.delta_for_age_lag2, t10.delta_for_con_lag2, t10.delta_cmi_sm_lag2, t10.delta_dd5_wt_lag2, t10.deltap_for_age_lag2, t10.deltap_for_con_lag2, t10.deltap_cmi_sm_lag2, t10.deltap_dd5_wt_lag2, 
  t11.delta_for_age_lag1, t11.delta_for_con_lag1, t11.delta_cmi_sm_lag1, t11.delta_dd5_wt_lag1, t11.deltap_for_age_lag1, t11.deltap_for_con_lag1, t11.deltap_cmi_sm_lag1, t11.deltap_dd5_wt_lag1, 
  t3.delta_for_age, t3.delta_for_con, t3.delta_cmi_sm, t3.delta_dd5_wt, t3.deltap_for_age, t3.deltap_for_con, t3.deltap_cmi_sm, t3.deltap_dd5_wt, 
  t4.fire, t4.harv_bin AS harv, t4.insc_bin AS insc, t4.gfc_bin AS gfc, t4.canlad_bin AS canlad, t4.abio_bin AS abio,
  ifnull(t5.count_brk,0) AS count_brk_neg, ifnull(t5.sum_brk_magnitude,0) AS sum_brk_magnitude_neg, ifnull(t5.avg_brk_magnitude,0) AS avg_brk_magnitude_neg, 
  ifnull(t6.count_brk,0) AS count_brk_pos, ifnull(t6.sum_brk_magnitude,0) AS sum_brk_magnitude_pos, ifnull(t6.avg_brk_magnitude,0) AS avg_brk_magnitude_pos, 
  t7.cmi_sm_nrange, dd5_wt_nrange, min_cmi_sm_rel, max_cmi_sm_rel, min_dd5_wt_rel,max_dd5_wt_rel, map_nrange, mat_nrange, min_map_rel, max_map_rel, min_mat_rel, max_mat_rel, cmi_sm_cv, dd5_wt_cv, cmi_sm_cqv, dd5_wt_cqv, t8.cmi_sm_nrange30, min_cmi_sm_rel30, max_cmi_sm_rel30, dd5_wt_nrange30, min_dd5_wt_rel30, max_dd5_wt_rel30, map_nrange30, 
  min_map_rel30, max_map_rel30, mat_nrange30, min_mat_rel30,max_mat_rel30, 
  t9.cmi_sm_nrange30_reg, min_cmi_sm_rel30_reg, max_cmi_sm_rel30_reg, dd5_wt_nrange30_reg, min_dd5_wt_rel30_reg, max_dd5_wt_rel30_reg, map_nrange30_reg, min_map_rel30_reg, max_map_rel30_reg, mat_nrange30_reg, min_mat_rel30_reg, max_mat_rel30_reg, cmi_sm_rel30, dd5_wt_rel30, cmi_sm_rel30_reg, dd5_wt_rel30_reg, cmi_sm_rel30p_reg, dd5_wt_rel30p_reg 
  FROM './trends/df2_trends_p",i,"_", period_start_year[i],"_v1.csv' t0 
  LEFT JOIN './trends/df2_trends_p", i, "_delta_lag3_v1.csv' t1 ON t0.pix=t1.pix 
  LEFT JOIN './trends/df2_trends_p",i,"_misc_win_v1.csv' t2 ON t0.pix=t2.pix 
  LEFT JOIN './trends/df2_trends_p",i,"_delta_lag2_v1.csv' t10 ON t0.pix=t10.pix 
  LEFT JOIN './trends/df2_trends_p",i, "_delta_lag1_v1.csv' t11 ON t0.pix=t11.pix 
  LEFT JOIN './trends/df2_trends_p", i, "_delta_v2.csv' t3 ON t0.pix=t3.pix 
  LEFT JOIN './trends/df2_trends_p", i,"_dist_v1.csv' t4 ON t0.pix=t4.pix 
  LEFT JOIN './trends/df2_trends_p", i, "_brk_neg_v1.csv' t5 ON t0.pix=t5.pix 
  LEFT JOIN './trends/df2_trends_p",i,"_brk_pos_v1.csv' t6 ON t0.pix=t6.pix 
  LEFT JOIN './trends/df2_trends_p", i, "_misc_norrel_v1.csv' t7 ON t0.pix=t7.pix 
  LEFT JOIN './trends/df2_trends_p", i, "_misc_nor30_v3.csv' t8 ON t0.pix=t8.pix 
  LEFT JOIN './trends/df2_trends_p", i, "_misc_nor30_reg_v1.csv' t9 ON t0.pix=t9.pix
  LEFT JOIN './trends/df2_dist_cumm_for_trends_v1.csv' t15 ON t0.pix=t15.pix
) TO './trends/df2_trends_p", i, "_vars_v4.csv' (HEADER);")

# Greening
gr1CSV <- paste0("COPY (SELECT * FROM './trends/df2_trends_p", i, "_vars_v4.csv' WHERE p", i,"_trend=1) TO './trends/df2_trends_p", i, "_vars_greening_v5.csv'  (HEADER);")

gr2CSV <- paste0("COPY (SELECT * FROM './trends/df2_trends_p", i, "_vars_v4.csv' WHERE p", i,"_trend=1) TO 'C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/df2_trends_p", i, "_vars_greening_v5.csv' (HEADER);")

# Browning
br1CSV <- paste0("COPY (SELECT * FROM './trends/df2_trends_p", i, "_vars_v4.csv' WHERE p", i,"_trend=2) TO './trends/df2_trends_p", i, "_vars_browning_v5.csv'  (HEADER);")

br2CSV <- paste0("COPY (SELECT * FROM './trends/df2_trends_p", i, "_vars_v4.csv' WHERE p", i,"_trend=2) TO 'C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/df2_trends_p", i, "_vars_browning_v5.csv' (HEADER);")

writeLines( c(allCSV, gr1CSV, gr2CSV, br1CSV , br2CSV), paste0(outf3,"duck_analysis_df_p",i,"_v1.sql"))

}



# to start an in-memory database
#con_duckdb <- dbConnect(duckdb(), dbdir = ":memory:")

#dbExecute(con_duckdb, createTemp1)



