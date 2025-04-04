-- # =========================================
-- # Creating data frames for XGBoost
-- # =========================================

-- ## Peter R.
-- ## 2025-03-10


-- # ---------------------------------------------
-- # Single year pixel data frame
-- # ---------------------------------------------

-- - Notes: 
--  - Here I build a pixel-level data frame. This means each row is a pixel.
--  - This is a wide data frame, meaning that time (year) is not running down the data frame as before (Chapter 2).
-- - Period trend data is running across columns and not down the roads
-- - 2025-03-31: I created a better version of this script using R. See: C:/Users/Peter R/github/forc_stpa/scripts/create_duckdb_queries_v1.R

--  - The join by year is not really needed as I am selected out single year records to start.
--  - This is in essence the template df to which period specific data frames will be joined.
--  - See below for the joining of all separate pieces

COPY (SELECT t1.*, t2.p1_trend, t2.p2_trend, t2.p3_trend, t2.p4_trend, t2.p1_trend_slope, t2.p2_trend_slope, t2.p3_trend_slope, t2.p4_trend_slope, t2.trend_20yrs FROM (SELECT pix, year, for_age, for_con, for_pro, elev, cmi_sm, cmi_sm_lag1, cmi_sm_lag2, cmi_sm_lag3, dd5_wt, dd5_wt_lag1, dd5_wt_lag2, dd5_wt_lag3 FROM 'df2_all_pts_v3.csv' WHERE year=2003 ) t1 JOIN 'df2_all_trends_v1.csv' t2 ON t1.pix=t2.pix AND t1.year=t2.year) TO 'df2_trends_2003_v1.csv' (HEADER);


-- # ---------------------------------------------
-- # Pixel average, min, max values by period
-- # ---------------------------------------------

-- - Notes: 
--  - Here I build a pixel-level data frame. This means each row is a pixel.
--  - Each query creates a data frame for each period. I started with period 1.  I will have to repeat for periods 2 to 4.

-- ---------------------------------------------
-- 1. Period 1 average of 3-year lag (2000-2002)
COPY (SELECT pix, '3-year lag' AS label, avg(for_age) as avg_for_age, avg(for_con) as avg_for_con, avg(cmi_sm) AS avg_cmi_sm, avg(dd5_wt) AS avg_dd5_wt, min(cmi_sm) AS min_cmi_sm, min(dd5_wt) AS min_dd5_wt, max(cmi_sm) AS max_cmi_sm, max(dd5_wt) AS max_dd5_wt FROM (SELECT pix, year, for_age, for_con, for_pro, elev, cmi_sm, cmi_sm_lag1, cmi_sm_lag2, cmi_sm_lag3, dd5_wt, dd5_wt_lag1, dd5_wt_lag2, dd5_wt_lag3 FROM 'df2_all_pts_v3.csv' WHERE year >= 2000 and year<2003 ) t0 GROUP BY pix) TO 'df2_trends_p1_3yrlag_avg_v1.csv' (HEADER);

-- ---------------------------------------------
-- 2. Period 1 3-year lag deltas (2000-2003, 2001-2003, 2002-2003)
--COPY (SELECT t1.pix, 1 AS period, '3-year-lag-delta-p1' AS label, round(t2.for_age-t1.for_age,3) AS delta_for_age_lag3, round(t2.for_con-t1.for_con,3) AS delta_for_con_lag3, round(t2.cmi_sm-t1.cmi_sm,3) AS delta_cmi_sm_lag3, round(t2.dd5_wt-t1.dd5_wt,3) AS delta_dd5_wt_lag3 FROM (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year = 2000) t1 JOIN (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year = 2003) t2 ON t1.pix=t2.pix) TO 'df2_trends_p1_delta_lag3_v1.csv' (HEADER);

COPY (SELECT t1.pix, 1 AS period, '3-year-lag-delta-p1' AS label, round(t2.for_age-t1.for_age,3) AS delta_for_age_lag3, round(t2.for_con-t1.for_con,3) AS delta_for_con_lag3, round(t2.cmi_sm-t1.cmi_sm,3) AS delta_cmi_sm_lag3, round(t2.dd5_wt-t1.dd5_wt,3) AS delta_dd5_wt_lag3, round((t2.for_age-t1.for_age)/t1.for_age*100,3) AS deltap_for_age_lag3, round((t2.for_con-t1.for_con)/t1.for_con*100,3) AS deltap_for_con_lag3, round((t2.cmi_sm-t1.cmi_sm)/t1.cmi_sm*100,3) AS deltap_cmi_sm_lag3, round((t2.dd5_wt-t1.dd5_wt)/t1.dd5_wt,3) AS deltap_dd5_wt_lag3 FROM (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year = 2000) t1 JOIN (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year = 2003) t2 ON t1.pix=t2.pix) TO 'df2_trends_p1_delta_lag3_v1.csv' (HEADER);


--COPY (SELECT t1.pix, 1 AS period, '2-year-lag-delta-p1' AS label, round(t2.for_age-t1.for_age,3) AS delta_for_age_lag2, round(t2.for_con-t1.for_con,3) AS delta_for_con_lag2, round(t2.cmi_sm-t1.cmi_sm,3) AS delta_cmi_sm_lag2, round(t2.dd5_wt-t1.dd5_wt,3) AS delta_dd5_wt_lag2 FROM (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year = 2001) t1 JOIN (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year = 2003) t2 ON t1.pix=t2.pix) TO 'df2_trends_p1_delta_lag2_v1.csv' (HEADER);

COPY (SELECT t1.pix, 1 AS period, '2-year-lag-delta-p1' AS label, round(t2.for_age-t1.for_age,3) AS delta_for_age_lag2, round(t2.for_con-t1.for_con,3) AS delta_for_con_lag2, round(t2.cmi_sm-t1.cmi_sm,3) AS delta_cmi_sm_lag2, round(t2.dd5_wt-t1.dd5_wt,3) AS delta_dd5_wt_lag2, round((t2.for_age-t1.for_age)/t1.for_age*100,3) AS deltap_for_age_lag2, round((t2.for_con-t1.for_con)/t1.for_con*100,3) AS deltap_for_con_lag2, round((t2.cmi_sm-t1.cmi_sm)/t1.cmi_sm*100,3) AS deltap_cmi_sm_lag2, round((t2.dd5_wt-t1.dd5_wt)/t1.dd5_wt,3) AS deltap_dd5_wt_lag2 FROM (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year = 2001) t1 JOIN (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year = 2003) t2 ON t1.pix=t2.pix) TO 'df2_trends_p1_delta_lag2_v1.csv' (HEADER);

