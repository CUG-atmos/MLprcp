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
        # runningId(k)
        ind_test  <- ind_CVs[[k]]
        ind_train <- setdiff(ind_all, ind_test)

        x_train   <- XX[ind_train, ]
        x_test    <- XX[ind_test, ]

        y_train   <- YY[ind_train] %>% as.matrix()
        y_test    <- YY[ind_test] %>% as.matrix()

        # m = plsreg1(x_train, y_train, comps = 10, crosval = TRUE)
        # m$reg.coefs %>% which.na() %>% length()
        d = data.frame(Y = y_train); d$X = x_train

        # m = plsr(y ~ x, data = d, ncomp = ncomp, ...)
        m = plsr2(d$X, d$Y)

        selected_vars = match(rownames(m$coefficients), colnames(XX))
        d_test = data.frame(Y = y_test); d_test$X = x_test[, selected_vars]

        ncomp_opt = dim(m$fitted.values)[3]
        pred = predict(m, d_test)[,,ncomp_opt]
        data = data.table(ind = ind_test, y_obs = y_test[,1], y_sim = pred)
        listk(model = m, data)
    }
    data = map(models, "data") %>% do.call(rbind, .) %>% .[order(ind),]
    gof = data[, as.list(GOF(y_obs, y_sim))]
    listk(model = models, data, gof)
}

plsr2 <- function(X, Y, ncomp = 10, VIP_min = 0.2, ...) {
    d = data.frame(Y = as.numeric(Y))
    d$X = X

    m = plsr(Y ~ X, data = d, ncomp = ncomp, validation = "CV")
    ncomp_opt = whichmin_RMSEP(m, 5)$ncomp_opt

    nvar_min = 20
    iter = 0
    while(TRUE) {
        iter = iter + 1
        # print(iter)
        vips = VIP(m)
        if (is.matrix(vips)) vips = vips[ncomp_opt, ]
        vars_bad = which(vips <= VIP_min)

        if (length(vars_bad) == 0) break()
        if (ncol(X) - length(vars_bad) < nvar_min) break()
        # if (nrow(X) - length(vars_bad) < nvar_min) break()

        d$X = X[, -vars_bad, drop = FALSE]
        # if (iter == 8) browser()
        m_this = plsr(Y ~ X, data = d, ncomp = 10, validation = "CV")
        ncomp_opt.new = whichmin_RMSEP(m_this, 5)$ncomp_opt
        m_this = plsr(Y ~ X, data = d, ncomp = ncomp_opt.new, validation = "CV")

        # if good then accept
        delta <- RMSEP(m_this)$val[2, 1, ncomp_opt.new] > RMSEP(m)$val[2, 1, ncomp_opt]
        if (delta > 0.1) break()

        # else if good, update model
        X = X[, -vars_bad, drop = FALSE]
        m = m_this
        ncomp_opt = ncomp_opt.new
    }
    m
}

#' @param m plsr object
whichmin_RMSEP <- function(m, ncomp_max = 5) {
    RMSEPs = RMSEP(m)$val[2, 1, ]
    ncomp_max = pmin(length(RMSEP), ncomp_max)
    ncomp_opt = which.min(RMSEPs[1:ncomp_max])

    listk(ncomp_opt, RMSEP = RMSEPs[ncomp_opt])
}
