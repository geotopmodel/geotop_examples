## CreateSoilInputData.R
#' This script is intended to  create a soil input file for the
#' Wierenga et al. (1991) infiltration trench experiment for simulations
#' in GEOtop. 
#' 
#' Parameters are defined based on values given in the original manuscript.

rm(list=ls())

require(lubridate)

# path to save output soil file
out.path <- "C:/Users/Sam/src/geotop_examples/1D/WierengaEtAl_1991/soil/soil0001.txt"

# define soil layer properties
min.Dz <- 10       # [mm] - thickness of top soil layer
total.Dz <- 10000  # [mm] - total soil thickness
nsoilay <- 100     # number of soil layers

# make Dz sequence
if (total.Dz/min.Dz < nsoilay){
  # if min.Dz is too big to make nsoilay layers adding up to total.Dz,
  # increase nsoilay
  nsoilay <- ceiling(total.Dz/min.Dz)
}

## figure out increment to increase layer thickness with depth
# coefficient for incrementing
incrcoeff <- 0.0
for (j in 1:nsoilay-1){
  # figure out total increment coefficient
  incrcoeff <- incrcoeff + j
}

# incrementing constant
incconst <- (total.Dz - (min.Dz*nsoilay))/incrcoeff

## build soil layers
df.out <- data.frame(Dz = numeric(length=nsoilay))
df.out$Dz[1] <- min.Dz
for (j in 1:nsoilay-1){
  df.out$Dz[j+1] <- min.Dz + j*incconst
}

# add other parameters, which will be constant with depth for infiltration trench
df.out$Kh <-  270.1*10/86400  # [mm/s] - convert from 270.1 cm/d
df.out$Kv <-  270.1*10/86400  # [mm/s] - convert from 270.1 cm/d
df.out$vwc_r <- 0.083         # residual VWC
#df.out$vwc_w <- 0.091         # wilting point VWC
df.out$vwc_fc <- 0.137        # field capacity VWC
df.out$vwc_s <- 0.321         # saturated VWC
df.out$VG_alpha <- 0.055*(1/10)  # [mm-1] - convert from 0.055 cm-1
df.out$VG_n <- 1.51              # Van Genuchten n
df.out$SS <- 1.00E-07       # Specific storativity - use default value

# save output file
write.csv(df.out, out.path, quote=F, row.names=F)
