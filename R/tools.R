fix_spatial <- function(arr) flipud(t(arr))


apply_3d <- function (array, dim = 3, FUN = rowMeans2, by = NULL, na.rm = TRUE, 
    ...) 
{
    dims <- dim(array)
    ndim <- length(dims)
    if (dim > ndim) 
        dim = ndim
    I_dims <- setdiff(1:ndim, dim)
    dims_head <- dims[I_dims]
    if (dim != ndim) {
        array %<>% aperm(c(I_dims, dim))
    }
    mat <- array_3dTo2d(array)
    if (is.null(by)) {
        ans <- FUN(mat, na.rm = na.rm, ...)
        dim_new <- dims_head
    }
    else {
        dim_new <- c(dims_head, length(unique(by)))
        ans <- apply_row(mat, by, FUN, na.rm = na.rm, ...)
    }
    dim(ans) <- dim_new
    ans
}


apply_row <- function(mat, by, FUN = rowMeans2, w = NULL, na.rm = TRUE, ...) {
    if (length(by) != ncol(mat)) {
        stop("Length of by is not equal to ncol of mat")
    }
    grps <- unique(by) %>%
        sort() %>%
        set_names(., .)
    lapply(grps, function(grp) {
        I <- which(by == grp)
        FUN(mat[, I, drop = FALSE], na.rm = na.rm, w = w[I], ...)
    }) %>%
        do.call(cbind, .) %>%
        set_rownames(rownames(mat))
}
