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
load("ml_input_1deg.rda")
ind_BadPredictor <- colSums2(mat_predictor2) %>% which.na()
mat_predictor2 = mat_predictor2[1:58, -ind_BadPredictor]
x_train <- mat_predictor2[ind_train, ]
x_test  <- mat_predictor2[ind_test, ]

prcp = array_3dTo2d(arr2, I_mask)
d_time2 = get_yseason_dt(dates)

InitCluster(10)
ngrid <- dim(mat_response)[1]

lst = foreach(i = 1:ngrid, k = icount()) %dopar% {
    runningId(k, 10)
    mat_prcp = get_preseason(prcp[i, ], d_time2, "prcp")
    x_train2 = cbind(x_train, mat_prcp[ind_train, ])
    x_test2 = cbind(x_test, mat_prcp[ind_test, ])

    tryCatch({
        y_train = mat_response[i, ind_train] %>% as.matrix()
        y_test = mat_response[i, ind_test] %>% as.matrix()

        set.seed(i)
        # r = randomForest(x_train, y_train, x_test, y_test, ntree = 500)
        r2 = randomForest(x_train2, y_train, x_test2, y_test, ntree = 500)
        info = GOF(y_test[, 1], r$test$predicted)
        # GOF(y_test[, 1], r2$test$predicted)
        listk(model = r2, info)
    }, error = function(e) {
        message(sprintf('%s', e$message))
    })
}

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