--COPY (SELECT t1.pix, 1 AS period, '1-year-lag-delta-p1' AS label, round(t2.for_age-t1.for_age,3) AS delta_for_age_lag1, round(t2.for_con-t1.for_con,3) AS delta_for_con_lag1, round(t2.cmi_sm-t1.cmi_sm,3) AS delta_cmi_sm_lag1, round(t2.dd5_wt-t1.dd5_wt,3) AS delta_dd5_wt_lag1 FROM (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt,  FROM 'df2_all_pts_v3.csv' WHERE year = 2002) t1 JOIN (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year = 2003) t2 ON t1.pix=t2.pix) TO 'df2_trends_p1_delta_lag1_v1.csv' (HEADER);

COPY (SELECT t1.pix, 1 AS period, '1-year-lag-delta-p1' AS label, round(t2.for_age-t1.for_age,3) AS delta_for_age_lag1, round(t2.for_con-t1.for_con,3) AS delta_for_con_lag1, round(t2.cmi_sm-t1.cmi_sm,3) AS delta_cmi_sm_lag1, round(t2.dd5_wt-t1.dd5_wt,3) AS delta_dd5_wt_lag1, round((t2.for_age-t1.for_age)/t1.for_age*100,3) AS deltap_for_age_lag1, round((t2.for_con-t1.for_con)/t1.for_con*100,3) AS deltap_for_con_lag1, round((t2.cmi_sm-t1.cmi_sm)/t1.cmi_sm*100,3) AS deltap_cmi_sm_lag1, round((t2.dd5_wt-t1.dd5_wt)/t1.dd5_wt,3) AS deltap_dd5_wt_lag1 FROM (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt,  FROM 'df2_all_pts_v3.csv' WHERE year = 2002) t1 JOIN (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year = 2003) t2 ON t1.pix=t2.pix) TO 'df2_trends_p1_delta_lag1_v1.csv' (HEADER);


-- ---------------------------------------------
-- 3. Period 1 averages, min, max values
-- This version is incomplete. see 'df2_trends_p1_misc_win_v1.csv' below which includes map and mat
--COPY (SELECT pix, 1 AS period, round(avg(for_age),3) as avg_for_age, round(avg(for_con),3) as avg_for_con, round(avg(cmi_sm),3) AS avg_cmi_sm, round(avg(dd5_wt),3) AS avg_dd5_wt, min(cmi_sm) AS min_cmi_sm, min(dd5_wt) AS min_dd5_wt, max(cmi_sm) AS max_cmi_sm, max(dd5_wt) AS max_dd5_wt FROM (SELECT pix, year, for_age, for_con, for_pro, elev, cmi_sm, cmi_sm_lag1, cmi_sm_lag2, cmi_sm_lag3, dd5_wt, dd5_wt_lag1, dd5_wt_lag2, dd5_wt_lag3 FROM 'df2_all_pts_v3.csv' WHERE year >= 2003 and year<2008 ) t0 GROUP BY pix) TO 'df2_trends_p1_avg_v1.csv' (HEADER);

-- ---------------------------------------------
-- 4. Change/delta metrics, year 2 minus year 1. Add relative delta.
--COPY (SELECT t1.pix, 'delta-p1' AS label, round(t2.for_age-t1.for_age,3) AS delta_for_age, round(t2.for_con-t1.for_con,3) AS delta_for_con, round(t2.cmi_sm-t1.cmi_sm,3) AS delta_cmi_sm, round(t2.dd5_wt-t1.dd5_wt,3) AS delta_dd5_wt FROM (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year = 2003) t1 JOIN (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt FROM 'df2_all_pts_v3.csv' WHERE year = 2007) t2 ON t1.pix=t2.pix) TO 'df2_trends_p1_delta_v1.csv' (HEADER);

-- improved deltas
-- Very high values for cmip
COPY (SELECT t1.pix, 1 AS period, 'delta-p1' AS label, round(t2.for_age-t1.for_age,3) AS delta_for_age, round(t2.for_con-t1.for_con,3) AS delta_for_con, round(t2.cmi_sm-t1.cmi_sm,3) AS delta_cmi_sm, round(t2.dd5_wt-t1.dd5_wt,3) AS delta_dd5_wt, round((t2.for_age-t1.for_age)/t1.for_age*100,3) AS deltap_for_age, round((t2.for_con-t1.for_con)/t1.for_con*100,3) AS deltap_for_con, round((t2.cmi_sm-t1.cmi_sm)/t1.cmi_sm*100,3) AS deltap_cmi_sm, round((t2.dd5_wt-t1.dd5_wt)/t1.dd5_wt*100,3) AS deltap_dd5_wt, round(t2.map-t1.map,3) AS delta_map, round(t2.mat-t1.mat,3) AS delta_mat, round((t2.map-t1.map)/t1.map*100,3) AS deltap_map, round((t2.mat-t1.mat)/t1.mat*100,3) AS deltap_mat FROM (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt, map, mat FROM 'df2_all_pts_v3.csv' WHERE year = 2003) t1 JOIN (SELECT pix, year, for_age, for_con, cmi_sm, dd5_wt, map, mat FROM 'df2_all_pts_v3.csv' WHERE year = 2007) t2 ON t1.pix=t2.pix) TO 'df2_trends_p1_delta_v2.csv' (HEADER);




-- I did not run these. They don't seem needed as I have period averages above
-- Mid-period forest values for period 1, lags may not be needed here. Modify joining year to work
-- COPY (SELECT t1.*, t2.p1_trend, t2.p2_trend, t2.p3_trend, t2.p4_trend, t2.p1_trend_slope, t2.p2_trend_slope, t2.p3_trend_slope, t2.p4_trend_slope, t2.trend_20yrs FROM (SELECT pix, year, for_age, for_con, for_pro, elev, cmi_sm, cmi_sm_lag1, cmi_sm_lag2, cmi_sm_lag3, dd5_wt, dd5_wt_lag1, dd5_wt_lag2, dd5_wt_lag3 FROM 'df2_all_pts_v3.csv' WHERE year=2005 ) t1 JOIN 'df2_all_trends_v1.csv' t2 ON t1.pix=t2.pix AND t1.year=t2.year+2) TO 'df2_trends_p1_mid_period.csv' (HEADER);


