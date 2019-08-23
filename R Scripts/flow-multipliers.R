# Calculate Flow Multipliers

library(tidyverse)



##################################################################
# Growth and Q10 Multipliers
##################################################################

gcm = "CanESM2"
rcp = "rcp45"
d = read_csv(paste("R Inputs/Data/flow-multipliers/FlowMultipliers",gcm,rcp,"csv", sep="."))
growth = d %>% filter(FlowGroupID=="Growth") %>% mutate(FlowMultiplierTypeID="Climate")
q10 = d %>% filter(FlowGroupID!="Growth") %>% mutate(FlowMultiplierTypeID="Q10")
write_csv(growth, paste("R Inputs/Data/flow-multipliers/growth.", gcm, ".", rcp, ".csv", sep=""))
write_csv(q10, paste("R Inputs/Data/flow-multipliers/q10.", gcm, ".", rcp, ".csv", sep=""))

gcm = "CanESM2"
rcp = "rcp85"
d = read_csv(paste("R Inputs/Data/flow-multipliers/FlowMultipliers",gcm,rcp,"csv", sep="."))
growth = d %>% filter(FlowGroupID=="Growth") %>% mutate(FlowMultiplierTypeID="Climate")
q10 = d %>% filter(FlowGroupID!="Growth") %>% mutate(FlowMultiplierTypeID="Q10")
write_csv(growth, paste("R Inputs/Data/flow-multipliers/growth.", gcm, ".", rcp, ".csv", sep=""))
write_csv(q10, paste("R Inputs/Data/flow-multipliers/q10.", gcm, ".", rcp, ".csv", sep=""))

gcm = "CNRM-CM5"
rcp = "rcp45"
d = read_csv(paste("R Inputs/Data/flow-multipliers/FlowMultipliers",gcm,rcp,"csv", sep="."))
growth = d %>% filter(FlowGroupID=="Growth") %>% mutate(FlowMultiplierTypeID="Climate")
q10 = d %>% filter(FlowGroupID!="Growth") %>% mutate(FlowMultiplierTypeID="Q10")
write_csv(growth, paste("R Inputs/Data/flow-multipliers/growth.", gcm, ".", rcp, ".csv", sep=""))
write_csv(q10, paste("R Inputs/Data/flow-multipliers/q10.", gcm, ".", rcp, ".csv", sep=""))

gcm = "CNRM-CM5"
rcp = "rcp85"
d = read_csv(paste("R Inputs/Data/flow-multipliers/FlowMultipliers",gcm,rcp,"csv", sep="."))
growth = d %>% filter(FlowGroupID=="Growth") %>% mutate(FlowMultiplierTypeID="Climate")
q10 = d %>% filter(FlowGroupID!="Growth") %>% mutate(FlowMultiplierTypeID="Q10")
write_csv(growth, paste("R Inputs/Data/flow-multipliers/growth.", gcm, ".", rcp, ".csv", sep=""))
write_csv(q10, paste("R Inputs/Data/flow-multipliers/q10.", gcm, ".", rcp, ".csv", sep=""))

gcm = "HadGEM2-ES"
rcp = "rcp45"
d = read_csv(paste("R Inputs/Data/flow-multipliers/FlowMultipliers",gcm,rcp,"csv", sep="."))
growth = d %>% filter(FlowGroupID=="Growth") %>% mutate(FlowMultiplierTypeID="Climate")
q10 = d %>% filter(FlowGroupID!="Growth") %>% mutate(FlowMultiplierTypeID="Q10")
write_csv(growth, paste("R Inputs/Data/flow-multipliers/growth.", gcm, ".", rcp, ".csv", sep=""))
write_csv(q10, paste("R Inputs/Data/flow-multipliers/q10.", gcm, ".", rcp, ".csv", sep=""))

gcm = "HadGEM2-ES"
rcp = "rcp85"
d = read_csv(paste("R Inputs/Data/flow-multipliers/FlowMultipliers",gcm,rcp,"csv", sep="."))
growth = d %>% filter(FlowGroupID=="Growth") %>% mutate(FlowMultiplierTypeID="Climate")
q10 = d %>% filter(FlowGroupID!="Growth") %>% mutate(FlowMultiplierTypeID="Q10")
write_csv(growth, paste("R Inputs/Data/flow-multipliers/growth.", gcm, ".", rcp, ".csv", sep=""))
write_csv(q10, paste("R Inputs/Data/flow-multipliers/q10.", gcm, ".", rcp, ".csv", sep=""))

