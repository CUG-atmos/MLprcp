source("scripts/main_pkgs.R")

load("INPUTS/China_MLprcp_INPUTS_1deg_v011.rda")
infile = "INPUTS/China_MLprcp_INPUTS_ClusterMean_v011.rda"

if (!file.exists(infile)) {
    ## 计算区域平均
    d_cluster = fread("INPUTS/fcm_prcp_clsuter_Id.csv")
    XX_prcp = apply_3d(X_prcp, 3, by = d_cluster$cluster)
    YY_prcp = apply_col(Y_prcp, by = d_cluster$cluster)
    YY_prcp %<>% t()
    save(XX_prcp, X_climate, YY_prcp, file = infile)
} else {
    load(infile)
}

# INPUT variable numbers
colnames(X_climate) %>% str_extract("\\w{1,3}(?=-)") %>% table()

## version 01
years <- 1961:2018

d_expert <- read_xlsx("data-raw/expert_variable_selection.xlsx")
d_expert %<>% mutate(
    type2 = mapvalues(types, c("M_Atm_Nc", "M_Ext", "M_Oce_Er"), c("X", "Y", "Z")),
    varname = paste0(type2, id))

# 干掉专家认为不好的变量
vars_bad <- d_expert[code == 0, varname] %>% paste(collapse = "-|") %>% grep(colnames(X_climate))

var_timescale = "accuMean_pre|month_pre|season_pre"
varnames <- X_climate[, -vars_bad] %>% selector(c(var_timescale, "X|Y|Z"))
X_climate0 <- X_climate[, varnames]

# 2. randomForest -------------------------------------------------------------
{
    cluster_ids = seq(1, 9, 1) %>% set_names(., .)
    lst <- foreach(i = cluster_ids, k = icount()) %do% {
        runningId(i)

        XX = cbind(X_climate0, XX_prcp[,,i] %>% set_colnames(prcp_variableName))
        YY = YY_prcp[,i, drop = FALSE]
        r = randomForest_kcv(XX, YY, kfold = 6, seed = 1, ind_all = 3:58, ntree = 200)
    }

    df = tidy_output(lst)
    {
        par(mar = c(3, 2, 2, 1))
        Rmax = 0.6
        brks = c(-Inf, seq(0, Rmax, 0.05), Inf)
        # BlAqGrYeOrRe
        # amwg256
        n = length(brks)
        cols = get_color("BlGrYeOrReVi200", n)[-n] #%>% rev()
        # cols = get_color("YlOrRd", n - 2) %>% c("blue", .)
        p <- spplot(df, "R", at = brks,
                    col.regions = cols,
                    sp.layout = poly,
                    aspect = 0.7,
                    ylim = c(18, 54), xlim = c(72.8, 135.4),
                    main = expression(bold(atop("Pearson Correlation (PRCP_obs, PRCP_cv)",
                                                "during 1963-2018"))))
        str_time = format(Sys.time(), "%Y%m%d-%H%M%S")
        outfile = glue("cluster_mean_result_v012_({var_timescale})-{str_time}.pdf") %>% gsub("\\|", ",", .)
        write_fig(p, outfile, 9, 6)
    }
}


d_vip = map(r$model, ~ .x$importance[, 1] %>% {data.table(varname = names(.), vip = .)}) %>%
    set_names(seq_along(.)) %>% melt_list("fold")
d_vip = plyr::mutate(d_vip,
                     variable = str_extract(varname, "\\w{1,4}(?=-)"),
                     type = str_extract(varname, "(?<=-).*(?=:)"),
                     time_scale = str_extract(varname, "(?<=:).*") %>% as.numeric())

x = r$model[[2]]$importance[, 1]

{
    # export final result
    df = map(lst, "data") %>% melt_list("cluster")
    df$year <- (1961:2018)[df$ind]
    df <- df[, .(cluster, year, y_obs, y_sim)]

    fwrite(df, "ML_RandomForest_ClusterRegionalMean_CVs_v010 (1963-2018).csv")
}
