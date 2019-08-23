

library(cowplot)
library(tidyverse)
library(knitr)
library(kableExtra)
library(rsyncrosim)
library(zoo)



##### Create Model Inputs ------------------------------

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

df3 = df2 %>% select(year, RCP, nppMultLow, nppMultMedLow, nppMultMed, nppMultMedHigh, nppMultHigh) %>% 
  gather(CFE, Multiplier, 3:7) %>% filter(RCP %in% c("rcp45", "rcp85")) %>% rename("Timestep"="year")

df4 = df2 %>% filter(co2<600) %>% select(year, RCP, nppMultLow, nppMultMedLow, nppMultMed, nppMultMedHigh, nppMultHigh) %>% 
  gather(CFE, Multiplier, 3:7) %>% filter(RCP %in% c("rcp45", "rcp85")) %>% rename("Timestep"="year")

df5 = df2 %>% filter(year==2059) %>% select(year, RCP, nppMultLow, nppMultMedLow, nppMultMed, nppMultMedHigh, nppMultHigh) %>% 
  gather(CFE, Limit, 3:7) %>% filter(RCP %in% c("rcp45", "rcp85")) %>% select(-year)

df6 = df2 %>% filter(co2>600) %>% select(year, RCP, nppMultLow, nppMultMedLow, nppMultMed, nppMultMedHigh, nppMultHigh) %>% 
  gather(CFE, Multiplier, 3:7) %>% filter(RCP %in% c("rcp45", "rcp85")) %>% left_join(df5, by=c("RCP", "CFE")) %>%
  rename("Timestep"="year") %>% mutate(Multiplier=Limit) %>% bind_rows(df4) %>% arrange(RCP, CFE, Timestep)

ggplot(df3, aes(x=Timestep, y=Multiplier, group=interaction(RCP, CFE), color=CFE)) +
  geom_line() + geom_point() +
  theme_bw() +
  facet_wrap(~RCP)

ggplot(df6, aes(x=Timestep, y=Multiplier, group=interaction(RCP, CFE), color=CFE)) +
  geom_line() + geom_point() +
  theme_bw() +
  facet_wrap(~RCP)


# Read in base Flow Multipliers
cfeLow.rcp45 = df3 %>% filter(RCP=="rcp45", CFE=="nppMultLow") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")
cfeMedLow.rcp45 = df3 %>% filter(RCP=="rcp45", CFE=="nppMultMedLow") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")
cfeMed.rcp45 = df3 %>% filter(RCP=="rcp45", CFE=="nppMultMed") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")
cfeMedHigh.rcp45 = df3 %>% filter(RCP=="rcp45", CFE=="nppMultMedHigh") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")
cfeHigh.rcp45 = df3 %>% filter(RCP=="rcp45", CFE=="nppMultHigh") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")

cfeLow.rcp85 = df3 %>% filter(RCP=="rcp85", CFE=="nppMultLow") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")
cfeMedLow.rcp85 = df3 %>% filter(RCP=="rcp85", CFE=="nppMultMedLow") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")
cfeMed.rcp85 = df3 %>% filter(RCP=="rcp85", CFE=="nppMultMed") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")
cfeMedHigh.rcp85 = df3 %>% filter(RCP=="rcp85", CFE=="nppMultMedHigh") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")
cfeHigh.rcp85 = df3 %>% filter(RCP=="rcp85", CFE=="nppMultHigh") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")

cfeLowLim.rcp85 = df6 %>% filter(RCP=="rcp85", CFE=="nppMultLow") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")
cfeMedLowLim.rcp85 = df6 %>% filter(RCP=="rcp85", CFE=="nppMultMedLow") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")
cfeMedLim.rcp85 = df6 %>% filter(RCP=="rcp85", CFE=="nppMultMed") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")
cfeMedHighLim.rcp85 = df6 %>% filter(RCP=="rcp85", CFE=="nppMultMedHigh") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")
cfeHighLim.rcp85 = df6 %>% filter(RCP=="rcp85", CFE=="nppMultHigh") %>% ungroup() %>% select(Timestep, Multiplier) %>% mutate(FlowGroupID="Growth")


