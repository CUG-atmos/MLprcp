
## 预测夏季降水
## 以1961年为例，对于变量x，输入的自变量:
# 1. 前两年monthly_x
# 2. 前两年季节性seasonal_x
# 3. 前两年1:24, accumulative_mean_x

get_yseason <- function(date) {
    season <- time2season(date, "seasons")
    year2 <- year(date) - 1 + (month(date) >= 3)
    yseason <- paste0(year2, "-", season)
    yseason
}

get_yseason_dt <- function(date) {
    season <- time2season(date, "seasons")
    year2 <- year(date) - 1 + (month(date) >= 3)
    yseason <- paste0(year2, "-", season)
    # yseason
    data.table(date, year2, season, yseason)
}

# shift ndays
vec_shiftleft <- function(x, length = 1) {
    n = length(x)
    foreach(width = seq(0, length)) %do% {
        if (width == 0) return(x)
        c(rep(NA, width), x[seq(1, n - width)])
    } %>% do.call(cbind, .)
}

vec_shiftleft_apply <- function(x, length, .fun = mean) {
    foreach(width = seq(1, length+1)) %do% {
        rollapply(x, width, .fun, na.rm = TRUE) %>% c(rep(NA, width-1), .)
    } %>% do.call(cbind, .)
}

#' get preseason input
#'
#' Prepare the previous 24 months INPUT
#' @param end_month 2 or 8
#' `2`: for temperature index
#' `8`: for atmospheric circulation index
#' 
#' @import data.table
get_preseason <- function(x, d_time, prefix = "X1", end_month = 2) {
    d = cbind(d_time, x)
    n = nrow(d)

    x_season   = d[, mean(x), .(yseason)]
    # 前0-7季
    mat_season = vec_shiftleft(x_season$V1, 7) %>% set_rownames(x_season$yseason) %>%
        set_colnames(sprintf("season_pre:%02d", (1:8)-1))

    # 前0-23月均值
    mat_month = vec_shiftleft(x, 23) %>% set_colnames(sprintf("month_pre:%02d", (1:24)-1))

    # 累积降水均值
    mat_accuMean = vec_shiftleft_apply(x, 23) %>% set_colnames(sprintf("accuMean_pre:%02d", (1:24)-1))

    years = 1961:max(d_time$year2)
    res = foreach(year = years) %do% {
        
        # 夏季降水最多采用到2月，也即上一年冬季降水
        I_month_target = which(make_date(year, end_month, 1) == d$date)
        end_season = switch(as.character(end_month), 
            `2` = paste0(year - 1, "-winter"), 
            `8` = paste0(year, "-summer"))
        I_yseason_target = which(x_season$yseason == end_season) # summer

        c(mat_month[I_month_target, ], mat_accuMean[I_month_target, ], mat_season[I_yseason_target, ])
    } %>% set_names(years) %>% do.call(rbind, .)
    names = colnames(res) %>% paste0(prefix, "-", .)
    set_colnames(res, names)
}
