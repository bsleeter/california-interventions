library(foreign)



ca_mask = raster("R Inputs/Data/initial-conditions/IC_Ecoregions_1km.tif")
plot(ca_mask)

nlcd_rat = read.dbf("I:/GIS-Raster/Land Cover/NLCD/2016/1km/nlcd_combine_2001_2006_2011_2016_1km.tif.vat.dbf") %>% as_tibble() %>% rename("ID"="Value")

r = raster("I:/GIS-Raster/Land Cover/NLCD/2016/1km/nlcd_combine_2001_2006_2011_2016_1km.tif", RAT=TRUE)
r = projectRaster(r, ca_mask, method="ngb")
r = mask(r, ca_mask)
plot(r)


r = ratify(r)
rat = levels(r)[[1]]
rat = left_join(rat, nlcd_rat)
levels(r) = rat

head(x)
head(rat)

x = data.frame(freq(r)) %>% rename("ID"="value") %>% left_join(rat, by="ID") %>% select(-Count) %>% rename("Count"="count")



##### Add Developed classes to Initial State Class Map #####

Con=function(condition, trueValue, falseValue){
  return(condition * trueValue + (!condition)*falseValue)
}


stateClass = raster("R Inputs/Data/initial-conditions/IC_StateClass_1km.tif")
nlcd2001 = raster("I:/GIS-Raster/Land Cover/NLCD/2016/1km/NLCD_2001_Land_Cover_L48_2011_1km.tif")

nlcd2001 = projectRaster(nlcd2001, stateClass, method="ngb")
nlcd2001 = mask(nlcd2001, stateClass)
nlcd2001 = reclassify(nlcd2001, c(0,20,0, 21,21,21, 22,22,22, 23,23,23, 24,24,24, 25,Inf,0))

newRaster = Con(nlcd2001>0,nlcd2001,stateClass)
newRaster = Con(newRaster==2,22,newRaster)
newRaster = Con(newRaster==3,25,newRaster)

writeRaster(newRaster, "R Inputs/Initial Conditions/IC_StateClass_Dev_1km.tif", format="GTiff", overwrite=T)
plot(newRaster)
freq(newRaster)

plot(stateClass)
freq(stateClass)

plot(nlcd2001)
freq(nlcd2001)


##### Urbanization Proportions - State-Wide #####

intFrom = data.frame(FromClass=c(21,22,23,24), FromStateClassID=c("Open", "Low", "Medium", "High"))
intTo = data.frame(ToClass=c(21,22,23,24), ToStateClassID=c("Open", "Low", "Medium", "High"))

# 2001-2006
urb1 = rat %>% filter(!NLCD_2001_ %in% c(21,22,23,24), NLCD_2006_ %in% c(21,22,23,24)) %>%  
  group_by(NLCD_2006_) %>% summarise(area = sum(Count)) %>% rename("ToClass"="NLCD_2006_") %>% left_join(intTo) %>% 
  mutate(TransitionGroupID="Urbanization", Year="2001-2006") %>% select(Year, ToStateClassID, TransitionGroupID, area)
urb1

urb2 = rat %>% filter(!NLCD_2006_ %in% c(21,22,23,24), NLCD_2011_ %in% c(21,22,23,24)) %>%  
  group_by(NLCD_2011_) %>% summarise(area = sum(Count)) %>% rename("ToClass"="NLCD_2011_") %>% left_join(intTo) %>% 
  mutate(TransitionGroupID="Urbanization", Year="2006-2011") %>% select(Year, ToStateClassID, TransitionGroupID, area)
urb2

urb3 = rat %>% filter(!NLCD_2011_ %in% c(21,22,23,24), NLCD_2016_ %in% c(21,22,23,24)) %>%  
  group_by(NLCD_2016_) %>% summarise(area = sum(Count)) %>% rename("ToClass"="NLCD_2016_") %>% left_join(intTo) %>% 
  mutate(TransitionGroupID="Urbanization", Year="2011-2016") %>% select(Year, ToStateClassID, TransitionGroupID, area)
urb3

urbAll = bind_rows(urb1,urb2,urb3) %>% group_by(ToStateClassID,TransitionGroupID) %>% summarise(Area=sum(area), Sd=sd(area), Min=min(area), Max=max(area)) %>%
  ungroup() %>% 
  mutate(Amount=Area/sum(Area)) %>% 
  mutate(TransitionGroupID=paste(TransitionGroupID,": ", ToStateClassID, " [Type]", sep="")) %>%
  mutate(DistributionSD=Sd/Area) %>%
  mutate(DistributionType="Normal", DistributionFrequencyID="Iteration and Timestep") %>%
  select(TransitionGroupID, Amount,DistributionType, DistributionFrequencyID, DistributionSD)