-- ---------------------------------------------
-- Disturbance
-- ---------------------------------------------

-- Aggregate disturbance data
-- brk=0, disturbance are year
--COPY (SELECT pix, 1 AS period, count(brk) as count_brk, round(sum(magnitude),3) AS sum_brk_magnitude, count(fire_year) AS fire, count(harv_year) AS harv, count(insc_year) AS insc, count(hansen_year) AS gfc, count(canlad_year) AS canlad  FROM (SELECT pix, year, brk, magnitude, fire_year, harv_year, insc_year, hansen_year, canlad_year FROM 'df2_all_pts_v3.csv' WHERE year >= 2003 and year<2008 ) t0 GROUP BY pix) TO 'df2_trends_p1_brk_dist_v1.csv' (HEADER);

-- This version uses the correct more strict disturbance data. Fire, harvest, and insect have not been calculated yet.
--COPY ( SELECT pix, period, fire, harv, insc, gfc, canlad, abio, sum_gfc, sum_canlad, sum_harv,
--CASE WHEN gfc > 0 THEN 1 ELSE 0 END AS gfc_bin , CASE WHEN canlad > 0 THEN 1 ELSE 0 END AS canlad_bin,
--CASE WHEN harv > 0 THEN 1 ELSE 0 END AS harv_bin , CASE WHEN insc > 0 THEN 1 ELSE 0 END AS insc_bin,
--CASE WHEN abio > 0 THEN 1 ELSE 0 END AS abio_bin
--FROM
--(SELECT pix, 1 AS period, null AS fire, count(harv) AS harv, count(insc) AS insc, count(abio) AS abio, count(gfc) AS gfc, count(canlad) AS canlad, sum(gfc) AS sum_gfc, sum(canlad) AS sum_canlad, sum(harv) AS sum_harv
--   FROM (SELECT pix, year, cast(gfc AS integer) gfc, cast(canlad AS integer) canlad , cast(harv AS integer) harv, cast(insc AS integer) insc, cast(abio AS integer) abio FROM 'df2_dist_for_trends_v1.csv' WHERE year >= 2003 and year<2008 ) t0 GROUP BY pix) t1) TO 'df2_trends_p1_dist_v1.csv' (HEADER);
   
COPY ( SELECT pix, period, fire, harv, insc, gfc, canlad, abio, sum_gfc, sum_canlad, sum_harv,
CASE WHEN gfc > 0 THEN 1 ELSE 0 END AS gfc_bin , CASE WHEN canlad > 0 THEN 1 ELSE 0 END AS canlad_bin,
CASE WHEN harv > 0 THEN 1 ELSE 0 END AS harv_bin , CASE WHEN insc > 0 THEN 1 ELSE 0 END AS insc_bin,
CASE WHEN abio > 0 THEN 1 ELSE 0 END AS abio_bin
FROM
(SELECT pix, 1 AS period, null AS fire, count(harv) AS harv, count(insc) AS insc, count(abio) AS abio, count(gfc) AS gfc, count(canlad) AS canlad, sum(gfc) AS sum_gfc, sum(canlad) AS sum_canlad, sum(harv) AS sum_harv
   FROM (SELECT pix, year, cast(gfc AS integer) gfc, cast(canlad AS integer) canlad , cast(harv AS integer) harv, cast(insc AS integer) insc, cast(abio AS integer) abio FROM 'df2_dist_for_trends_v1.csv' WHERE year >= 2003 and year=2007 ) t0 GROUP BY pix) t1) TO 'df2_trends_p1_dist_v1.csv' (HEADER);
   
 


-- ---------------------------------------------
-- EVI Trend breaks
-- ---------------------------------------------
-- #Summary negative breaks
COPY (SELECT pix, 1 AS period, count(brk) as count_brk, round(sum(magnitude),3) AS sum_brk_magnitude, round(avg(magnitude),3) AS avg_brk_magnitude  FROM (SELECT pix, year, brk, magnitude, fire_year, harv_year, insc_year, hansen_year, canlad_year FROM 'df2_all_pts_v3.csv' WHERE year >= 2003 and year<2008 AND magnitude<0) t0 GROUP BY pix) TO 'df2_trends_p1_brk_neg_v1.csv' (HEADER);

-- #Summary positive breaks
COPY (SELECT pix, 1 AS period, count(brk) as count_brk, round(sum(magnitude),3) AS sum_brk_magnitude, round(avg(magnitude),3) AS avg_brk_magnitude  FROM (SELECT pix, year, brk, magnitude, fire_year, harv_year, insc_year, hansen_year, canlad_year FROM 'df2_all_pts_v3.csv' WHERE year >= 2003 and year<2008 AND magnitude>0) t0 GROUP BY pix) TO 'df2_trends_p1_brk_pos_v1.csv' (HEADER);


-- ---------------------------------------------
-- Aggregated data
-- ---------------------------------------------
-- After running a first XGBoost model, the variables used so far did not explain muc.  For positive trend slopes (greening) only 13% of variance was explained. For browing it was higher around 40%.
-- Here I create new metrics that may be able to explain better positive greening trends