gcm = "MIROC5"
rcp = "rcp45"
d = read_csv(paste("R Inputs/Data/flow-multipliers/FlowMultipliers",gcm,rcp,"csv", sep="."))
growth = d %>% filter(FlowGroupID=="Growth") %>% mutate(FlowMultiplierTypeID="Climate")
q10 = d %>% filter(FlowGroupID!="Growth") %>% mutate(FlowMultiplierTypeID="Q10")
write_csv(growth, paste("R Inputs/Data/flow-multipliers/growth.", gcm, ".", rcp, ".csv", sep=""))
write_csv(q10, paste("R Inputs/Data/flow-multipliers/q10.", gcm, ".", rcp, ".csv", sep=""))

gcm = "MIROC5"
rcp = "rcp85"
d = read_csv(paste("R Inputs/Data/flow-multipliers/FlowMultipliers",gcm,rcp,"csv", sep="."))
growth = d %>% filter(FlowGroupID=="Growth") %>% mutate(FlowMultiplierTypeID="Climate")
q10 = d %>% filter(FlowGroupID!="Growth") %>% mutate(FlowMultiplierTypeID="Q10")
write_csv(growth, paste("R Inputs/Data/flow-multipliers/growth.", gcm, ".", rcp, ".csv", sep=""))
write_csv(q10, paste("R Inputs/Data/flow-multipliers/q10.", gcm, ".", rcp, ".csv", sep=""))





################################################
# CO2 Fertilization Scenarios
################################################

# Read in the historical observations from Mauna Loa
mlo = read_csv("R Inputs/Data/flow-multipliers/co2/co2_annmean_mlo.csv") %>%
  rename("rcp26"="mean") %>% mutate(rcp45=rcp26, rcp60=rcp26, rcp85=rcp26) %>% gather(RCP, co2, 2:5)

ggplot(mlo, aes(x=year,y=co2, color=RCP)) + geom_line() + scale_color_viridis_d() + theme_bw()

# CO2 Multiplier

co2ambient = (mlo %>% filter(RCP=="rcp26", year==1998))$co2
co2550 = 550
co2Diff = co2550-co2ambient

norbyLow = 0.05
norbyMedLow = 0.10
norbyMed = 0.15
norbyMedHigh = 0.20
norbyHigh = 0.25

co2Low = norbyLow/co2Diff
co2MedLow = norbyMedLow/co2Diff
co2Med = norbyMed/co2Diff
co2MedHigh = norbyMedHigh/co2Diff
co2High = norbyHigh/co2Diff

# Create an empty dataframe with all the years and rcps 
emptydf = tibble(year=seq(2017,2100,1), rcp26=NA, rcp45=NA, rcp60=NA, rcp85=NA) %>% gather(RCP, co2, 2:5)

# Bind the empty data frame and MLO together
df = bind_rows(mlo, emptydf)

# Read in the RCP projections (decadal, from RCP database)
rcp = read_csv("R Inputs/Data/flow-multipliers/co2/co2_rcpdb.csv") %>% gather(RCP, co2, 2:5)

ggplot(rcp, aes(x=year,y=co2, color=RCP)) + geom_line(size=2) + scale_color_viridis_d() + theme_bw()

# Join historical and RCP data frames and interpolate annual values for projection data
df2 = df %>% left_join(rcp, by=c("year","RCP")) %>%
  mutate(co2=ifelse(is.na(co2.x), co2.y, co2.x)) %>% arrange(RCP, year) %>%
  mutate(new=na.approx(co2, maxgap=10)) %>% select(year, RCP, new) %>% rename("co2"="new") %>%
  group_by(RCP) %>% arrange(RCP, year) %>%
  mutate(co2Change=co2-lag(co2)) %>% filter(year>2001) %>%
  mutate(co2ChangeCum=cumsum(co2Change)) %>%
  mutate(nppMultLow=1+co2ChangeCum*co2Low) %>%
  mutate(nppMultMedLow=1+co2ChangeCum*co2MedLow) %>%
  mutate(nppMultMed=1+co2ChangeCum*co2Med) %>%
  mutate(nppMultMedHigh=1+co2ChangeCum*co2MedHigh) %>%
  mutate(nppMultHigh=1+co2ChangeCum*co2High)
head(df2)

# Create the flow multiplier datasheets (rcp 8.5 limited to 600 ppm)
df3 = df2 %>% select(year, RCP, nppMultLow, nppMultMedLow, nppMultMed, nppMultMedHigh, nppMultHigh) %>% 
  gather(CFE, Multiplier, 3:7) %>% rename("Timestep"="year", "Value"="Multiplier") %>% 
  mutate(FlowMultiplierTypeID="CFE", FlowGroupID="Growth") %>%
  select(Timestep, FlowMultiplierTypeID,FlowGroupID,Value, RCP, CFE)