# RCP45 CFE Scenarios (Flow Multipliers)
fm_canesm45 = read_csv("R Inputs/Data/flow-multipliers/FlowMultipliers.CanESM2.rcp45.csv")
fm_canesm45_ng = fm_canesm45 %>% filter(FlowGroupID!="Growth")

fm_cfeLow.rcp45 = fm_canesm45 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeLow.rcp45, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm45_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp45.CFElow.csv")

fm_cfeMedLow.rcp45 = fm_canesm45 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeMedLow.rcp45, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm45_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp45.CFEmedlow.csv")

fm_cfeMed.rcp45 = fm_canesm45 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeMed.rcp45, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm45_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp45.CFEmed.csv")

fm_cfeMedHigh.rcp45 = fm_canesm45 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeMedHigh.rcp45, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm45_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp45.CFEmedhigh.csv")

fm_cfeHigh.rcp45 = fm_canesm45 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeHigh.rcp45, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm45_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp45.CFEhigh.csv")

# RCP85 CFE Scenarios (Flow Multipliers)
fm_canesm85 = read_csv("R Inputs/Data/flow-multipliers/FlowMultipliers.CanESM2.rcp85.csv")
fm_canesm85_ng = fm_canesm85 %>% filter(FlowGroupID!="Growth")

fm_cfeLow.rcp85 = fm_canesm85 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeLow.rcp85, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm85_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp85.CFElow.csv")

fm_cfeMedLow.rcp85 = fm_canesm85 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeMedLow.rcp85, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm85_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp85.CFEmedlow.csv")

fm_cfeMed.rcp85 = fm_canesm85 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeMed.rcp85, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm85_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp85.CFEmed.csv")

fm_cfeMedHigh.rcp85 = fm_canesm85 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeMedHigh.rcp85, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm85_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp85.CFEmedhigh.csv")

fm_cfeHigh.rcp85 = fm_canesm85 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeHigh.rcp85, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm85_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp85.CFEhigh.csv")


setwd("D:/california-carbon-futures")

# RCP85 CFE LIMITED (600 ppm) Scenarios (Flow Multipliers)
fm_canesm85 = read_csv("R Inputs/Data/flow-multipliers/FlowMultipliers.CanESM2.rcp85.csv")
fm_canesm85_ng = fm_canesm85 %>% filter(FlowGroupID!="Growth")

fm_cfeLow.rcp85 = fm_canesm85 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeLowLim.rcp85, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm85_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp85.CFElowLim.csv")

fm_cfeMedLow.rcp85 = fm_canesm85 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeMedLowLim.rcp85, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm85_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp85.CFEmedlowLim.csv")

fm_cfeMed.rcp85 = fm_canesm85 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeMedLim.rcp85, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm85_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp85.CFEmedLim.csv")

fm_cfeMedHigh.rcp85 = fm_canesm85 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeMedHighLim.rcp85, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm85_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp85.CFEmedhighLim.csv")

fm_cfeHigh.rcp85 = fm_canesm85 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeHighLim.rcp85, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm85_ng) %>%
  write_csv("R Inputs/Data/flow-multipliers/co2/FlowMultipliers.CanESM2.rcp85.CFEhighLim.csv")



ggplot(fm_cfeLow.rcp45, aes(x=Timestep, y=newVal)) + geom_line()+ facet_wrap(~StratumID) + ylim(0,2) + geom_smooth(method="lm")
ggplot(fm_cfeLow.rcp45, aes(x=Timestep, y=Value)) + geom_line() + facet_wrap(~StratumID) + ylim(0,2) + geom_smooth(method="lm")






# All RCP85 CFE LIMITED (600 ppm) Scenarios (Flow Multipliers)
fm_canesm85 = read_csv("Build/model_base/R Inputs/Flow Multipliers/FlowMultipliers.CanESM2.rcp85.csv")
fm_cnrm85 = read_csv("Build/model_base/R Inputs/Flow Multipliers/FlowMultipliers.CNRM-CM5.rcp85.csv")
fm_hadgem85 = read_csv("Build/model_base/R Inputs/Flow Multipliers/FlowMultipliers.HadGEM2-ES.rcp85.csv")
fm_miroc85 = read_csv("Build/model_base/R Inputs/Flow Multipliers/FlowMultipliers.MIROC5.rcp85.csv")

