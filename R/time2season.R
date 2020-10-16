time2season <- function (x, out.fmt = "months", type = "default") 
{
    if (!(is(x, "Date") | is(x, "POSIXct") | is(x, "POSIXt"))) 
        stop("Invalid argument: 'x' must be in c('Date', 'POSIXct', 'POSIXt') !")
    if (is.na(match(out.fmt, c("seasons", "months")))) 
        stop("Invalid argument: 'out.fmt' must be in c('seasons', 'months')")
    valid.types <- c("default", "FrenchPolynesia")
    if (length(which(!is.na(match(type, valid.types)))) <= 0) 
        stop("Invalid argument: 'type' must be in c('default', 'FrenchPolynesia')")
    months <- format(x, "%m")
    if (type == "default") {
        winter <- which(months %in% c("12", "01", "02"))
        spring <- which(months %in% c("03", "04", "05"))
        summer <- which(months %in% c("06", "07", "08"))
        autumm <- which(months %in% c("09", "10", "11"))
    }
    else if (type == "FrenchPolynesia") {
        winter <- which(months %in% c("12", "01", "02", "03"))
        spring <- which(months %in% c("04", "05"))
        summer <- which(months %in% c("06", "07", "08", "09"))
        autumm <- which(months %in% c("10", "11"))
    }
    seasons <- rep(NA, length(x))
    if (out.fmt == "seasons") {
        seasons[winter] <- "winter"
        seasons[spring] <- "spring"
        seasons[summer] <- "summer"
        seasons[autumm] <- "autumm"
    }
    else {
        if (type == "default") {
            seasons[winter] <- "DJF"
            seasons[spring] <- "MAM"
            seasons[summer] <- "JJA"
            seasons[autumm] <- "SON"
        }
        else if (type == "FrenchPolynesia") {
            seasons[winter] <- "DJFM"
            seasons[spring] <- "AM"
            seasons[summer] <- "JJAS"
            seasons[autumm] <- "ON"
        }
    }
    return(seasons)
}