-- Window functions: range, coefficient of variation, Quartile based Coefficient of Variation
-- This is an improved version of 'df2_trends_p1_avg_v1.csv' (see above)
-- Adding std dev , median, q1, q3 is an overkill. I am just adding it for completion sake
-- This query will work better if looking at 20-year trend data as they will be 20 data oints. Now there is only 5 data points per period
COPY (SELECT pix, 1 AS period, round(avg(for_age),3) as avg_for_age, round(avg(for_con),3) as avg_for_con, round(avg(cmi_sm),3) AS avg_cmi_sm, round(avg(dd5_wt),3) AS avg_dd5_wt, min(cmi_sm) AS min_cmi_sm, min(dd5_wt) AS min_dd5_wt, max(cmi_sm) AS max_cmi_sm, max(dd5_wt) AS max_dd5_wt, round(avg(map),3) AS avg_map, round(avg(mat),3) AS avg_mat, min(map) AS min_map, min(mat) AS min_mat, max(map) AS max_map, max(mat) AS max_mat, round(sum(map),3) as sum_map, round(stddev_pop(for_age),3) as sd_for_age, round(stddev_pop(for_con),3) as sd_for_con, round(stddev_pop(cmi_sm),3) AS sd_cmi_sm, round(stddev_pop(dd5_wt),3) AS sd_dd5_wt, round(stddev_pop(map),3) AS sd_map, round(stddev_pop(mat),3) AS sd_mat,round(median(for_age),3) as med_for_age, round(median(for_con),3) as med_for_con, round(median(cmi_sm),3) AS med_cmi_sm, round(median(dd5_wt),3) AS med_dd5_wt, round(median(map),3) AS med_map, round(median(mat),3) AS med_mat,round(quantile_cont(for_age,0.25),3) as q1_for_age, round(quantile_cont(for_con,0.25),3) as q1_for_con, round(quantile_cont(cmi_sm,0.25),3) AS q1_cmi_sm, round(quantile_cont(dd5_wt,0.25),3) AS q1_dd5_wt, round(quantile_cont(map,0.25),3) AS q1_map, round(quantile_cont(mat,0.25),3) AS q1_mat, round(quantile_cont(for_age,0.75),3) as q3_for_age, round(quantile_cont(for_con,0.75),3) as q3_for_con, round(quantile_cont(cmi_sm,0.75),3) AS q3_cmi_sm, round(quantile_cont(dd5_wt,0.75),3) AS q3_dd5_wt, round(quantile_cont(map,0.75),3) AS q3_map, round(quantile_cont(mat,0.75),3) AS q3_mat FROM (SELECT pix, year, for_age, for_con, for_pro, elev, cmi_sm, cmi_sm_lag1, cmi_sm_lag2, cmi_sm_lag3, dd5_wt, dd5_wt_lag1, dd5_wt_lag2, dd5_wt_lag3, map, mat FROM 'df2_all_pts_v3.csv' WHERE year >= 2003 and year<2008 ) t0 GROUP BY pix) TO 'df2_trends_p1_misc_win_v1.csv' (HEADER);


-- ---------------------------------------------
-- Relative metrics using normal data
-- ---------------------------------------------
--
-- this uses 5-year data. That is only has 5 data points, not a lot of variation expected
-- This used NO normal metrics, only within pixel metrics
COPY (SELECT pix, period, round((max_cmi_sm-min_cmi_sm)/avg_cmi_sm,3) as cmi_sm_nrange, round((max_dd5_wt-min_dd5_wt)/avg_dd5_wt,3) as dd5_wt_nrange, round(min_cmi_sm/avg_cmi_sm,3) AS min_cmi_sm_rel, round(max_cmi_sm/avg_cmi_sm,3) AS max_cmi_sm_rel, round(min_dd5_wt/avg_dd5_wt,3) AS min_dd5_wt_rel, round(max_dd5_wt/avg_dd5_wt,3) AS max_dd5_wt_rel,round((max_map-min_map)/avg_map,3) as map_nrange, round((max_mat-min_mat)/avg_mat,3) as mat_nrange, round(min_map/avg_map,3) AS min_map_rel, round(max_map/avg_map,3) AS max_map_rel, round(min_mat/avg_mat,3) AS min_mat_rel, round(max_mat/avg_mat,3) AS max_mat_rel, round((sd_cmi_sm/(avg_cmi_sm*-1)),3) as cmi_sm_cv, round(sd_dd5_wt/avg_dd5_wt,3) as dd5_wt_cv, round((q3_cmi_sm-q1_cmi_sm)/(q3_cmi_sm+q1_cmi_sm),3) as cmi_sm_cqv, round((q3_dd5_wt-q1_dd5_wt)/(q3_dd5_wt+q1_dd5_wt),3) as dd5_wt_cqv FROM 'df2_trends_p1_misc_win_v1.csv') TO 'df2_trends_p1_misc_norrel_v1.csv' (HEADER);

-- this uses 30-year normals. I chnage var names manually
--COPY (SELECT t1.pix, t1.period, round((max_cmi_sm-min_cmi_sm)/cmi_sm_nor,3) as cmi_sm_nrange30, round(min_cmi_sm/cmi_sm_nor,3) AS min_cmi_sm_rel30, round(max_cmi_sm/cmi_sm_nor,3) AS max_cmi_sm_rel30, round((max_dd5_wt-min_dd5_wt)/dd5_wt_nor,3) as dd5_wt_nrange30, round(min_dd5_wt/dd5_wt_nor,3) AS min_dd5_wt_rel30, round(max_dd5_wt/dd5_wt_nor,3) AS max_dd5_wt_rel30, round((max_map-min_map)/map_nor,3) as map_nrange30, round(min_map/map_nor,3) AS min_map_rel30, round(max_map/map_nor,3) AS max_map_rel30, round((max_mat-min_mat)/mat_nor,3) as mat_nrange30, round(min_mat/mat_nor,3) AS min_mat_rel30, round(max_mat/mat_nor,3) AS max_mat_rel30 FROM 'df2_trends_p1_misc_win_v1.csv' t1 JOIN 'df2_climate_normals30_v1.csv' t2 ON t1.pix=t2.pix) TO 'df2_trends_p1_misc_nor30_v1.csv' (HEADER);

--COPY (SELECT t1.pix, t1.period, round((max_cmi_sm-min_cmi_sm)/cmi_sm_nor2,3) as cmi_sm_nrange30, round(min_cmi_sm/cmi_sm_nor2,3) AS min_cmi_sm_rel30, round(max_cmi_sm/cmi_sm_nor2,3) AS max_cmi_sm_rel30, round((max_dd5_wt-min_dd5_wt)/dd5_wt_nor,3) as dd5_wt_nrange30, round(min_dd5_wt/dd5_wt_nor,3) AS min_dd5_wt_rel30, round(max_dd5_wt/dd5_wt_nor,3) AS max_dd5_wt_rel30, round((max_map-min_map)/map_nor,3) as map_nrange30, round(min_map/map_nor,3) AS min_map_rel30, round(max_map/map_nor,3) AS max_map_rel30, round((max_mat-min_mat)/mat_nor,3) as mat_nrange30, round(min_mat/mat_nor,3) AS min_mat_rel30, round(max_mat/mat_nor,3) AS max_mat_rel30 FROM 'df2_trends_p1_misc_win_v1.csv' t1 JOIN 'df2_climate_normals30_v1.csv' t2 ON t1.pix=t2.pix) TO 'df2_trends_p1_misc_nor30_v2.csv' (HEADER);

