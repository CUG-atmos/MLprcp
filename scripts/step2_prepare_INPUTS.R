source("scripts/main_pkgs.R", encoding = "utf-8")

d1 <- read_data("data-raw/cma_ClimateIndex/M_Atm_Nc.txt")
d2 <- read_data("data-raw/cma_ClimateIndex/M_Ext.txt", "Y")
d3 <- read_data("data-raw/cma_ClimateIndex/M_Oce_Er.txt", "Z")
d2[d2 == -999] = NA

df = merge(d1, d2) %>% merge(d3)
date   <- df$date
d_time <- get_yseason_dt(date)

# loops over climate indexes
variables = colnames(df)[-1]

file_clim = "OUTPUT/INPUTS_climateIndex.rda"
if (!file.exists(file_clim)) {
    lst_input = foreach(variableName = variables, i = icount()) %do% {
        runningId(i, 10)
        x = df[[variableName]]
        get_preseason(x, d_time, variableName)
    }
    save(lst_input, file_clim)
} else {
    load(file_clim)
}

## prepare inputs
lst_climateIndex <- foreach(variable = variables, i = icount()) %do% {
    runningId(i)
    x = df[[variable]]
    get_preseason(x, d_time, variable)
}
mat_predictor <- do.call(cbind, lst_climateIndex) #
mat_predictor2 <- mat_predictor[1:58, ]
fwrite(data.table(mat_predictor), "INPUT_climateIndex.csv")

## 同时输入prcp前24个月的降水
## 2. Response variable --------------------------------------------------------
## add a cross validation part
mat_season <- apply_3d(arr2, dim = 3, FUN = rowSums2, by = get_yseason(dates))
seasons <- unique(get_yseason(dates))
I_summer = seasons %>% grep("summer", .)
mat_response <- mat_season[,,I_summer] %>% array_3dTo2d(I_mask)

# d_loc = data_loc %>% array_3dTo2d(I_mask)  %>% as.data.table() %>% set_colnames(c("lon", "lat", "alt"))
# data = pre_monthly_sd %>% array_3dTo2d(I_mask) %>% cbind(d_loc[, 1:2], .) %>% data.frame()

## 后路已备好
# coordinates(data) <- ~ lon + lat
# gridded(data) <- TRUE
save(mat_response, mat_predictor2, d_loc, file = "ml_input_1deg.rda")