fm_canesm85_ng = fm_canesm85 %>% filter(FlowGroupID!="Growth")
fm_cnrm85_ng = fm_cnrm85 %>% filter(FlowGroupID!="Growth")
fm_hadgem85_ng = fm_hadgem85 %>% filter(FlowGroupID!="Growth")
fm_miroc85_ng = fm_miroc85 %>% filter(FlowGroupID!="Growth")

fm_CanESM2.rcp85.cfeLow = fm_canesm85 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeLowLim.rcp85, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_canesm85_ng) %>%
  write_csv("Build/model_base/R Inputs/Flow Multipliers/CFE/FlowMultipliers.CanESM2.rcp85.cfeLow.csv")

fm_CNRM-CM5.rcp85.cfeLow = fm_cnrm85 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeLowLim.rcp85, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_cnrm85_ng) %>%
  write_csv("Build/model_base/R Inputs/Flow Multipliers/CFE/FlowMultipliers.CNRM-CM5.rcp85.cfeLow.csv")

fm_HadGEM2-ES.rcp85.cfeLow = fm_hadgem85 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeLowLim.rcp85, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_hadgem85_ng) %>%
  write_csv("Build/model_base/R Inputs/Flow Multipliers/CFE/FlowMultipliers.HadGEM2-ES.rcp85.cfeLow.csv")

fm_MIROC5.rcp85.cfeLow = fm_miroc85 %>% filter(FlowGroupID=="Growth", Timestep>2001) %>% left_join(cfeLowLim.rcp85, by=c("Timestep","FlowGroupID")) %>%
  mutate(newVal=Value*Multiplier) %>% select(-Value, -Multiplier) %>% rename("Value"="newVal") %>% bind_rows(fm_miroc85_ng) %>%
  write_csv("Build/model_base/R Inputs/Flow Multipliers/CFE/FlowMultipliers.MIROC5.rcp85.cfeLow.csv")





































##### Analyze Results -------------------------------------

# Set the Syncro Sim program directory
# *************************************************************

programFolder = "C:/Program Files/SyncroSim" # Set this to location of SyncroSim installation

# Start a SyncroSim session
mySession = session(programFolder) # Start a session with SyncroSim

# Set the current working directory
setwd("D:/california-carbon-futures/Build/model_base") # Check this is correct for your computer!
getwd() # Show the current working directory

# Create and setup a new Library
myLibrary = ssimLibrary(name = "ccf_v4-cfe", model = "stsim", session = mySession)
list.files() # Check that the new library was created on disk

# Display internal names of all the library's datasheets - corresponds to the the 'File-Library Properties' menu in SyncroSim
datasheet(myLibrary, summary = T)

# Create or open a new project
myProject = project(myLibrary, project = "ccf_v4-cfe") # Also creates a new project (if it doesn't exist already)

# Run Scenarios & Get Results
# *************************************************************

# Create a list of the output scenario IDs
resultScenarios = c(202,203,204,205,206,208,209,210,211,212,220,221,222,223,224)
datasheet(myProject, scenario=185)

# Get a dataframe of the state class tabular output (for both scenarios combined)
CFEoutputStocks = datasheet(myProject, scenario=resultScenarios, name="SF_OutputStock")
CFEoutputFlows = datasheet(myProject, scenario=resultScenarios, name="SF_OutputFlow")
str(CFEoutputStocks)
head(CFEoutputStocks)
write_csv(CFEoutputStocks, "D:/california-carbon-futures/run/summaries/state/data/cfe_stocks_by_scn_iter_ts.csv")
write_csv(CFEoutputFlows, "D:/california-carbon-futures/run/summaries/state/data/cfe_flows_by_scn_iter_ts.csv")

# Read in CFE Scenario Lookup Table
cfeLookup = read_csv("D:/california-carbon-futures/run/summaries/reference/CFEScenarios.csv")

# Get Reference scenario results

