## Validation_CompareVWC.R
#' This script is intended to read in observed and modeled data
#' and make some plots comparing them.

rm(list=ls())

require(ggplot2)
require(reshape2)
require(dplyr)
require(gridExtra)

## paths
# observed data path
path.obs <- "C:/Users/Sam/src/geotop_examples/1D/InfiltrationTrench/Validation/ValidationData_WierengaEtAl1991.csv"

# modeled data path
path.mod <- "C:/Users/Sam/src/geotop_examples/1D/InfiltrationTrench/output-tabs/thetaliq0001.txt"

# save plot path
path.plot <- "C:/Users/Sam/src/geotop_examples/1D/InfiltrationTrench/Validation/CompareVWC_Day19-Day35_WithOtherModels.png"

## section to deal with MAGI and COMSOL data
# Info to select correct output data
version <- "r166"
MAGI.file <- paste0("D:/Dropbox/Work/Models/Agro-IBIS/AIM/Trench/zipper_AIM_validation_infiltration/Results/", version, "/AIM_Validation_trench_Theta.txt")  # path to AIM output file to read in
COM.file <- "D:/Dropbox/Work/Models/Agro-IBIS/AIM/Trench/COMSOL/Day19+35_Theta.txt"                      # path to COMSOL output file

# load model output data
MAGI.theta <- read.table(MAGI.file)
colnames(MAGI.theta) <- c("time", "numnp", "hsoi", "50", "150", "250", "500", "750", "875", "1000")
MAGI.theta$time <- MAGI.theta$time

# load COMSOL output data
COM.theta <- read.table(COM.file, skip=8, sep="", col.names=c("depth", "theta.day19", "theta.day35"))
COM.theta$depth <- COM.theta$depth*-1

# process AIM data
zeros <- subset(MAGI.theta, time==1)
for (i in 1:dim(zeros)[1]){
  zeros$height[i] <- sum(zeros$hsoi[1:i])
}
zeros$depth <- max(zeros$height) - zeros$height

MAGI.theta$depth <- rep(zeros$depth, length(unique(MAGI.theta$time)))
df.MAGI.theta <- melt(MAGI.theta[, c("time", "depth", "50", "150", "250", "500", "750", "875", "1000")], id=c("time", "depth"))
colnames(df.MAGI.theta) <- c("time", "depth", "position", "theta")
df.MAGI.theta$position <- as.numeric(levels(df.MAGI.theta$position))[as.numeric(df.MAGI.theta$position)]
df.MAGI.theta$source <- "model"

## read in data
df.obs <- read.csv(path.obs, stringsAsFactors=F)
df.mod <- read.csv(path.mod, stringsAsFactors=F)

## rearrange model data into long-form data frame
# keep column for TimeFromStart and anything beginning with "X" (these are the depths)
all.cols <- colnames(df.mod)
colnames(df.mod)[startsWith(all.cols, "TimeFromStart")] <- "TimeFromStart"
all.cols <- colnames(df.mod)
cols.keep <- all.cols[startsWith(all.cols, "TimeFromStart") | startsWith(all.cols, "X")]

# melt into long-form data frame
df.mod.long <- melt(df.mod[,cols.keep], id.vars="TimeFromStart", variable.name="depth.mm", value.name="VWC")

# get rid of leading X in column depth.mm
df.mod.long$depth.mm <- as.numeric(sub("X", "", df.mod.long$depth.mm))

## summarize to daily means
# make a DOY column
df.mod.long$day <- floor(df.mod.long$TimeFromStart)
df.mod.long.day <- summarize(group_by(df.mod.long, day, depth.mm),
                             VWC.mean = mean(VWC),
                             VWC.min = min(VWC),
                             VWC.max = max(VWC))

## subset to only days with observational data
df.mod.long.day <- subset(df.mod.long.day, day %in% df.obs$day)

## plots for theta profiles vs time
# points are observations
# lines are daily mean
# dashed line is MAGI
# dotted line is COMSOL
p.profile.day19 <- 
  ggplot() +
  geom_line(data=subset(df.mod.long.day, day==19), aes(y=VWC.mean, x=depth.mm/1000)) +
  geom_line(data=COM.theta, 
            aes(y=theta.day19, x=depth), color="black", linetype="dotted") +
  geom_line(data=subset(df.MAGI.theta, position==50 & time==444), 
            aes(y=theta, x=depth), color="black", linetype="32") +
  geom_point(data=subset(df.obs, day==19), aes(y=VWC, x=depth.cm/100), shape=21) +
  labs(title="Day 19", subtitle="point=Obs, solid=GEOtop,\ndash=MAGI, dot=COMSOL") +
  scale_y_continuous(name="Vol. Water Content [m3/m3]", limits=c(0.0, 0.26), breaks=seq(0,0.25,0.05), expand=c(0,0)) +
  scale_x_reverse(name="Depth [m]", limits=c(6,0), expand=c(0,0)) +
  coord_flip() +
  theme_bw() +
  theme(panel.grid=element_blank())

p.profile.day35 <- 
  ggplot() +
  geom_line(data=subset(df.mod.long.day, day==35), aes(y=VWC.mean, x=depth.mm/1000)) +
  geom_line(data=COM.theta, 
            aes(y=theta.day35, x=depth), color="black", linetype="dotted") +
  geom_line(data=subset(df.MAGI.theta, position==50 & time==828), 
            aes(y=theta, x=depth), color="black", linetype="32") +
  geom_point(data=subset(df.obs, day==35), aes(y=VWC, x=depth.cm/100), shape=21) +
  labs(title="Day 35", subtitle="point=Obs, solid=GEOtop,\ndash=MAGI, dot=COMSOL") +
  scale_y_continuous(name="Vol. Water Content [m3/m3]", limits=c(0.0, 0.26), breaks=seq(0,0.25,0.05), expand=c(0,0)) +
  scale_x_reverse(name="Depth [m]", limits=c(6,0), expand=c(0,0)) +
  coord_flip() +
  theme_bw() +
  theme(panel.grid=element_blank())
ggsave(path.plot, arrangeGrob(p.profile.day19, p.profile.day35, ncol=2),
       width=6, height=6, units="in")
