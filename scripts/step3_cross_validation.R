source('scripts/main_pkgs.R', encoding = "utf-8")
library(randomForest)
library(phenofit)
library(caret)


set.seed(100)
years <- 1961:2018
nyear <- length(years)
kfold <- 6
inds = 3:nyear # begin from 1963
ind_lst <- createFolds(inds, k = kfold, list = TRUE)

ind  = ind_lst[[1]]
ind_train = inds[-ind]
ind_test  = setdiff(inds, ind_train)

# 逐格点运算
{
    load("ml_input_1deg.rda")
    ind_bad1 <- colSums2(mat_predictor2) %>% which.na()
    ind_bad2 <- colSds(mat_predictor2) %>% {which(. < 0.01)}
    ind_bad <- union(ind_bad1, ind_bad2)

    mat_predictor2 = mat_predictor2[1:58, -ind_bad][, -4925]
    d_predictor <- as.data.table(mat_predictor2) %>% set_rownames(rownames(mat_predictor2))
    fwrite(d_predictor, "X-130气候因子.csv", row.names = TRUE)

    x_train <- mat_predictor2[ind_train, ]
    x_test  <- mat_predictor2[ind_test, ]

    prcp = array_3dTo2d(arr2, I_mask)
    d_time2 = get_yseason_dt(dates)
}

InitCluster(10)
ngrid <- dim(mat_response)[1]

lst_prcp = foreach(i = seq(1, ngrid, 1), k = icount()) %do% {
    runningId(k, 10)
    mat_prcp = get_preseason(prcp[i, ], d_time2, "prcp")
    # x_train2 = cbind(x_train, mat_prcp[ind_train, ])
    # x_test2 = cbind(x_test, mat_prcp[ind_test, ])
    #
    # # tryCatch({
    #     y_train = mat_response[i, ind_train] %>% as.matrix()
    #     y_test = mat_response[i, ind_test] %>% as.matrix()
    #
    #     set.seed(i)
    #     # r = randomForest(x_train, y_train, x_test, y_test, ntree = 500)
    #     r2 = randomForest(x_train2, y_train, x_test2, y_test, ntree = 500)
    #     # r2 = randomForest(x_train2, y_train, ntree = 500)
    #     info = GOF(y_test[, 1], r2$test$predicted)
    #     # GOF(y_test[, 1], r2$test$predicted)
    #     listk(model = r2, info)
    #     print(info)
    # }, error = function(e) {
    #     message(sprintf('%s', e$message))
    # })
}


X_climate <- mat_predictor2
X_prcp <- abind(lst_prcp, along = 3)
# arr_prcp in the dimension of [year, variable_id, grid_id]
years = 1961:2018
grid_ids = 1:ngrid
prcp_variableName = colnames(X_prcp)

Y_prcp = mat_response

save(X_climate, X_prcp, Y_prcp, years, grid_ids, prcp_variableName, d_loc, file = "MLprcp_INPUTS_v010.rda")
# 逐格点的

names(lst) <- seq_along(lst)
{
    info = map(lst, "info") %>% do.call(rbind, .) %>% data.table()
    d_loc = data_loc %>% array_3dTo2d(I_mask)  %>% as.data.table() %>% set_colnames(c("lon", "lat", "alt"))
    d <- cbind(d_loc[, 1:2], info)
    coordinates(d) <- ~ lon + lat
    gridded(d) <- TRUE
    spplot(d, "R", at = c(-Inf, seq(-0.6, 0.6, 0.1), Inf))

    spplot(d, "R2", at = c(-Inf, seq(0, 0.4, 0.05), Inf))
}