-- this uses 5-year data aggregates together with pixel-level normal metrics. Only within pixel metrics
-- The idea here was to compare pixels to their own long-term behaviours. Are the values in period 1 (2003-2007) very different for the avergae of 1960-1990?
--COPY (SELECT t1.pix, t1.period, round((max_cmi_sm-min_cmi_sm)/cmi_sm_nor3,3) as cmi_sm_nrange30, round(min_cmi_sm/cmi_sm_nor3,3) AS min_cmi_sm_rel30, round(max_cmi_sm/cmi_sm_nor3,3) AS max_cmi_sm_rel30, round((max_dd5_wt-min_dd5_wt)/dd5_wt_nor,3) as dd5_wt_nrange30, round(min_dd5_wt/dd5_wt_nor,3) AS min_dd5_wt_rel30, round(max_dd5_wt/dd5_wt_nor,3) AS max_dd5_wt_rel30, round((max_map-min_map)/map_nor,3) as map_nrange30, round(min_map/map_nor,3) AS min_map_rel30, round(max_map/map_nor,3) AS max_map_rel30, round((max_mat-min_mat)/mat_nor,3) as mat_nrange30, round(min_mat/mat_nor,3) AS min_mat_rel30, round(max_mat/mat_nor,3) AS max_mat_rel30, ((avg_cmi_sm-cmi_sm_nor)/cmi_sm_nor3) AS cmi_sm_rel30, ((avg_dd5_wt-dd5_wt_nor)/dd5_wt_nor) AS dd5_wt_rel30 FROM 'df2_trends_p1_misc_win_v1.csv' t1 JOIN 'df2_climate_normals30_v1.csv' t2 ON t1.pix=t2.pix) TO 'df2_trends_p1_misc_nor30_v3.csv' (HEADER);

-- Version with absolute change for CMI and DD5. This seems better as relative metrics for CMI produce quite big numbers
COPY (SELECT t1.pix, t1.period, round((max_cmi_sm-min_cmi_sm)/cmi_sm_nor3,3) as cmi_sm_nrange30, round(min_cmi_sm/cmi_sm_nor3,3) AS min_cmi_sm_rel30, round(max_cmi_sm/cmi_sm_nor3,3) AS max_cmi_sm_rel30, round((max_dd5_wt-min_dd5_wt)/dd5_wt_nor,3) as dd5_wt_nrange30, round(min_dd5_wt/dd5_wt_nor,3) AS min_dd5_wt_rel30, round(max_dd5_wt/dd5_wt_nor,3) AS max_dd5_wt_rel30, round((max_map-min_map)/map_nor,3) as map_nrange30, round(min_map/map_nor,3) AS min_map_rel30, round(max_map/map_nor,3) AS max_map_rel30, round((max_mat-min_mat)/mat_nor,3) as mat_nrange30, round(min_mat/mat_nor,3) AS min_mat_rel30, round(max_mat/mat_nor,3) AS max_mat_rel30, ((avg_cmi_sm-cmi_sm_nor)) AS cmi_sm_rel30, ((avg_dd5_wt-dd5_wt_nor)) AS dd5_wt_rel30 FROM 'df2_trends_p1_misc_win_v1.csv' t1 JOIN 'df2_climate_normals30_v1.csv' t2 ON t1.pix=t2.pix) TO 'df2_trends_p1_misc_nor30_v3.csv' (HEADER);


-- this uses 5-year data aggregates together with 30-year normals for the entire study area (regiona mean/median). One value per metric per study region.
-- The idea here was to compare pixels to regional (space) metrics.
--COPY (SELECT pix, period, round((max_cmi_sm-min_cmi_sm)/-2.18,3) as cmi_sm_nrange30_reg, round(min_cmi_sm/-2.18,3) AS min_cmi_sm_rel30_reg, round(max_cmi_sm/-2.18,3) AS max_cmi_sm_rel30_reg, round((max_dd5_wt-min_dd5_wt)/3.75,3) as dd5_wt_nrange30_reg, round(min_dd5_wt/3.75,3) AS min_dd5_wt_rel30_reg, round(max_dd5_wt/3.75,3) AS max_dd5_wt_rel30_reg, round((max_map-min_map)/923.8,3) as map_nrange30_reg, round(min_map/923.8,3) AS min_map_rel30_reg, round(max_map/923.8,3) AS max_map_rel30_reg, round((max_mat-min_mat)/3.79,3) as mat_nrange30_reg, round(min_mat/3.79,3) AS min_mat_rel30_reg, round(max_mat/3.79,3) AS max_mat_rel30_reg, round(avg_cmi_sm/-2.18,3) AS cmi_sm_rel30_reg, round(avg_dd5_wt/3.75,3) AS dd5_wt_rel30_reg FROM 'df2_trends_p1_misc_win_v1.csv') TO 'df2_trends_p1_misc_nor30_reg_v1.csv' (HEADER);

-- Improved version with percentage

--COPY (SELECT pix, period, round((max_cmi_sm-min_cmi_sm)/-2.18,3) as cmi_sm_nrange30_reg, round(min_cmi_sm/-2.18,3) AS min_cmi_sm_rel30_reg, round(max_cmi_sm/-2.18,3) AS max_cmi_sm_rel30_reg, round((max_dd5_wt-min_dd5_wt)/3.75,3) as dd5_wt_nrange30_reg, round(min_dd5_wt/3.75,3) AS min_dd5_wt_rel30_reg, round(max_dd5_wt/3.75,3) AS max_dd5_wt_rel30_reg, round((max_map-min_map)/923.8,3) as map_nrange30_reg, round(min_map/923.8,3) AS min_map_rel30_reg, round(max_map/923.8,3) AS max_map_rel30_reg, round((max_mat-min_mat)/3.79,3) as mat_nrange30_reg, round(min_mat/3.79,3) AS min_mat_rel30_reg, round(max_mat/3.79,3) AS max_mat_rel30_reg, round((avg_cmi_sm - (-2.18)),3) AS cmi_sm_rel30_reg, round((avg_dd5_wt-3.75),3) AS dd5_wt_rel30_reg, round(((avg_cmi_sm - (-2.18))/abs(-2.18)) * 100,3) AS cmi_sm_rel30p_reg, round(((avg_dd5_wt-3.75)/3.75)*100,3) AS dd5_wt_rel30p_reg FROM 'df2_trends_p1_misc_win_v1.csv') TO 'df2_trends_p1_misc_nor30_reg_v1.csv' (HEADER);

