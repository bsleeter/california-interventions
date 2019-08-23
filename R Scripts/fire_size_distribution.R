library(raster)
library(rgdal)
library(sf)
library(tidyverse)
library(rsyncrosim)
library(fasterize)

eco_short_names = tibble(EcoregionID = c(1,4,5,6,7,8,9,13,14,78,80,81),
                         Name = c("Coast Range", "Cascades", "Sierra Nevada", 
                                  "Oak Woodlands", "Central Valley", "SoCal. Mtns.", 
                                  "East Cascades", "Central Basin", "Mojave Basin", "Klamath Mtns.", "Northern Basin", "Sonoran Basin"))

econame = datasheet(myProject, "STSim_Stratum", empty = F, optional = T)

ecoreg_poly = st_read("R Inputs/Data/calfire/ca_ecoregions_fromraster30m.shp")
ecoreg_poly = st_transform(ecoreg_poly, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")

calfire = st_read("R Inputs/Data/calfire/ca_fire_2002-2017.shp")
calfire = st_transform(calfire, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")

calfire_large = calfire %>% filter(Shape_Area > 1000000)

eco_fire = st_intersection(ecoreg_poly, calfire_large)
eco_fire1 = eco_fire[c("GRIDCODE","OBJECTID","GIS_ACRES","geometry")]
eco_fire1$km = eco_fire1$GIS_ACRES * 0.00404686

eco_fire1_df = tibble(ID=eco_fire1$GRIDCODE,
                          Fire=eco_fire1$OBJECTID,
                          Area=eco_fire1$km)
eco_fire1_df = eco_fire1_df %>% left_join(econame, by="ID") %>% select(ID, Name, Fire, Area)


breaks = c(1,5,10,20,50,100,200,300,500,1000,2500)
eco_dist = eco_fire1_df %>% arrange(ID, Name, Area) %>% 
  mutate(km1=if_else(Area>1 & Area<=2,1,0)) %>%
  mutate(km5=if_else(Area>2 & Area<=5,1,0)) %>%
  mutate(km10=if_else(Area>5 & Area<=10,1,0)) %>%
  mutate(km20=if_else(Area>10 & Area<=20,1,0)) %>%
  mutate(km50=if_else(Area>20 & Area<=50,1,0)) %>%
  mutate(km100=if_else(Area>50 & Area<=100,1,0)) %>%
  mutate(km200=if_else(Area>100 & Area<=200,1,0)) %>%
  mutate(km300=if_else(Area>200 & Area<=300,1,0)) %>%
  mutate(km500=if_else(Area>300 & Area<=500,1,0)) %>%
  mutate(km1000=if_else(Area>500 & Area<=1000,1,0)) %>%
  mutate(km2500=if_else(Area>1000,1,0)) %>%
  gather(bin, count, 5:15) %>%
  group_by(ID, Name) %>% mutate(total=sum(count)) %>%
  group_by(ID, Name, bin) %>% mutate(freq=sum(count)/total) %>%
  group_by(ID, Name, bin) %>% summarise(freq=mean(freq)) %>%
  mutate(bin=replace(bin, bin=="km1", 2)) %>%
  mutate(bin=replace(bin, bin=="km5", 5)) %>%
  mutate(bin=replace(bin, bin=="km10", 10)) %>%
  mutate(bin=replace(bin, bin=="km20", 20)) %>%
  mutate(bin=replace(bin, bin=="km50", 50)) %>%
  mutate(bin=replace(bin, bin=="km100", 100)) %>%
  mutate(bin=replace(bin, bin=="km200", 200)) %>%
  mutate(bin=replace(bin, bin=="km300", 300)) %>%
  mutate(bin=replace(bin, bin=="km500", 500)) %>%
  mutate(bin=replace(bin, bin=="km1000", 1000)) %>%
  mutate(bin=replace(bin, bin=="km2500", 2500)) %>% arrange(ID, bin) 
eco_dist$bin = as.numeric(eco_dist$bin)
eco_dist = eco_dist %>% arrange(Name, bin)

ggplot(eco_dist, aes(x=factor(bin), y=freq)) +
  geom_bar(stat="identity") +
  facet_wrap(~Name) +
  theme_bw(8) +
  labs(x=expression(Maximum~area~km^2), y="Frequency")

sheetData = datasheet(myProject, name = "STSim_TransitionSizeDistribution", scenario = "Transition Size Distribution", optional = T, empty = F)

fire_size_df = data.frame(Timestep=2018,
                          StratumID=eco_dist$Name,
                          TransitionGroupID="FIRE",
                          MaximumArea=eco_dist$bin,
                          RelativeAmount=eco_dist$freq)

write_csv(fire_size_df, "R Inputs/Data/calfire/fire_size_by_ecoregion.csv")



# Calculate relative fire probability for each LULC class-----------------------------------

calfire = st_read("R Inputs/Data/calfire/ca_fire_2002-2017.shp")
calfire = st_transform(calfire, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs")

# Read in ecoregion raster
ecoreg = raster("R Inputs/Data/initial-conditions/IC_Ecoregions_1km.tif")

# Read in State Class raster
vegmap = raster("R Inputs/Data/initial-conditions/IC_StateClass_1km.tif")
veg_forest = reclassify(vegmap, c(-Inf,5,NA, 5,6,1, 6,Inf,NA))
veg_grass = reclassify(vegmap, c(-Inf,6,NA, 6,7,1, 7,Inf,NA))
veg_shrub = reclassify(vegmap, c(-Inf,9,NA, 9,10,1, 10,Inf,NA))
plot(veg_forest)

# Create zonal stats for each state class type
forest_by_eco = data.frame(zonal(veg_forest, ecoreg, fun=sum)) %>% rename("ID"="zone", "ForestArea"="value")
grass_by_eco = data.frame(zonal(veg_grass, ecoreg, fun=sum)) %>% rename("ID"="zone", "GrassArea"="value")
shrub_by_eco = data.frame(zonal(veg_shrub, ecoreg, fun=sum)) %>% rename("ID"="zone", "ShrubArea"="value")

vegClass_by_eco = forest_by_eco %>% left_join(grass_by_eco, by="ID") %>% left_join(shrub_by_eco, by="ID")

# Create an empty raster
r = raster(as(calfire, "Spatial"), ncols=730, nrows=1233)
rr = fasterize(as(calfire, "Spatial"), r, getCover = TRUE, progress = "text")
r3 = projectRaster(rr, ecoreg)
r3 = mask(r3, ecoreg)
firemap = reclassify(r3, c(-Inf,0,NA, 0,Inf,1))
plot(firemap)

vegfire = mask(vegmap, firemap)
forest_fire = reclassify(vegfire, c(-Inf,5,NA, 5,6,1, 6,Inf,NA))
grass_fire = reclassify(vegfire, c(-Inf,6,NA, 6,7,1, 7,Inf,NA))
shrub_fire = reclassify(vegfire, c(-Inf,9,NA, 9,10,1, 10,Inf,NA))
plot(shrub_fire)

# Create zonal stats for each state class type for fire areas
forest_fire_by_eco = data.frame(zonal(forest_fire, ecoreg, fun=sum)) %>% rename("ID"="zone", "ForestFire"="value")
grass_fire_by_eco = data.frame(zonal(grass_fire, ecoreg, fun=sum)) %>% rename("ID"="zone", "GrassFire"="value")
shrub_fire_by_eco = data.frame(zonal(shrub_fire, ecoreg, fun=sum)) %>% rename("ID"="zone", "ShrubFire"="value")

veg_fire_by_eco = forest_by_eco %>% left_join(grass_by_eco, by="ID") %>% left_join(shrub_by_eco, by="ID") %>%
  left_join(forest_fire_by_eco, by="ID") %>% left_join(grass_fire_by_eco, by="ID") %>% left_join(shrub_fire_by_eco, by="ID")

veg_fire_by_eco = veg_fire_by_eco %>% mutate(ForestProb=(ForestFire/ForestArea)/13, GrassProb=(GrassFire/GrassArea)/13, ShrubProb=(ShrubFire/ShrubArea)/13) %>%
  mutate(ForestRelProb=ForestProb/(ForestProb+GrassProb+ShrubProb)) %>%
  mutate(GrassRelProb=GrassProb/(ForestProb+GrassProb+ShrubProb)) %>%
  mutate(ShrubRelProb=ShrubProb/(ForestProb+GrassProb+ShrubProb))

relProb_veg_eco = veg_fire_by_eco %>% select(ID, ForestRelProb, GrassRelProb, ShrubRelProb) %>%
  gather(StateClassID, Amount, 2:4) %>% left_join(econame, by="ID") %>% select(Name, StateClassID, Amount) %>% rename("StratumID"="Name") %>%
  mutate(StateClassID=replace(StateClassID, StateClassID=="ForestRelProb", "Forest:All")) %>%
  mutate(StateClassID=replace(StateClassID, StateClassID=="GrassRelProb", "Grassland:All")) %>%
  mutate(StateClassID=replace(StateClassID, StateClassID=="ShrubRelProb", "Shrubland:All")) %>%
  mutate(TransitionGroupID="Fire", Timestep=2017)

write_csv(relProb_veg_eco, "R Inputs/Data/calfire/relative_proportions_state_class.csv")






