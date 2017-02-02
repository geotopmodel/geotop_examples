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
out.path <- "C:/Users/Sam/src/geotop_examples/1D/WierengaEtAl_1991/meteo/meteo0001.txt"

# start and end datetime
date.start <- dmy_hm("27/05/1987 00:00")
date.end <- dmy_hm("21/08/1987 23:00")

# make data frame
df.met <- data.frame(Date = format(seq(date.start, date.end, by="hour"), "%d/%m/%Y %H:%M"),
                     Iprec = sprintf("%f", 1.82*10/24), 
                     WindSp = sprintf("%f", 0),
                     WindDir = sprintf("%f", 0),
                     RH = sprintf("%f", 100.0),
                     AirT = sprintf("%f", 5.0),
                     Swglob = sprintf("%f", 0.0),
                     CloudTrans = sprintf("%f", 1.0))

# save output file
write.csv(df.met, out.path, quote=F, row.names=F)