write_csv(urbAll, "R Inputs/Data/transition-targets/TransitionTargetsRelativeProbabilities.csv")

##### Urban Intensification area targets and proportions - State-Wide #####



int1 = x %>% filter(NLCD_2001_ %in% c(21,22,23,24), NLCD_2006_ %in% c(21,22,23,24)) %>% filter(NLCD_2001_ != NLCD_2006_) %>%
  group_by(NLCD_2001_, NLCD_2006_) %>% summarise(Area = sum(Count)) %>% ungroup() %>% rename("FromClass"="NLCD_2001_", "ToClass"="NLCD_2006_") %>% mutate(Year="2001-2006")

int2 = x %>% filter(NLCD_2006_ %in% c(21,22,23,24), NLCD_2011_ %in% c(21,22,23,24)) %>% filter(NLCD_2006_ != NLCD_2011_) %>%
  group_by(NLCD_2006_, NLCD_2011_) %>% summarise(Area = sum(Count)) %>% ungroup() %>% rename("FromClass"="NLCD_2006_", "ToClass"="NLCD_2011_") %>% mutate(Year="2006-2011")

int3 = x %>% filter(NLCD_2011_ %in% c(21,22,23,24), NLCD_2016_ %in% c(21,22,23,24)) %>% filter(NLCD_2011_ != NLCD_2016_) %>%
  group_by(NLCD_2011_, NLCD_2016_) %>% summarise(Area = sum(Count)) %>% ungroup() %>% rename("FromClass"="NLCD_2011_", "ToClass"="NLCD_2016_") %>% mutate(Year="2011-2016")

intAll = bind_rows(int1,int2,int3) %>% group_by(FromClass,ToClass) %>% summarise(Mean=mean(Area)/5, StDev=sd(Area)/5, Min=min(Area)/5, Max=max(Area)/5) %>% 
  left_join(intFrom) %>% left_join(intTo) %>% ungroup() %>% select(FromStateClassID,ToStateClassID,Mean,StDev,Min,Max)
intAll

intProp = bind_rows(int1,int2,int3) %>% group_by(FromClass,ToClass) %>% summarise(Amount=mean(Area)/5, DistributionSD=sd(Area)/5, DistributionMin=min(Area)/5, DistributionMax=max(Area)/5) %>% 
  ungroup() %>% left_join(intFrom) %>% left_join(intTo) %>% ungroup() %>% 
  select(FromStateClassID,ToStateClassID,Amount,DistributionSD,DistributionMin,DistributionMax)

intensificationTargets = intProp %>% 
  mutate(Iteration="NA", Timestep=2002, StratumID="NA", SecondaryStratumID="NA", TertiaryStratumID="NA", 
         TransitionGroupID=paste("Intensification:",FromStateClassID,"to",ToStateClassID,"[Type]", sep=" "),
         DistributionType = "Normal", DistributionFrequencyID="Iteration and Timestep", DistributionMin="NA", DistributionMax="NA") %>%
  select(Iteration, Timestep, StratumID, SecondaryStratumID, TertiaryStratumID, TransitionGroupID, Amount, DistributionType, DistributionFrequencyID, DistributionSD, DistributionMin, DistributionMax)
write_csv(intensificationTargets, "R Inputs/Data/transition-targets/TransitionTargetsIntensification.csv")

intensificationTargets = intProp %>% 
  mutate(Timestep=2002, TransitionGroupID=paste("Intensification:",FromStateClassID,"to",ToStateClassID,"[Type]", sep=" "),
         DistributionType = "Normal", DistributionFrequencyID="Iteration and Timestep") %>%
  select(Timestep,TransitionGroupID, Amount, DistributionType, DistributionFrequencyID, DistributionSD)
write_csv(intensificationTargets, "R Inputs/Data/transition-targets/TransitionTargetsIntensification.csv")












r1 = r
r1 = ratify(r1)
levels(r1) = rp1


plot(rp1)





r1 = deratify(r, "NLCD_2006_")
plot(r1)

z = as.data.frame(zonal(r, ca_mask))
z


















r2 = data.frame(zonal(r1, ca_mask, sum))
plot(r1)