COPY (SELECT pix, period, round((max_cmi_sm-min_cmi_sm)/abs(-2.18),3) as cmi_sm_nrange30_reg, round(min_cmi_sm/abs(-2.18),3) AS min_cmi_sm_rel30_reg, round(max_cmi_sm/abs(-2.18),3) AS max_cmi_sm_rel30_reg, round((max_dd5_wt-min_dd5_wt)/3.75,3) as dd5_wt_nrange30_reg, round(min_dd5_wt/3.75,3) AS min_dd5_wt_rel30_reg, round(max_dd5_wt/3.75,3) AS max_dd5_wt_rel30_reg, round((max_map-min_map)/923.8,3) as map_nrange30_reg, round(min_map/923.8,3) AS min_map_rel30_reg, round(max_map/923.8,3) AS max_map_rel30_reg, round((max_mat-min_mat)/3.79,3) as mat_nrange30_reg, round(min_mat/3.79,3) AS min_mat_rel30_reg, round(max_mat/3.79,3) AS max_mat_rel30_reg, 
round((avg_cmi_sm - (-2.18)),3) AS cmi_sm_rel30_reg, round((avg_dd5_wt-3.75),3) AS dd5_wt_rel30_reg, round(((avg_cmi_sm - (-2.18))/abs(-2.18)) * 100,3) AS cmi_sm_rel30p_reg, round(((avg_dd5_wt-3.75)/3.75)*100,3) AS dd5_wt_rel30p_reg FROM 'df2_trends_p1_misc_win_v1.csv') TO 'df2_trends_p1_misc_nor30_reg_v1.csv' (HEADER);




-- Aggregate break data

-- 2025-04-03
-- Here I added a few muy disturbance related metrics as the binary disturbance metric does not seem to discriminate between Gr & Br too well.
-- This query was run by itself in DuckDB. The R script then refers to this data table by period
COPY (SELECT pix, ifnull(min(gfc_tsince_p1),0) as gfc_tsince_p1, ifnull(min(gfc_tsince_p2),0) as gfc_tsince_p2, ifnull(min(gfc_tsince_p3),0) as gfc_tsince_p3, ifnull(min(gfc_tsince_p4),0) as gfc_tsince_p4,
ifnull(sum(gfc_p1),0) AS gfc_csum_p1, ifnull(sum(gfc_p2),0) AS gfc_csum_p2, ifnull(sum(gfc_p3),0) AS gfc_csum_p3, ifnull(sum(gfc_p4),0) AS gfc_csum_p4,
round(ifnull(sum(gfc_wsum_p1),0),3) AS gfc_wsum_p1, round(ifnull(sum(gfc_wsum_p2),0),3) AS gfc_wsum_p2, round(ifnull(sum(gfc_wsum_p3),0),3) AS gfc_wsum_p3, round(ifnull(sum(gfc_wsum_p4),0),3) AS gfc_wsum_p4 
FROM
( 
SELECT pix, year, gfc_tsince_p1, gfc_tsince_p2, gfc_tsince_p3, gfc_tsince_p4, gfc_p1, gfc_p2, gfc_p3, gfc_p4,
(gfc_p1/gfc_tsince_p1) AS gfc_wsum_p1, (gfc_p2/gfc_tsince_p2) AS gfc_wsum_p2, (gfc_p3/gfc_tsince_p3) AS gfc_wsum_p3, (gfc_p4/gfc_tsince_p4) AS gfc_wsum_p4 
FROM (
SELECT *, CASE WHEN cast(gfc AS integer) >1 AND year <2008 THEN 2008-year ELSE NULL END AS gfc_tsince_p1,
CASE WHEN cast(gfc AS integer)>1 AND year <2013 THEN 2013-year ELSE NULL END AS gfc_tsince_p2, 
CASE WHEN cast(gfc AS integer)>1 AND year <2018 THEN 2018-year ELSE NULL END AS gfc_tsince_p3, 
CASE WHEN cast(gfc AS integer)>1 AND year <2023 THEN 2023-year ELSE NULL END AS gfc_tsince_p4,
CASE WHEN year <2008 THEN cast(gfc AS integer) ELSE NULL END AS gfc_p1,
CASE WHEN year <2013 THEN cast(gfc AS integer) ELSE NULL END AS gfc_p2, 
CASE WHEN year < 2018 THEN cast(gfc AS integer) ELSE NULL END AS gfc_p3, 
CASE WHEN year <2023 THEN cast(gfc AS integer) ELSE NULL END AS gfc_p4

FROM './trends/df2_dist_for_trends_v1.csv'
) t1
) t2 GROUP BY pix) TO './trends/df2_dist_cumm_for_trends_v1.csv' (HEADER);


-- #---------------------------------------------
-- # Joining all together
-- # ---------------------------------------------

-- For Period 1
--COPY (SELECT t0.pix, t0.year, t0.for_age AS for_age_2003, t0.for_con AS for_con_2003, t0.for_pro, t0.elev, t0.p1_trend, t0.p1_trend_slope, t0.trend_20yrs, t1.avg_for_age AS avg_for_age_lag, t1.avg_for_con AS avg_for_con_lag, t1.avg_cmi_sm AS avg_cmi_sm_lag, t1.avg_dd5_wt AS avg_dd5_wt_lag, t1.min_cmi_sm AS min_cmi_sm_lag, t1.min_dd5_wt AS min_dd5_wt_lag, t1.max_cmi_sm AS max_cmi_sm_lag, t1.max_dd5_wt AS max_dd5_wt_lag, t2.avg_for_age, t2.avg_for_con, t2.avg_cmi_sm, t2.avg_dd5_wt, t2.min_cmi_sm, t2.min_dd5_wt, t2.max_cmi_sm, t2.max_dd5_wt, t3.delta_for_age, t3.delta_for_con, t3.delta_cmi_sm, t3.delta_dd5_wt, t4.fire, t4.harv, t4.insc, t4.gfc, t4.canlad, t5.count_brk AS count_brk_neg, t5.sum_brk_magnitude AS sum_brk_magnitude_neg, t5.avg_brk_magnitude AS avg_brk_magnitude_neg, t6.count_brk AS count_brk_pos, t6.sum_brk_magnitude AS sum_brk_magnitude_pos, t6.avg_brk_magnitude AS avg_brk_magnitude_pos  FROM 'df2_trends_2003_v1.csv' t0 LEFT JOIN 'df2_trends_p1_3yrlag_avg_v1.csv' t1 ON t0.pix=t1.pix LEFT JOIN 'df2_trends_p1_avg_v1.csv' t2 ON t0.pix=t2.pix LEFT JOIN 'df2_trends_p1_delta_v1.csv' t3 ON t0.pix=t3.pix LEFT JOIN 'df2_trends_p1_brk_dist_v1.csv' t4 ON t0.pix=t4.pix LEFT JOIN 'df2_trends_p1_brk_neg_v1.csv' t5 ON t0.pix=t5.pix LEFT JOIN 'df2_trends_p1_brk_pos_v1.csv' t6 ON t0.pix=t6.pix) TO 'df2_trends_p1_vars_v1.csv' (HEADER);


