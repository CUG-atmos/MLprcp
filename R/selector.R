
selector <- function(x, patterns) {
    varnames = colnames(x)
    for (pattern in patterns) {
        varnames %<>% {.[grep(pattern, .)]}
    }
    varnames
}
