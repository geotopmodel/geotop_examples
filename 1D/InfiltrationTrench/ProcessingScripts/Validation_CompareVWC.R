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
path.plot <- "C:/Users/Sam/src/geotop_examples/1D/InfiltrationTrench/Validation/CompareVWC_Day19-Day35.png"

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
# dots are observations
# lines are daily mean
# ribbons are daily range
p.profile.day19 <- 
  ggplot() +
  geom_line(data=subset(df.mod.long.day, day==19), aes(y=VWC.mean, x=depth.mm/1000)) +
  geom_ribbon(data=subset(df.mod.long.day, day==19), aes(ymax=VWC.max, ymin=VWC.min, x=depth.mm/1000), alpha=0.5) +
  geom_point(data=subset(df.obs, day==19), aes(y=VWC, x=depth.cm/100), shape=21) +
  labs(title="Day 19") +
  scale_y_continuous(name="Vol. Water Content [m3/m3]", limits=c(0.0, 0.26), breaks=seq(0,0.25,0.05), expand=c(0,0)) +
  scale_x_reverse(name="Depth [m]", limits=c(6,0), expand=c(0,0)) +
  coord_flip() +
  theme_bw() +
  theme(panel.grid=element_blank())

p.profile.day35 <- 
  ggplot() +
  geom_line(data=subset(df.mod.long.day, day==35), aes(y=VWC.mean, x=depth.mm/1000)) +
  geom_ribbon(data=subset(df.mod.long.day, day==35), aes(ymax=VWC.max, ymin=VWC.min, x=depth.mm/1000), alpha=0.5) +
  geom_point(data=subset(df.obs, day==35), aes(y=VWC, x=depth.cm/100), shape=21) +
  labs(title="Day 35") +
  scale_y_continuous(name="Vol. Water Content [m3/m3]", limits=c(0.0, 0.26), breaks=seq(0,0.25,0.05), expand=c(0,0)) +
  scale_x_reverse(name="Depth [m]", limits=c(6,0), expand=c(0,0)) +
  coord_flip() +
  theme_bw() +
  theme(panel.grid=element_blank())
ggsave(path.plot, arrangeGrob(p.profile.day19, p.profile.day35, ncol=2),
       width=6, height=6, units="in")
