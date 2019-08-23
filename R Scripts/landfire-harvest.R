
library(raster)
library(rasterVis)
library(tidyverse)
library(rsyncrosim)
library(landscapemetrics)

# Preprocessing ----------------------------------

crs = "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"

# Get a list of Ecoregion names
econame = datasheet(myProject, "STSim_Stratum", empty = F, optional = T)

# Read in the ecoregions raster
ecoreg = raster("R Inputs/Initial Conditions/IC_Ecoregions_1km.tif")
plot(ecoreg)

# Read in the state class raster and convert to binary for forest/non-forest
lulc = raster("R Inputs/Initial Conditions/IC_StateClass_1km.tif")
lulc = reclassify(lulc, c(-Inf,5,NA, 5,6,1, 6,Inf,NA))
plot(lulc)

# Read in the PAD/GAP and Ecoregions harvest mask (Harvest spatial multiplier) and mask only forest cells from LULC map
harv_mask = raster("R Inputs/Spatial Multipliers/SM_Harvest_v2_Ecomask_1km.tif")
harv_mask = reclassify(harv_mask, c(-Inf,0,NA, 1,Inf,1))
harv_mask = mask(harv_mask, lulc)
plot(harv_mask)

# Read in time series of harvest rasters from Landfire (1999-2014) ----------------------------------
lf_list = list.files(path="R Inputs/Data/landfire/", pattern="*.tif$")
lf_dist = stack(paste("R Inputs/Data/landfire/",lf_list, sep=""))
names(lf_dist) = seq(1999,2014,1)
lf_dist = projectRaster(lf_dist, harv_mask, method="ngb")

# Mask the raster stack using the harvest mask raster and plot one year
lf_dist_mask = mask(lf_dist, harv_mask)
plot(lf_dist_mask$X2013)

# Reclassify the harvest maps into either clearcut or selection
# Clearcut
lf_dist_clear = reclassify(lf_dist_mask, c(-Inf,0,NA, 0,1,1, 1,Inf,NA))
names(lf_dist_clear) = seq(1999,2014,1)
plot(lf_dist_clear$X2002)
# Selection
lf_dist_select = reclassify(lf_dist_mask, c(-Inf,1,NA, 1,Inf,1))
names(lf_dist_select) = seq(1999,2014,1)


# Calculate historical distributions for each ecoregion and harvest type----------------------------------
# Clearcut
lf_dist_eco_clear = data.frame(zonal(lf_dist_clear, ecoreg, fun=sum)) %>%
  gather(Year, Amount, 2:17) %>% arrange(zone, Year) %>% mutate(Year=rep(seq(1999,2014,1),12)) %>% rename("ID"="zone") %>%
  left_join(econame, by="ID") %>% rename("StratumID"="Name") %>% select(StratumID, Year, Amount) %>%
  mutate(DistributionTypeID="Historical Rate: Forest Clearcut",
         ExternalVariableTypeID="Historical Year: Forest Harvest",
         ExternalVariableMin=Year,
         ExternalVariableMax=Year,
         Value=Amount) %>% 
  select(StratumID, DistributionTypeID, ExternalVariableTypeID, ExternalVariableMin, ExternalVariableMax, Value)
head(lf_dist_eco_clear)

# Selection
lf_dist_eco_select = data.frame(zonal(lf_dist_select, ecoreg, fun=sum)) %>%
  gather(Year, Amount, 2:17) %>% arrange(zone, Year) %>% mutate(Year=rep(seq(1999,2014,1),12)) %>% rename("ID"="zone") %>%
  left_join(econame, by="ID") %>% rename("StratumID"="Name") %>% select(StratumID, Year, Amount) %>%
  mutate(DistributionTypeID="Historical Rate: Forest Selection",
         ExternalVariableTypeID="Historical Year: Forest Harvest",
         ExternalVariableMin=Year,
         ExternalVariableMax=Year,
         Value=Amount) %>% 
  select(StratumID, DistributionTypeID, ExternalVariableTypeID, ExternalVariableMin, ExternalVariableMax, Value)
head(lf_dist_eco_select)

