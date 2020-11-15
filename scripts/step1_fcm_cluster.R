source("scripts/main_pkgs.R")

## 1. prepare INPUTS -----------------------------------------------------------
b <- brick("data-raw/CN05.1/CN05.1_1deg_Pre_1961_2018_month.nc")
arr <- as.array(b) # [lat, lon, time]
arr2 <- aperm(arr, c(3, 1, 2)) * daysInMonth
arr2 <- aperm(arr2, c(2, 3, 1))

## annual
# data_annual = apply_3d(arr, dim = 3, FUN = rowSums2, by = year(dates)) # yearly
pre_annual       = apply_3d(arr2, dim = 3, FUN = rowSums2, by = year(dates))
pre_monthly_mean = apply_3d(arr2, dim = 3, FUN = rowMeans2, by = month(dates))
pre_monthly_sd   = apply_3d(arr2, dim = 3, FUN = rowSds, by = month(dates))

names <- c(paste0("year", 1961:2018), paste0("mean:", 1:12), paste0("sd:", 1:12), c("lon", "lat", "alt"))
INPUTS = list(annual = pre_annual, monthly_mean = pre_monthly_mean, monthly_sd = pre_monthly_sd,
    loc = data_loc) %>% abind(along = 3)
mask = (pre_monthly_mean + pre_monthly_sd) %>% apply_3d() %>% {!is.na(.)} # keep TRUE, drop FALSE
I_mask = which(mask)[-c(811, 825)] # 811, 825: mean, sd have NA values
# rowSums2(data) %>% which.na()
d_loc = data_loc %>% array_3dTo2d(I_mask) %>% as.data.table() %>% set_colnames(c("lon", "lat", "alt"))
dims_origin = dim(INPUTS)
data = array_3dTo2d(INPUTS, I_mask) %>% set_colnames(names)
## 2. PCA降维 ------------------------------------------------------------------
s = summary(pc.cr <- princomp(data, cor = TRUE))
sd_perc    = s$sdev^2 %>% {./sum(.)}
sd_cumperc = s$sdev^2 %>% {cumsum(.)/sum(.)}
{
    x = seq_along(sd_perc)
    plot(seq_along(x), sd_cumperc, xlab = "Components", ylab = "Explains (%)"); grid();
    # hist(x, sd_perc)
    abline(h = 0.7, col = "red", lty = 2)
    abline(h = 0.8, col = "red")
    # ind = 1:10; lines(ind, sd_perc[ind]*100)
}
# the first four PCs already explain >= 95% sd, hence nPC = 4 is selected
## 3. FCM ----------------------------------------------------------------------
npc = 4
X   = pc.cr$scores[, 1:npc]
nc  = 20
lst_fcm = foreach(c = 2:nc) %do% {
    runningId(c)
    set.seed(0)
    r = cmeans(X, c, 100)
    indexes = fclustIndex(r, X, index = "all")
    as.list(indexes) %>% as.data.table() %>% cbind(c, .)
}
save(lst_fcm, file = "OUTPUT/lst_fcm.rda")
df <- do.call(rbind, lst_fcm)[, -("pre")] %>% melt("c")

p <- ggplot(df, aes(c, value)) + geom_point() + geom_line() +
    facet_wrap(~variable, scales = "free_y") +
    theme_grey(base_size = 14) +
    theme(strip.text = element_text(size = 16)) +
    labs(y = "validation index")
write_fig(p, "Figures/Figure1_FCM_validation_index.pdf", 10, 6)
# fhv, pc, pe有没有得出有价值的信息。
# pd, xb, fs, pd: 同时指示c = 9分区效果最好，si显示c=8是最好的选择，当c=9时si值略微下降，因此最终取c=9。

set.seed(0)
r = cmeans(X, 9, 100)
d = cbind(d_loc, cluster = r$cluster %>% factor())
fwrite(d, "INPUTS/fcm_prcp_clsuter_Id.csv")
p <- ggplot(d, aes(lon, lat, color = cluster, shape = cluster)) +
    geom_point() +
    scale_shape_manual(values = 1:9)
write_fig(p, "Figures/Figure2_FCM_spatialResult.pdf", 10, 6)

## Performance Index -----------------------------------------------------------
# gath.geva              : fuzzy (fhv), average (apd), partition (pd)
# xie.beni               : (xb), min better
# fukuyama.sugeno        : (fs), min beter
# partition.coefficientre: (pc), max better
# partition.entropy      : (pe), min better
# (unavailable) proportion.exponent    : (ppe), max better
# separation.index       : (si), max better
