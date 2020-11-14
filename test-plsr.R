


library(plsdepot)
{
    load_all("/mnt/n/Research/r_pkgs/plsdepot")
    r = plsreg1_adj(x_train2, y_train, comps = NULL)
}

# I_vars <- colnames(x_train2) %>% grep("season", .)
# colnames(x_train2) %>% str_extract("-.*(?=_)") %>% table()
