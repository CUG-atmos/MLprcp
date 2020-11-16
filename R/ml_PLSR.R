#' PLSR
#' 
#' @param ... others to [pls::plsr()]
#' 
#' @examples
#' PLSR_kcv(XX, YY, kfold = 6, seed = 1)
#' @import pls
PLSR_kcv <- function(XX, YY, kfold = 6, seed = 1, ind_all = NULL,
    ncomp = 2, ...)
{
    if (is.null(ind_all)) ind_all = 1:nrow(XX)

    set.seed(seed)
    ind_CVs <- createFolds(ind_all, k = kfold, list = F) %>% split(ind_all, .)

    models <- foreach(k = 1:kfold, i = icount()) %do% {
        runningId(k)
        ind_test  <- ind_CVs[[k]]
        ind_train <- setdiff(ind_all, ind_test)

        x_train   <- XX[ind_train, ]
        x_test    <- XX[ind_test, ]

        y_train   <- YY[ind_train] %>% as.matrix()
        y_test    <- YY[ind_test] %>% as.matrix()

        # m = plsreg1(x_train, y_train, comps = 10, crosval = TRUE)
        # m$reg.coefs %>% which.na() %>% length()
        d = data.frame(y = y_train); d$x = x_train
        d_test = data.frame(y = y_test); d_test$x = x_test

        m = plsr(y ~ x, data = d, ncomp = ncomp, ...)
        pred = predict(m, d_test)[,,ncomp]
        data = data.table(ind = ind_test, y_obs = y_test[,1], y_sim = pred)
        listk(model = m, data)
    }
    data = map(models, "data") %>% do.call(rbind, .) %>% .[order(ind),]
    gof = data[, as.list(GOF(y_obs, y_sim))]
    listk(model = models, data, gof)
}