--COPY (SELECT t0.pix, t0.year, t0.for_age AS for_age_2003, t0.for_con AS for_con_2003, t0.for_pro, t0.elev, t0.p1_trend, round(t0.p1_trend_slope, 3) AS p1_trend_slope, t0.trend_20yrs, t1.delta_for_age_lag3, t1.delta_for_con_lag3, t1.delta_cmi_sm_lag3, t1.delta_dd5_wt_lag3, t10.delta_for_age_lag2, t10.delta_for_con_lag2, t10.delta_cmi_sm_lag2, t10.delta_dd5_wt_lag2, t11.delta_for_age_lag1, t11.delta_for_con_lag1, t11.delta_cmi_sm_lag1, t11.delta_dd5_wt_lag1, t3.delta_for_age, t3.delta_for_con, t3.delta_cmi_sm, t3.delta_dd5_wt, t4.fire, t4.harv, t4.insc, t4.gfc, t4.canlad, t5.count_brk AS count_brk_neg, round(t5.sum_brk_magnitude,3) AS sum_brk_magnitude_neg, t5.avg_brk_magnitude AS avg_brk_magnitude_neg, t6.count_brk AS count_brk_pos, round(t6.sum_brk_magnitude,3) AS sum_brk_magnitude_pos, t6.avg_brk_magnitude AS avg_brk_magnitude_pos  FROM 'df2_trends_2003_v1.csv' t0 LEFT JOIN 'df2_trends_p1_delta_lag3_v1.csv' t1 ON t0.pix=t1.pix LEFT JOIN 'df2_trends_p1_delta_lag2_v1.csv' t10 ON t0.pix=t10.pix LEFT JOIN 'df2_trends_p1_delta_lag1_v1.csv' t11 ON t0.pix=t11.pix LEFT JOIN 'df2_trends_p1_delta_v1.csv' t3 ON t0.pix=t3.pix LEFT JOIN 'df2_trends_p1_brk_dist_v1.csv' t4 ON t0.pix=t4.pix LEFT JOIN 'df2_trends_p1_brk_neg_v1.csv' t5 ON t0.pix=t5.pix LEFT JOIN 'df2_trends_p1_brk_pos_v1.csv' t6 ON t0.pix=t6.pix) TO 'df2_trends_p1_vars_v2.csv' (HEADER);


--COPY (SELECT t0.pix, t0.year, t0.for_age AS for_age_2003, t0.for_con AS for_con_2003, t0.for_pro, t0.elev, t0.p1_trend, round(t0.p1_trend_slope, 3) AS p1_trend_slope, t0.trend_20yrs, t1.delta_for_age_lag3, t1.delta_for_con_lag3, t1.delta_cmi_sm_lag3, t1.delta_dd5_wt_lag3, t2.avg_for_age, t2.avg_for_con, t2.avg_cmi_sm, t2.avg_dd5_wt, t2.min_cmi_sm, t2.min_dd5_wt, t2.max_cmi_sm, t2.max_dd5_wt, t10.delta_for_age_lag2, t10.delta_for_con_lag2, t10.delta_cmi_sm_lag2, t10.delta_dd5_wt_lag2, t11.delta_for_age_lag1, t11.delta_for_con_lag1, t11.delta_cmi_sm_lag1, t11.delta_dd5_wt_lag1, t3.delta_for_age, t3.delta_for_con, t3.delta_cmi_sm, t3.delta_dd5_wt, t4.fire, t4.harv, t4.insc, t4.gfc, t4.canlad, ifnull(t5.count_brk,0) AS count_brk_neg, ifnull(t5.sum_brk_magnitude,0) AS sum_brk_magnitude_neg, ifnull(t5.avg_brk_magnitude,0) AS avg_brk_magnitude_neg, ifnull(t6.count_brk,0) AS count_brk_pos, ifnull(t6.sum_brk_magnitude,0) AS sum_brk_magnitude_pos, ifnull(t6.avg_brk_magnitude,0) AS avg_brk_magnitude_pos, t7.cmi_sm_nrange, dd5_wt_nrange, min_cmi_sm_rel, max_cmi_sm_rel, min_dd5_wt_rel,max_dd5_wt_rel, map_nrange, mat_nrange, min_map_rel, max_map_rel, min_mat_rel, max_mat_rel, cmi_sm_cv, dd5_wt_cv, cmi_sm_cqv, dd5_wt_cqv, t8.cmi_sm_nrange30, min_cmi_sm_rel30, max_cmi_sm_rel30, dd5_wt_nrange30, min_dd5_wt_rel30, max_dd5_wt_rel30, map_nrange30, min_map_rel30, max_map_rel30, mat_nrange30, min_mat_rel30,max_mat_rel30, t9.cmi_sm_nrange30_reg, min_cmi_sm_rel30_reg, max_cmi_sm_rel30_reg, dd5_wt_nrange30_reg, min_dd5_wt_rel30_reg, max_dd5_wt_rel30_reg, map_nrange30_reg, min_map_rel30_reg, max_map_rel30_reg, mat_nrange30_reg, min_mat_rel30_reg, max_mat_rel30_reg, cmi_sm_rel30, dd5_wt_rel30 FROM 'df2_trends_2003_v1.csv' t0 LEFT JOIN 'df2_trends_p1_delta_lag3_v1.csv' t1 ON t0.pix=t1.pix LEFT JOIN 'df2_trends_p1_misc_win_v1.csv' t2 ON t0.pix=t2.pix LEFT JOIN 'df2_trends_p1_delta_lag2_v1.csv' t10 ON t0.pix=t10.pix LEFT JOIN 'df2_trends_p1_delta_lag1_v1.csv' t11 ON t0.pix=t11.pix LEFT JOIN 'df2_trends_p1_delta_v2.csv' t3 ON t0.pix=t3.pix LEFT JOIN 'df2_trends_p1_brk_dist_v1.csv' t4 ON t0.pix=t4.pix LEFT JOIN 'df2_trends_p1_brk_neg_v1.csv' t5 ON t0.pix=t5.pix LEFT JOIN 'df2_trends_p1_brk_pos_v1.csv' t6 ON t0.pix=t6.pix LEFT JOIN 'df2_trends_p1_misc_norrel_v1.csv' t7 ON t0.pix=t7.pix LEFT JOIN 'df2_trends_p1_misc_nor30_v3.csv' t8 ON t0.pix=t8.pix LEFT JOIN 'df2_trends_p1_misc_nor30_reg_v1.csv' t9 ON t0.pix=t9.pix) TO 'df2_trends_p1_vars_v3.csv' (HEADER);


