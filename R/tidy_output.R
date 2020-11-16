
tidy_output_cluster <- function(lst) {
    d <- map(lst, "gof") %>% map(function(info) {
        info %>% as.list() %>% as.data.table()
    }) %>% melt_list("cluster")

    regions = c("(1) Mongo", "(2) Yangtze_south", "(3) Pearl", "(4) NorthPlain", "(5) XinJiang", "(6) SouthChina-Pearl"
    , "(7) Tibet_west", "(8) Yangtze_north", "(9) Tibet_east")
    # d$region = regions
    d$cluster %<>% as.numeric()
    df = merge(d, d_cluster)
    coordinates(df) <- ~ lon + lat
    gridded(df) <- TRUE
    df
}

tidy_output <- function(lst, name = "id") {
    d <- map(lst, "gof") %>% map(function(info) {
        info %>% as.list() %>% as.data.table()
    }) %>% melt_list(name)
    d[[name]] %<>% as.numeric()

    regions = c("(1) Mongo", "(2) Yangtze_south", "(3) Pearl", "(4) NorthPlain", "(5) XinJiang", "(6) SouthChina-Pearl"
    , "(7) Tibet_west", "(8) Yangtze_north", "(9) Tibet_east")
    # d$region = regions
    
    df = merge(d, d_cluster %>% cbind(id = 1:nrow(.), .) )
    coordinates(df) <- ~ lon + lat
    gridded(df) <- TRUE
    df
}