cfe = "nppMultLow"
rcp = "rcp45"
timestep = 2100
d = df3 %>% ungroup() %>% filter(RCP==rcp, CFE==cfe, Timestep<=timestep) %>% select(Timestep,FlowMultiplierTypeID, FlowGroupID, Value) %>%
  write_csv("R Inputs/Data/flow-multipliers/cfe.low.rcp45.csv")

cfe = "nppMultMedLow"
rcp = "rcp45"
timestep = 2100
d = df3 %>% ungroup() %>% filter(RCP==rcp, CFE==cfe, Timestep<=timestep) %>% select(Timestep,FlowMultiplierTypeID, FlowGroupID, Value) %>%
  write_csv("R Inputs/Data/flow-multipliers/cfe.medlow.rcp45.csv")

cfe = "nppMultMed"
rcp = "rcp45"
timestep = 2100
d = df3 %>% ungroup() %>% filter(RCP==rcp, CFE==cfe, Timestep<=timestep) %>% select(Timestep,FlowMultiplierTypeID, FlowGroupID, Value) %>%
  write_csv("R Inputs/Data/flow-multipliers/cfe.med.rcp45.csv")

cfe = "nppMultMedHigh"
rcp = "rcp45"
timestep = 2100
d = df3 %>% ungroup() %>% filter(RCP==rcp, CFE==cfe, Timestep<=timestep) %>% select(Timestep,FlowMultiplierTypeID, FlowGroupID, Value) %>%
  write_csv("R Inputs/Data/flow-multipliers/cfe.medhigh.rcp45.csv")

cfe = "nppMultHigh"
rcp = "rcp45"
timestep = 2100
d = df3 %>% ungroup() %>% filter(RCP==rcp, CFE==cfe, Timestep<=timestep) %>% select(Timestep,FlowMultiplierTypeID, FlowGroupID, Value) %>%
  write_csv("R Inputs/Data/flow-multipliers/cfe.high.rcp45.csv")


  
  
cfe = "nppMultLow"
rcp = "rcp85"
timestep = 2060
d = df3 %>% ungroup() %>% filter(RCP==rcp, CFE==cfe, Timestep<=timestep) %>% select(Timestep,FlowMultiplierTypeID, FlowGroupID, Value) %>%
  write_csv("R Inputs/Data/flow-multipliers/cfe.low.rcp85.csv")

cfe = "nppMultMedLow"
rcp = "rcp85"
timestep = 2060
d = df3 %>% ungroup() %>% filter(RCP==rcp, CFE==cfe, Timestep<=timestep) %>% select(Timestep,FlowMultiplierTypeID, FlowGroupID, Value) %>%
  write_csv("R Inputs/Data/flow-multipliers/cfe.medlow.rcp85.csv")

cfe = "nppMultMed"
rcp = "rcp85"
timestep = 2060
d = df3 %>% ungroup() %>% filter(RCP==rcp, CFE==cfe, Timestep<=timestep) %>% select(Timestep,FlowMultiplierTypeID, FlowGroupID, Value) %>%
  write_csv("R Inputs/Data/flow-multipliers/cfe.med.rcp85.csv")

cfe = "nppMultMedHigh"
rcp = "rcp85"
timestep = 2060
d = df3 %>% ungroup() %>% filter(RCP==rcp, CFE==cfe, Timestep<=timestep) %>% select(Timestep,FlowMultiplierTypeID, FlowGroupID, Value) %>%
  write_csv("R Inputs/Data/flow-multipliers/cfe.medhigh.rcp85.csv")

cfe = "nppMultHigh"
rcp = "rcp85"
timestep = 2060
d = df3 %>% ungroup() %>% filter(RCP==rcp, CFE==cfe, Timestep<=timestep) %>% select(Timestep,FlowMultiplierTypeID, FlowGroupID, Value) %>%
  write_csv("R Inputs/Data/flow-multipliers/cfe.high.rcp85.csv")










































  
  

ggplot(df3, aes(x=Timestep, y=Multiplier, group=interaction(RCP, CFE), color=CFE)) +
  geom_line() + geom_point() +
  theme_bw() +
  facet_wrap(~RCP)

ggplot(df6, aes(x=Timestep, y=Multiplier, group=interaction(RCP, CFE), color=CFE)) +
  geom_line() + geom_point() +
  theme_bw() +
  facet_wrap(~RCP)