cal_tec_by_scn_ts = read_csv("D:/california-carbon-futures/run/summaries/report/Report_Tables/cal_tec_by_scn_ts.csv")
cfe_tec_ref = cal_tec_by_scn_ts %>% filter(LUC=="BAU", GCM=="CanESM2", Ecosystem=="Yes") %>% mutate(CFE="No CFE", CFERate=0.0) %>% 
  select(LUC, GCM, RCP, CFE, CFERate, Timestep, Mean, Lower, Upper) 

d = cfe_tec_ref %>% filter(RCP=="rcp85") %>% mutate(RCP="rcp85-600")
cfe_tec_ref = bind_rows(cfe_tec_ref, d)


cal_necb_by_scn = read_csv("D:/california-carbon-futures/run/summaries/report/Report_Tables/cal_necb_by_scn.csv")
cfe_necb_ref = cal_necb_by_scn %>% filter(LUC=="BAU", GCM=="CanESM2") %>% mutate(CFE="No CFE", CFERate=0.0, Mean=Mean/1000, Lower=Lower/1000, Upper=Upper/1000) %>%
  select(LUC, GCM, RCP, CFE, CFERate, Mean, Lower, Upper) %>%
  add_row(LUC="BAU", GCM="CanESM2", RCP="rcp85-600", CFE="No CFE", CFERate=0, 
          Mean=(filter(cfe_necb_ref, RCP=="rcp85"))$Mean,
          Lower=(filter(cfe_necb_ref, RCP=="rcp85"))$Lower,
          Upper=(filter(cfe_necb_ref, RCP=="rcp85"))$Upper)


# Calculate NPP
head(CFEoutputFlows)
cfeNPP = CFEoutputFlows %>% select(-ProjectID,-ScenarioName,-ParentID,-ParentName) %>% filter(FlowTypeID=="Growth") %>% left_join(cfeLookup, by="ScenarioID") %>%
  group_by(LUC,GCM,RCP,Iteration,CFE,CFERate,Timestep,FlowTypeID) %>% summarise(Amount=sum(Amount)/1000) %>% 
  group_by(GCM,RCP,CFE,CFERate,Timestep) %>% summarise(Mean=mean(Amount), Lower=quantile(Amount,0.025), Upper=quantile(Amount, 0.975)) %>%
  mutate(Flux="NPP", Source="LUCAS CFE") %>% write_csv("state/data/Report_Tables/cfe_npp_by_scn_ts.csv")
  
  
head(cfeNPP)




# Calculate TEC ---------------------------------
cfe_tec = CFEoutputStocks %>% select(ScenarioID, Iteration, Timestep, StratumID, StateClassID,StockTypeID, Amount) %>%
  filter(StockTypeID %in% c("Living Biomass", "Standing Deadwood", "Down Deadwood", "Litter", "Soil")) %>%
  group_by(ScenarioID, Iteration, Timestep) %>% summarise(Amount=sum(Amount)/1000) %>%
  arrange(ScenarioID, Iteration, Timestep) %>% 
  left_join(cfeLookup, by="ScenarioID") %>% 
  ungroup() %>%
  select(LUC, GCM, RCP, CFE, CFERate, Timestep, Amount) %>%
  group_by(LUC, GCM, RCP, CFE, CFERate, Timestep) %>% summarise(Mean=mean(Amount), Lower=min(Amount), Upper=max(Amount)) %>%
  bind_rows(cfe_tec_ref)
cfe_tec

cfe_tec$CFE = factor(cfe_tec$CFE, levels=c("High","MedHigh","Medium","MedLow","Low", "No CFE"))

write_csv(cfe_tec, "D:/california-carbon-futures/run/summaries/report/Report_Tables/cfe_tec.csv")

ggplot(cfe_tec, aes(x=Timestep, y=Mean, fill=CFE)) +
  geom_ribbon(aes(ymin=Lower, ymax=Upper), alpha=0.5) +
  geom_line() +
  scale_fill_viridis_d() +
  facet_wrap(~RCP) +
  theme_bw()



# CFE Difference Plot 2 -------------------------

