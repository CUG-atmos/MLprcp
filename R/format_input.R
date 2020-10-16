
## 预测夏季降水
## 以1961年为例，对于变量x，输入的自变量:
# 1. 前两年monthly_x
# 2. 前两年季节性seasonal_x
# 3. 前两年1:24, accumulative_mean_x

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

