# !/usr/bin/Rscript
# 2020-10-15
# Dongdong Kong ----------------------------------------------------------------
# source('examples/main_pkgs.R', encoding = "utf-8")
suppressMessages({
    library(magrittr)
    library(purrr)
    library(data.table)
    library(plyr)
    library(stringr)
    library(foreach)
    library(iterators)

    library(JuliaCall)
    ## spatial
    library(raster)
    library(rgdal)
    library(sp)
    library(sf)
    library(stars)

    # personal packages
    library(Ipaper)
    library(latticeGrob)
    library(rcolors)
})
