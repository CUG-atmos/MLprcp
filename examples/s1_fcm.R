library(e1071)
library(foreach)
source('examples/main_pkgs.R', encoding = "utf-8")

b <- brick("data-raw/CN05.1/CN05.1_1deg_Pre_1961_2018_month.nc")
arr <- as.array(b)

N = 1000
# a 2-dimensional example
x <- rbind(matrix(rnorm(N,sd=0.3),ncol=2),
         matrix(rnorm(N,mean=1,sd=0.3),ncol=2))

nc = 10
lst = foreach(c = 2:nc) %do% {
    cl <- cmeans(x, c, 100,verbose=TRUE,method="cmeans")
    resultindexes <- fclustIndex(cl,x, index="all")
    d = as.list(resultindexes) %>% as.data.table() %>% cbind(c)
}


# 9 performance index
resultindexes

ggplot(df, aes(c, value)) + geom_point() + geom_line() +
    facet_wrap(~variable, scales = "free_y")

# min better: [XB, ]
# max better: []

# gath.geva ():
# xie.beni: (xb)
# fukuyama.sugeno:
# partition.coefficientre:
# partition.entropy (pe):
# proportion.exponent (ppe):
# separation.index (si):
