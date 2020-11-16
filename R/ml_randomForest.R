#' k-fold randomForest
#' 
#' @param ... others to [randomForest::randomForest()]
#' 
#' @examples
#' randomForest_kcv(XX, YY, kfold = 6, seed = 1)
randomForest_kcv <- function(XX, YY, kfold = 6, seed = 1, ind_all = NULL, 
    ntree = 500, ...) 
{
    if (is.null(ind_all)) ind_all = 1:nrow(XX)

    set.seed(seed)
    ind_CVs <- createFolds(ind_all, k = kfold, list = F) %>% split(ind_all, .)

    models <- foreach(k = 1:kfold, i = icount()) %do% {
        # runningId(k)
        ind_test  <- ind_CVs[[k]]
        ind_train <- setdiff(ind_all, ind_test)

        x_train   <- XX[ind_train, ]
        x_test    <- XX[ind_test, ]

        y_train   <- YY[ind_train] %>% as.matrix()
        y_test    <- YY[ind_test] %>% as.matrix()

        r <- randomForest(x_train, y_train, x_test, y_test, ntree = ntree, ...)
    }

    ind = match(ind_all, ind_CVs %>% unlist())
    y_sim = map(models, ~.x$test$predicted) %>% unlist() %>% .[ind]

    data = data.table(ind = ind_all, y_obs = YY[ind_all], y_sim)
    gof =  GOF(data$y_obs, data$y_sim) %>% as.list() %>% as.data.table()
    listk(model = models, data, gof)
}