COPY (
SELECT t0.pix, t0.year, t0.for_age AS for_age_2003, t0.for_con AS for_con_2003, t0.for_pro, t0.elev, t0.p1_trend, round(t0.p1_trend_slope, 3) AS p1_trend_slope, t0.trend_20yrs, 
t1.delta_for_age_lag3, t1.delta_for_con_lag3, t1.delta_cmi_sm_lag3, t1.delta_dd5_wt_lag3, t1.deltap_for_age_lag3, t1.deltap_for_con_lag3, t1.deltap_cmi_sm_lag3, t1.deltap_dd5_wt_lag3,
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
FROM 'df2_trends_2003_v1.csv' t0 
LEFT JOIN 'df2_trends_p1_delta_lag3_v1.csv' t1 ON t0.pix=t1.pix 
LEFT JOIN 'df2_trends_p1_misc_win_v1.csv' t2 ON t0.pix=t2.pix 
LEFT JOIN 'df2_trends_p1_delta_lag2_v1.csv' t10 ON t0.pix=t10.pix 
LEFT JOIN 'df2_trends_p1_delta_lag1_v1.csv' t11 ON t0.pix=t11.pix 
LEFT JOIN 'df2_trends_p1_delta_v2.csv' t3 ON t0.pix=t3.pix 
LEFT JOIN 'df2_trends_p1_dist_v1.csv' t4 ON t0.pix=t4.pix 
LEFT JOIN 'df2_trends_p1_brk_neg_v1.csv' t5 ON t0.pix=t5.pix 
LEFT JOIN 'df2_trends_p1_brk_pos_v1.csv' t6 ON t0.pix=t6.pix 
LEFT JOIN 'df2_trends_p1_misc_norrel_v1.csv' t7 ON t0.pix=t7.pix 
LEFT JOIN 'df2_trends_p1_misc_nor30_v3.csv' t8 ON t0.pix=t8.pix 
LEFT JOIN 'df2_trends_p1_misc_nor30_reg_v1.csv' t9 ON t0.pix=t9.pix
) TO 'df2_trends_p1_vars_v4.csv' (HEADER);

COPY (SELECT * FROM 'df2_trends_p1_vars_v4.csv' WHERE p1_trend=1) TO 'df2_trends_p1_vars_greening_v5.csv'  (HEADER);
COPY (SELECT * FROM 'df2_trends_p1_vars_v4.csv' WHERE p1_trend=1) TO 'C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/df2_trends_p1_vars_greening_v5.csv' (HEADER);

COPY (SELECT * FROM 'df2_trends_p1_vars_v4.csv' WHERE p1_trend=2) TO 'df2_trends_p1_vars_browning_v5.csv'  (HEADER);
COPY (SELECT * FROM 'df2_trends_p1_vars_v4.csv' WHERE p1_trend=2) TO 'C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/df2_trends_p1_vars_browning_v5.csv' (HEADER);


-- I am gettins startified sample from the greening & browning CSVs. See : C:/Users/Peter R/github/forc_stpa/scripts/create_stratified_random_samples_v1.R


-- Select out greening trends

--COPY (SELECT * FROM 'df2_trends_p1_vars_v2.csv' WHERE p1_trend=1) TO 'df2_trends_p1_vars_greening_v1.csv'  (HEADER);


-- Select out browning trends

--COPY (SELECT * FROM 'df2_trends_p1_vars_v2.csv' WHERE p1_trend=2) TO 'df2_trends_p1_vars_browning_v1.csv'  (HEADER);


--
--COPY (SELECT * FROM 'df2_trends_p1_vars_v3.csv' WHERE p1_trend=1) TO 'df2_trends_p1_vars_greening_v2.csv'  (HEADER);

-- Select out browning trends

-- COPY (SELECT * FROM 'df2_trends_p1_vars_v3.csv' WHERE p1_trend=2) TO 'df2_trends_p1_vars_browning_v2.csv'  (HEADER);

-- VIF should be done on the full 'df2_trends_p1_vars_v3.csv'
-- I forgot to do the 20-year metrics which are good if I want ot explain the 20-year trend


--COPY (SELECT * FROM 'df2_trends_p1_vars_v4.csv' WHERE p1_trend=1) TO 'df2_trends_p1_vars_greening_v4.csv'  (HEADER);
--COPY (SELECT * FROM 'df2_trends_p1_vars_v4.csv' WHERE p1_trend=1) TO 'C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/df2_trends_p1_vars_greening_v4.csv' (HEADER);

--COPY (SELECT * FROM 'df2_trends_p1_vars_v4.csv' WHERE p1_trend=2) TO 'df2_trends_p1_vars_browning_v4.csv'  (HEADER);
--COPY (SELECT * FROM 'df2_trends_p1_vars_v4.csv' WHERE p1_trend=2) TO 'C:/Users/Peter R/github/forc_stpa/models/xgboost/exploratory/data/df2_trends_p1_vars_browning_v4.csv' (HEADER);


-- Run in DuckDB
.read ./trends/duck_query_p3.sql

.read ./trends/duck_analysis_df_p1_v1.sql

.read ./trends/duck_analysis_df_p2_v1.sql

.read ./trends/duck_analysis_df_p3_v1.sql

.read ./trends/duck_analysis_df_p4_v1.sql