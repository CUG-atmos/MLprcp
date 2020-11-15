source("scripts/main_pkgs.R")

load("INPUTS/China_MLprcp_INPUTS_1deg_v010.rda")
load("OUTPUT/lst_fcm.rda")

d_cluster = fread("INPUTS/fcm_prcp_clsuter_Id.csv")
df <- do.call(rbind, lst_fcm)[, -("pre")] %>% melt("c")

XX_prcp = apply_3d(X_prcp, 3, by = d_cluster$cluster)
YY_prcp = apply_col(Y_prcp, by = d_cluster$cluster)

save(XX_prcp, X_climate, YY_prcp, file = "INPUTS/China_MLprcp_INPUTS_ClusterMean_v010.rda")
load("INPUTS/China_MLprcp_INPUTS_ClusterMean_v010.rda")
YY_prcp %<>% t()

# INPUT variable numbers
colnames(X_climate) %>% str_extract("\\w{1,3}(?=-)") %>% table()

## 1. k-fold cross validation---------------------------------------------------
{
    # k-fold cross validation index
    set.seed(100)
    years <- 1961:2018
    nyear <- length(years)
    kfold <- 6
    inds <- 3:nyear # begin from 1963
    ind_lst <- createFolds(inds, k = kfold, list = TRUE)

    ind <- ind_lst[[1]]
    ind_train <- inds[-ind]
    ind_test <- setdiff(inds, ind_train)
}

## 2. randomForest -------------------------------------------------------------
cluster_ids = seq(1, 9, 1) %>% set_names(., .)
lst <- foreach(i = cluster_ids, k = icount()) %do% {
    runningId(i)

    XX = cbind(X_climate[], XX_prcp[,,i])
    YY = YY_prcp[,i, drop = FALSE]

    x_train = XX[ind_train,]
    x_test  = XX[ind_test,]
    y_train = YY[ind_train] %>% as.matrix()
    y_test  = YY[ind_test] %>% as.matrix()

    set.seed(i)
    r = randomForest(x_train, y_train, x_test, y_test, ntree = 500)
    info = GOF(y_test[, 1], r$test$predicted)
    listk(model = r, info)
}
