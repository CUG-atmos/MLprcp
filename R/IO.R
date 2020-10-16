#' @export 
read_data <- function(file, prefix = "X") {
    d <- read.table(file)
    date <- rownames(d) %>% paste0("01") %>% as.Date("%Y%m%d")
    as.data.table(d) %>% 
        set_colnames(paste0(prefix, 1:ncol(.))) %>% 
        cbind(date, .) 
}