forest_harvest_distribution = bind_rows(lf_dist_eco_clear, lf_dist_eco_select)
head(forest_harvest_distribution)
write_csv(forest_harvest_distribution, "R Inputs/Data/landfire/forest_harvest_distribution.csv")


# Calculate patch size distribution for each harvest type ----------------------------------
# Clearcut
patcharea_clear = lsm_p_area(lf_dist_clear)

dfclear = patcharea_clear %>% filter(class==1) %>% mutate(MaxArea=value/100) %>% group_by(MaxArea) %>% mutate(x=sum(MaxArea)) %>% summarise(Area=mean(x)) %>% 
  mutate(CellCount=Area/MaxArea, RelativeAmount=CellCount/sum(CellCount),TransitionGroupID="Management: Forest Clearcut [Type]")

dfclear_1 = dfclear %>% filter(MaxArea<=11) %>% select(MaxArea, TransitionGroupID, RelativeAmount)
dfclear_2 = dfclear %>% filter(MaxArea>11) %>% summarise(RelativeAmount=sum(RelativeAmount)) %>% mutate(MaxArea=34,TransitionGroupID="Management: Forest Clearcut [Type]")
dfclear_3 = bind_rows(dfclear_1, dfclear_2)
clearcut_size_df = data.frame(Timestep=2002,
                          StratumID="",
                          TransitionGroupID=dfclear_3$TransitionGroupID,
                          MaximumArea=dfclear_3$MaxArea,
                          RelativeAmount=dfclear_3$RelativeAmount)

# Selection
patcharea_select = lsm_p_area(lf_dist_select)

dfselect = patcharea_select %>% filter(class==1) %>% mutate(MaxArea=value/100) %>% group_by(MaxArea) %>% mutate(x=sum(MaxArea)) %>% summarise(Area=mean(x)) %>% 
  mutate(CellCount=Area/MaxArea, RelativeAmount=CellCount/sum(CellCount),TransitionGroupID="Management: Forest Selection [Type]")

dfselect_1 = dfselect %>% filter(MaxArea<=11) %>% select(MaxArea, TransitionGroupID, RelativeAmount)
dfselect_2 = dfselect %>% filter(MaxArea>11) %>% summarise(RelativeAmount=sum(RelativeAmount)) %>% mutate(MaxArea=34,TransitionGroupID="Management: Forest Selection [Type]")
dfselect_3 = bind_rows(dfselect_1, dfselect_2)
select_size_df = data.frame(Timestep=2002,
                              StratumID="",
                              TransitionGroupID=dfselect_3$TransitionGroupID,
                              MaximumArea=dfselect_3$MaxArea,
                              RelativeAmount=dfselect_3$RelativeAmount)

# Merge the size distribution data frames and create a datafeed to import into model
harvest_size_distribution = bind_rows(clearcut_size_df, select_size_df)
write_csv(harvest_size_distribution, "R Inputs/Data/landfire/harvest_size_distribution.csv")


# Create historical spatial multipliers ----------------------------------

# Clearcut
sm_clearcut = reclassify(lf_dist_mask, c(-Inf,0,0, 0,1,1, 1,Inf,0))
sm_clearcut[is.na(sm_clearcut[])] = 0
sm_clearcut = mask(sm_clearcut, ecoreg)
names(sm_clearcut) = seq(1999,2014,1)
plot(sm_clearcut$X2002)
crs(sm_clearcut) = crs
writeRaster(sm_clearcut, filename=paste("R Inputs/Data/landfire/spatial-multipliers/clearcut/sm_clearcut_", names(sm_clearcut), sep=""), format="GTiff", overwrite=T, bylayer=T)

# Selection
sm_selection = reclassify(lf_dist_mask, c(-Inf,1,0, 1,Inf,1))
sm_selection[is.na(sm_selection[])] = 0
sm_selection = mask(sm_selection, ecoreg)
names(sm_selection) = seq(1999,2014,1)
plot(sm_selection$X2002)
crs(sm_selection) = crs
writeRaster(sm_selection, filename=paste("R Inputs/Data/landfire/spatial-multipliers/selection/sm_selection_", names(sm_clearcut), sep=""), format="GTiff", overwrite=T, bylayer=T)
