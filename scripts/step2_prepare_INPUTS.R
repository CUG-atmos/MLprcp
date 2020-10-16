source("scripts/main_pkgs.R", encoding = "utf-8")

d1 <- read_data("data-raw/cma_ClimateIndex/M_Atm_Nc.txt")
d2 <- read_data("data-raw/cma_ClimateIndex/M_Ext.txt", "Y")
d3 <- read_data("data-raw/cma_ClimateIndex/M_Oce_Er.txt", "Z")
d2[d2 == -999] = NA

df = merge(d1, d2) %>% merge(d3)

date <- df$date
season  = time2season(date, "seasons")
year2 = year(date) - 1 + (month(date) >= 3)
yseason = paste0(year2, "-", season)

d_time = data.table(date, year2, season, yseason)
d = cbind(d_time, x = df$X1)

x = df$X1
d = cbind(d_time, x)

n = length(x)
x_season   = d[, mean(x), .(yseason)]
mat_season = vec_shiftleft(x_season$V1, 7) %>% set_rownames(x_season$yseason) %>%
    set_colnames(sprintf("season_pre:%02d", (1:8)-1))
mat_accuMean = vec_shiftleft_apply(x, 23) %>% set_colnames(sprintf("accuMean_pre:%02d", (1:24)-1))
mat_month = vec_shiftleft(x, 23) %>% set_colnames(sprintf("month_pre:%02d", (1:24)-1))

years = 1961:2020
res = foreach(year = 1961:2020) %do% {
    I_month_target = which(make_date(year, 2, 1) == date)
    I_yseason_target = which(x_season$yseason == paste0(year, "-summer"))
    c(mat_month[I_month_target, ], mat_accuMean[I_month_target, ], mat_season[I_yseason_target, ])
} %>% set_names(years) %>% do.call(rbind, .)
