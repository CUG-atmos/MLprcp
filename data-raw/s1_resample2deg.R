
source("examples/main_pkgs.R")

r = raster("data-raw/CN05.1/CN05.1_Pre_1961_2018_month_025x025.nc")
r2 <- brick("data-raw/CN05.1/CN05.1_Pre_1961_2018_month_2deg.nc")
r2 = readAll(r2)

mat = as.array(r2)
