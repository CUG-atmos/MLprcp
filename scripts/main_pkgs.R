# !/usr/bin/Rscript
# 2020-10-15
# Dongdong Kong ----------------------------------------------------------------
# source('scripts/main_pkgs.R', encoding = "utf-8")
suppressMessages({
    library(magrittr)
    library(purrr)
    library(data.table)
    library(plyr)
    library(stringr)
    library(foreach)
    library(iterators)

    library(JuliaCall)
    ## spatial
    library(raster)
    library(rgdal)
    library(sp)
    library(maptools)
    library(sf)
    library(stars)

    library(e1071)
    library(foreach)
    library(nctools)
    library(lubridate)
    library(matrixStats)
    library(tidyverse)
    library(zoo)
    library(glue)
    
    # personal packages
    library(Ipaper)
    library(latticeGrob)
    library(phenofit) 
    library(rcolors)

    # machine learning packages
    library(randomForest)
    library(caret)
    library(pls)
    library(plsdepot)
})

shp <- rgdal::readOGR("E:/WSL/r_library/ChinaHW/extdata/shp/bou1_4l_south_sml.shp")
poly <- list("sp.polygons", shp)


# b <- brick("data-raw/CN05.1/CN05.1_1deg_Pre_1961_2018_month.nc")
dates <- seq(ymd("1961-01-01"), ymd("2018-12-01"), by = "month")
I_summer <- which(month(dates) %in% 6:8)
daysInMonth <- days_in_month(month(dates))

# 同时添加lon, lat, alt
dem <- raster("data-raw/dem_srtm90_1deg_China.tif")
r_loc <- raster_coord(dem)
r_loc$dem <- dem
data_loc <- as.array(r_loc)

## 3. INPUT precipitation ------------------------------------------------------
b    <- brick("data-raw/CN05.1/CN05.1_1deg_Pre_1961_2018_month.nc")
arr  <- as.array(b) # [lat, lon, time]
arr2 <- aperm(arr, c(3, 1, 2)) * daysInMonth
arr2 <- aperm(arr2, c(2, 3, 1))

# get anomaly, w.r.t. 1981-2010
ind_clim = which(year(dates) %in% 1981:2010)
pre_monthly_climatology = apply_3d(arr2[,,ind_clim], dim = 3, FUN = rowMeans2, by = month(dates[ind_clim]))
# monthly_anom = (arr2 - pre_monthly_climatology)/pre_monthly_climatology
## annual
# data_annual = apply_3d(arr, dim = 3, FUN = rowSums2, by = year(dates)) # yearly
pre_annual <- apply_3d(arr2, dim = 3, FUN = rowSums2, by = year(dates))
pre_monthly_mean <- apply_3d(arr2, dim = 3, FUN = rowMeans2, by = month(dates))
pre_monthly_sd <- apply_3d(arr2, dim = 3, FUN = rowSds, by = month(dates))

mask = (pre_monthly_mean + pre_monthly_sd) %>% apply_3d() %>% {!is.na(.)} # keep TRUE, drop FALSE
I_mask = which(mask)[-c(811, 825)] # 811, 825: mean, sd have NA values
