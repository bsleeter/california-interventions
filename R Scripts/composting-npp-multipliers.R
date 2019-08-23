
library(zoo)
library(tidyverse)
library(rsyncrosim)



d = read_csv("R Inputs/Data/flow-multipliers/DayCent NPP for USGS.csv")

d1 = d %>% group_by(year) %>% summarise(npp=mean(aNPP), nppdif=mean(relNPP), sddif=sd(relNPP)) %>% filter(year>=2000) %>% ungroup() %>%
  mutate(nppmult=nppdif/npp, nppvar=sddif/npp) %>% filter(year>2016) %>%
  mutate(loess=predict(loess(nppmult~year)))

ggplot(data=d1, aes(x=year, y=nppmult)) +
  geom_ribbon(aes(ymin=nppmult-nppvar, ymax=nppmult+nppvar), alpha=0.3) +
  geom_line() +
  geom_smooth(method="loess")


d2 = data.frame(StateClassID="Grassland:Composted",
                AgeMin=seq(1:105),
                AgeMax=seq(1:105),
                FlowGroupID="Growth",
                FlowMultiplierTypeID="Composting",
                Value=1+d1$loess,
                DistributionType="Normal",
                DistributionFrequencyID="Always",
                DistributionSD=d1$nppvar)
head(d2)
tail(d2)
write_csv(d2, "R Inputs/Data/flow-multipliers/composting.csv")
