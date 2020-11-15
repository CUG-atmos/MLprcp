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
    end_month = ifelse(i <= 86, 8, 2)
    get_preseason(x, d_time, variable, end_month = end_month)
}

mat_predictor <- do.call(cbind, lst_climateIndex)[1:58, ]

## 同时输入prcp前24个月的降水
## 2. Response variable --------------------------------------------------------
## add a cross validation part
mat_season <- apply_3d(arr2, dim = 3, FUN = rowSums2, by = get_yseason(dates))
seasons <- unique(get_yseason(dates))
I_summer = seasons %>% grep("summer", .)
mat_response <- mat_season[,,I_summer] %>% array_3dTo2d(I_mask)

d_cluster = fread("INPUTS/fcm_prcp_clsuter_Id.csv")
# d_loc = data_loc %>% array_3dTo2d(I_mask)  %>% as.data.table() %>% set_colnames(c("lon", "lat", "alt"))
# data = pre_monthly_sd %>% array_3dTo2d(I_mask) %>% cbind(d_loc[, 1:2], .) %>% data.frame()

{
    ind_bad1 <- colSums2(mat_predictor) %>% which.na()
    ind_bad2 <- colSds(mat_predictor) %>% { which(. < 0.01) }
    ind_bad <- union(ind_bad1, ind_bad2)

    mat_predictor2 <- mat_predictor[1:58, -ind_bad][, -4925]

    prcp <- array_3dTo2d(arr2, I_mask)
    d_time2 <- get_yseason_dt(dates)
}

ngrid <- dim(mat_response)[1]
lst_prcp <- foreach(i = seq(1, ngrid, 1), k = icount()) %do% {
    runningId(k, 10)
    get_preseason(prcp[i, ], d_time2, "prcp")
}
X_prcp <- abind(lst_prcp, along = 3)
X_climate <- mat_predictor2

# arr_prcp in the dimension of [year, variable_id, grid_id]
years <- 1961:2018
grid_ids <- 1:ngrid
prcp_variableName <- colnames(X_prcp)
Y_prcp <- mat_response

save(X_climate, X_prcp, Y_prcp, years, grid_ids, prcp_variableName, d_cluster,
     file = "INPUTS/China_MLprcp_INPUTS_1deg_v011.rda")