cfe_tec_all = CFEoutputStocks %>% select(ScenarioID, Iteration, Timestep, StratumID, StateClassID,StockTypeID, Amount) %>%
  filter(StockTypeID %in% c("Living Biomass", "Standing Deadwood", "Down Deadwood", "Litter", "Soil")) %>%
  group_by(ScenarioID, Iteration, Timestep) %>% summarise(Amount=sum(Amount)/1000) %>%
  arrange(ScenarioID, Iteration, Timestep) %>% left_join(cfeLookup, by="ScenarioID") %>% ungroup() %>%
  select(LUC, GCM, RCP, CFE, CFERate, Timestep, Amount) %>% filter(CFE!="No CFE") %>%
  group_by(LUC, GCM, RCP, Timestep) %>% summarise(Mean=mean(Amount), Lower=min(Amount), Upper=max(Amount))
cfe_tec_all

write_csv(cfe_tec_all, "D:/california-carbon-futures/run/summaries/report/Report_Tables/cfe_tec_all.csv")


ggplot() +
  geom_ribbon(data=cfe_tec_all, aes(x=Timestep, ymin=Lower-cfe_tec_ref$Lower, ymax=Upper-cfe_tec_ref$Upper, fill=RCP), alpha=0.7) +
  geom_line(data=cfe_tec_all, aes(x=Timestep, y=Mean-cfe_tec_ref$Mean, color=RCP)) +
  scale_fill_viridis_d() +
  scale_color_viridis_d() +
  facet_wrap(~RCP) +
  labs(x="Year",
       y=expression(TEC~Change~(Tg~C~yr^-1))) +
  theme_bw()
  
  


# Calculate NECB by Scenario -----------------------------------

cfe_necb = CFEoutputStocks %>% select(ScenarioID, Iteration, Timestep, StratumID, StateClassID,StockTypeID, Amount) %>%
  filter(StockTypeID %in% c("Living Biomass", "Standing Deadwood", "Down Deadwood", "Litter", "Soil"), Timestep %in% c(2015, 2100)) %>%
  group_by(ScenarioID, Iteration, Timestep) %>% summarise(Amount=sum(Amount)/1000) %>%
  arrange(ScenarioID, Iteration, Timestep) %>% left_join(cfeLookup, by="ScenarioID") %>% ungroup() %>%
  select(LUC, GCM, RCP, CFE, CFERate, Timestep, Amount) %>%
  group_by(LUC, GCM, RCP, CFE, CFERate) %>% mutate(Amount=Amount-lag(Amount)) %>% filter(Timestep==2100) %>% 
  group_by(LUC, GCM, RCP, CFE, CFERate, Timestep) %>% summarise(Mean=mean(Amount), Lower=min(Amount), Upper=max(Amount)) %>%
  bind_rows(cfe_necb_ref)
cfe_necb$CFE = factor(cfe_necb$CFE, levels=c("High","MedHigh","Medium","MedLow","Low", "No CFE"))
text = data.frame(x=c(0.12,0.12), y=c(-1,1), Label=c("Source", "Sink"))
#cfe_necb = cfe_necb %>% filter(RCP!="rcp85")

write_csv(cfe_necb, "D:/california-carbon-futures/run/summaries/report/Report_Tables/cfe_necb.csv")


ggplot() +
  geom_hline(yintercept = 0, color="gray60") +
  geom_pointrange(data=cfe_necb, aes(x=CFERate*100, y=Mean/85, ymin=Lower/85, ymax=Upper/85, color=RCP),shape=15, size=0.5) +
  geom_line(data=cfe_necb, aes(x=CFERate*100, y=Mean/85, color=RCP), size=0.2, show.legend=FALSE) +
  geom_text(data=text, aes(x=x, y=y, label=Label), size=3) +
  scale_color_manual(name="RCP", labels=c("RCP4.5", "RCP8.5", "RCP8.5-600"), values=c("DarkCyan","SaddleBrown", "SandyBrown")) +
  labs(x="CFE Rate (% increase in NPP per 100ppm increase in CO2)",
       y=expression(NECB~(Tg~C~yr^-1))) +
  theme_bw() +
  theme(legend.position="bottom")









