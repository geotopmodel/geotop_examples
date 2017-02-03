## CreateMetInputData.R
#' This script is intended to  create a meteorological input file for the
#' Wierenga et al. (1991) infiltration trench experiment for simulations
#' in GEOtop. 
#' 
#' Because this experiment uses a constant infiltration rate and sets all 
#' other surface fluxes (evaporation, precipitation, etc.) equal to 0, some
#' tricks will be used to try to minimize evaporation:
#' -Precipitation intensity is 0.758333 mm/hr (=1.82 cm.day)
#' -Wind speed = 0 m/s
#' -Wind direction = 0
#' -RH = 100.0%
#' -AirT = 5.0 C
#' -Global SW radiation = 0 W/m2
#' -Cloud transmissivity = 1.0

rm(list=ls())

require(lubridate)

# path to save output met file
out.path <- "C:/Users/Sam/src/geotop_examples/1D/WierengaEtAl_1991/meteo/meteotrench0001.txt"

# start and end datetime
date.start <- dmy_hm("27/05/1987 00:00")
date.end <- dmy_hm("21/08/1987 23:00")
dates.all <- seq(date.start, date.end, by="hour")

# make data frame
df.met <- data.frame(Date = format(dates.all, "%d/%m/%Y %H:%M"),
                     Iprec = sprintf("%f", 1.82*10/24),
                     WindSp = rnorm(n=length(dates.all), mean=10, sd=0.1),
                     WindDir = rnorm(n=length(dates.all), mean=20, sd=0.1),
                     RH = rnorm(n=length(dates.all), mean=90, sd=0.1),
                     AirT = rnorm(n=length(dates.all), mean=5, sd=0.1),
                     Swglob = rnorm(n=length(dates.all), mean=30, sd=0.1),
                     CloudTrans = rnorm(n=length(dates.all), mean=0.9, sd=0.01))
                     # WindSp = sprintf("%f", 0),
                     # WindDir = sprintf("%f", 90.0),
                     # RH = sprintf("%f", 100.0),
                     # AirT = sprintf("%f", 5.0),
                     # Swglob = sprintf("%f", 0.0),
                     # CloudTrans = sprintf("%f", 1.0))

# save output file
write.csv(df.met, out.path, quote=F, row.names=F)
