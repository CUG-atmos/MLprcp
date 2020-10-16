raster_coord <- function(r) {
    coors = coordinates(r) %>% cbind(., .) %>% 
        set_colnames(c("x", "y", "lon", "lat")) %>% data.frame()
    coordinates(coors) <- ~x+y
    gridded(coors) <- TRUE
    brick(coors)
}