# Historical NECB change due to CFE
cfe_necb_hist_ref = cal_necb_by_ts %>% filter(Timestep<=2015) %>% 
  summarise(Mean=sum(Mean), Lower=sum(Lower), Upper=sum(Upper)) %>%
  mutate(Timestep=2015, CFE="No CFE", CFERate=0)

cal_necb_by_ts

cfe_necb_hist = CFEoutputStocks %>% select(ScenarioID, Iteration, Timestep, StratumID, StateClassID,StockTypeID, Amount) %>%
  filter(StockTypeID %in% c("Living Biomass", "Standing Deadwood", "Down Deadwood", "Litter", "Soil"), Timestep %in% c(2001, 2015)) %>%
  group_by(ScenarioID, Iteration, Timestep) %>% summarise(Amount=sum(Amount)/1000) %>%
  arrange(ScenarioID, Iteration, Timestep) %>% left_join(cfeLookup, by="ScenarioID") %>% ungroup() %>%
  select(LUC, GCM, RCP, CFE, CFERate, Timestep, Amount) %>%
  group_by(LUC, GCM, RCP, CFE, CFERate) %>% mutate(Amount=Amount-lag(Amount)) %>% filter(Timestep==2015) %>% 
  group_by(CFE, CFERate, Timestep) %>% summarise(Mean=mean(Amount), Lower=min(Amount), Upper=max(Amount)) %>%
  bind_rows(cfe_necb_hist_ref)
cfe_necb_hist

cfe_necb_hist$CFE = factor(cfe_necb_hist$CFE, levels=c("High","MedHigh","Medium","MedLow","Low", "No CFE"))


ggplot(cfe_necb_hist, aes(x=CFERate, y=Mean)) +
  geom_crossbar(aes(ymin=Lower, ymax=Upper)) +
  #scale_color_manual(name="RCP", labels=c("RCP4.5", "RCP8.5", "RCP8.5-600"), values=c("DarkCyan","SaddleBrown", "SandyBrown")) +
  labs(x="CFE Rate (% increase in NPP per 100ppm increase in CO2)",
       y=expression(NECB~(Tg~C~yr^-1))) +
  theme_bw() +
  theme(legend.position="bottom")








nocfe = cfe_necb %>% filter(CFE=="No CFE")

cfe_necb_diff = CFEoutputStocks %>% select(ScenarioID, Iteration, Timestep, StratumID, StateClassID,StockTypeID, Amount) %>%
  filter(StockTypeID %in% c("Living Biomass", "Standing Deadwood", "Down Deadwood", "Litter", "Soil"), Timestep %in% c(2001, 2100)) %>%
  group_by(ScenarioID, Iteration, Timestep) %>% summarise(Amount=sum(Amount)/1000) %>%
  arrange(ScenarioID, Iteration, Timestep) %>% left_join(cfeLookup, by="ScenarioID") %>% ungroup() %>% filter(CFE!="No CFE") %>%
  select(LUC, GCM, RCP, CFE, CFERate, Timestep, Amount) %>%
  group_by(LUC, GCM, RCP, CFE, CFERate) %>% mutate(Amount=Amount-lag(Amount)) %>% filter(Timestep==2100) %>% 
  mutate(Amount=Amount-nocfe$Mean) %>%
  group_by(LUC, GCM, RCP, CFE, CFERate, Timestep) %>% summarise(Mean=mean(Amount), Lower=min(Amount), Upper=max(Amount))
cfe_necb_diff  

cfe_necb_diff$CFE = factor(cfe_necb_diff$CFE, levels=c("High","MedHigh","Medium","MedLow","Low"))

ggplot(cfe_necb_diff, aes(x=CFERate, y=Mean, color=RCP)) +
  geom_pointrange(aes(ymin=Lower, ymax=Upper)) +
  geom_line() +
  scale_color_manual(name="RCP", labels=c("RCP4.5", "RCP8.5"), values=c("DarkCyan","SaddleBrown", "Brown")) +
  labs(x="CFE Rate (% increase in NPP / 100 ppm increase in CO2)", y="NECB (Tg C)") +
  theme_bw()





