
``` r
library(magrittr)
load("./China_MLprcp_INPUTS_1deg_v010.rda")
```

# 输入数据

## `X_climate`: 130个气候因子

``` r
str(X_climate) %>% print()
```

    ##  num [1:58, 1:6914] 0 0 0 0.89 0 0 0 0 0 0 ...
    ##  - attr(*, "dimnames")=List of 2
    ##   ..$ : chr [1:58] "1961" "1962" "1963" "1964" ...
    ##   ..$ : chr [1:6914] "X1-month_pre:00" "X1-month_pre:01" "X1-month_pre:02" "X1-month_pre:03" ...
    ## NULL

## `X_prcp`: 前两年降水输入，`dim = [n_year, n_variable, n_grid]`

``` r
str(X_prcp) %>% print()
```

    ##  num [1:58, 1:56, 1:918] 7.42 3.86 4.33 6.02 9.72 ...
    ##  - attr(*, "dimnames")=List of 3
    ##   ..$ : chr [1:58] "1961" "1962" "1963" "1964" ...
    ##   ..$ : chr [1:56] "prcp-month_pre:00" "prcp-month_pre:01" "prcp-month_pre:02" "prcp-month_pre:03" ...
    ##   ..$ : NULL
    ## NULL

## `Y_prcp`: 因变量，每年的夏季降水

``` r
str(Y_prcp) %>% print()
```

    ##  num [1:918, 1:58] 56.41 22.15 33.26 26.84 9.54 ...
    ## NULL

``` r
print(d_loc)
```

    ##        lon  lat  alt
    ##   1:  73.5 39.5 4403
    ##   2:  74.5 39.5 3861
    ##   3:  74.5 38.5 4242
    ##   4:  74.5 37.5 4588
    ##   5:  75.5 39.5 2089
    ##  ---                
    ## 914: 130.5 45.5  278
    ## 915: 131.5 47.5   63
    ## 916: 131.5 46.5   93
    ## 917: 132.5 47.5   62
    ## 918: 132.5 46.5   72
