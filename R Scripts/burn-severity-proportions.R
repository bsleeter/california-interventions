library(tidyverse)
library(raster)


mask = raster("R Inputs/Data/initial-conditions/IC_Ecoregions_1km.tif")
rPrimaryStratum = mask
plot(mask)

r = raster("M:/GIS-Raster/MTBS/mtbs_conus_dt_2014/mtbs_conus_dt_2014_20150401.img")
rp = projectRaster(r, mask, method="ngb")
rm = mask(rp, mask)
writeRaster(rm, "R Inputs/Data/mtbs/mtbs_2014.tif", overwrite=T, format="GTiff")

r = raster("M:/GIS-Raster/MTBS/mtbs_conus_dt_2013/mtbs_conus_dt_2013_20150401.img")
rp = projectRaster(r, mask, method="ngb")
rm = mask(rp, mask)
writeRaster(rm, "R Inputs/Data/mtbs/mtbs_2013.tif", overwrite=T, format="GTiff")

r = raster("M:/GIS-Raster/MTBS/mtbs_conus_dt_2012/mtbs_conus_dt_2012_20141001.img")
rp = projectRaster(r, mask, method="ngb")
rm = mask(rp, mask)
writeRaster(rm, "R Inputs/Data/mtbs/mtbs_2012.tif", overwrite=T, format="GTiff")

r = raster("M:/GIS-Raster/MTBS/mtbs_conus_dt_2011/mtbs_conus_dt_2011_20141001.img")
rp = projectRaster(r, mask, method="ngb")
rm = mask(rp, mask)
writeRaster(rm, "R Inputs/Data/mtbs/mtbs_2011.tif", overwrite=T, format="GTiff")

r = raster("M:/GIS-Raster/MTBS/mtbs_conus_dt_2010/mtbs_conus_dt_2010_20141001.img")
rp = projectRaster(r, mask, method="ngb")
rm = mask(rp, mask)
writeRaster(rm, "R Inputs/Data/mtbs/mtbs_2010.tif", overwrite=T, format="GTiff")

r = raster("M:/GIS-Raster/MTBS/mtbs_conus_dt_2009/mtbs_conus_dt_2009_20141001.img")
rp = projectRaster(r, mask, method="ngb")
rm = mask(rp, mask)
writeRaster(rm, "R Inputs/Data/mtbs/mtbs_2009.tif", overwrite=T, format="GTiff")

r = raster("M:/GIS-Raster/MTBS/mtbs_conus_dt_2008/mtbs_conus_dt_2008_20141001.img")
rp = projectRaster(r, mask, method="ngb")
rm = mask(rp, mask)
writeRaster(rm, "R Inputs/Data/mtbs/mtbs_2008.tif", overwrite=T, format="GTiff")

r = raster("M:/GIS-Raster/MTBS/mtbs_conus_dt_2007/mtbs_conus_dt_2007_20141001.img")
rp = projectRaster(r, mask, method="ngb")
rm = mask(rp, mask)
writeRaster(rm, "R Inputs/Data/mtbs/mtbs_2007.tif", overwrite=T, format="GTiff")

r = raster("M:/GIS-Raster/MTBS/mtbs_conus_dt_2006/mtbs_conus_dt_2006_20141001.img")
rp = projectRaster(r, mask, method="ngb")
rm = mask(rp, mask)
writeRaster(rm, "R Inputs/Data/mtbs/mtbs_2006.tif", overwrite=T, format="GTiff")

r = raster("M:/GIS-Raster/MTBS/mtbs_conus_dt_2005/mtbs_conus_dt_2005_20141001.img")
rp = projectRaster(r, mask, method="ngb")
rm = mask(rp, mask)
writeRaster(rm, "R Inputs/Data/mtbs/mtbs_2005.tif", overwrite=T, format="GTiff")

r = raster("M:/GIS-Raster/MTBS/mtbs_conus_dt_2004/mtbs_conus_dt_2004_20141001.img")
rp = projectRaster(r, mask, method="ngb")
rm = mask(rp, mask)
writeRaster(rm, "R Inputs/Data/mtbs/mtbs_2004.tif", overwrite=T, format="GTiff")

r = raster("M:/GIS-Raster/MTBS/mtbs_conus_dt_2003/mtbs_conus_dt_2003_20141001.img")
rp = projectRaster(r, mask, method="ngb")
rm = mask(rp, mask)
writeRaster(rm, "R Inputs/Data/mtbs/mtbs_2003.tif", overwrite=T, format="GTiff")

r = raster("M:/GIS-Raster/MTBS/mtbs_conus_dt_2002/mtbs_conus_dt_2002_20141001.img")
rp = projectRaster(r, mask, method="ngb")
rm = mask(rp, mask)
writeRaster(rm, "R Inputs/Data/mtbs/mtbs_2002.tif", overwrite=T, format="GTiff")

r = raster("M:/GIS-Raster/MTBS/mtbs_conus_dt_2001/mtbs_conus_dt_2001_20141001.img")
rp = projectRaster(r, mask, method="ngb")
rm = mask(rp, mask)
writeRaster(rm, "R Inputs/Data/mtbs/mtbs_2001.tif", overwrite=T, format="GTiff")


list = list.files(path="R Inputs/Data/mtbs", pattern="*.tif")

mtbs_stack = stack(paste("R Inputs/Data/mtbs/",list, sep=""))
mtbs_stack_low = reclassify(mtbs_stack, c(-Inf,1,0, 2,2,1, 3,Inf,0))
mtbs_stack_med = reclassify(mtbs_stack, c(-Inf,2,0, 3,3,1, 4,Inf,0))
mtbs_stack_high = reclassify(mtbs_stack, c(-Inf,3,0, 4,4,1, 5,Inf,0))

mtbs_low_zonal = data.frame(zonal(mtbs_stack_low, rPrimaryStratum, fun=sum)) %>% gather(year, area, 2:15) %>% mutate(severity="low")
mtbs_med_zonal = data.frame(zonal(mtbs_stack_med, rPrimaryStratum, fun=sum)) %>% gather(year, area, 2:15) %>% mutate(severity="medium")
mtbs_high_zonal = data.frame(zonal(mtbs_stack_high, rPrimaryStratum, fun=sum))%>% gather(year, area, 2:15) %>% mutate(severity="high")

mtbs_zonal = bind_rows(mtbs_low_zonal, mtbs_med_zonal, mtbs_high_zonal) %>% as.tibble() %>% 
  mutate(year=replace(year, year=="layer.1", 2001)) %>%
  mutate(year=replace(year, year=="layer.2", 2002)) %>%
  mutate(year=replace(year, year=="layer.3", 2003)) %>%
  mutate(year=replace(year, year=="layer.4", 2004)) %>%
  mutate(year=replace(year, year=="layer.5", 2005)) %>%
  mutate(year=replace(year, year=="layer.6", 2006)) %>%
  mutate(year=replace(year, year=="layer.7", 2007)) %>%
  mutate(year=replace(year, year=="layer.8", 2008)) %>%
  mutate(year=replace(year, year=="layer.9", 2009)) %>%
  mutate(year=replace(year, year=="layer.10", 2010)) %>%
  mutate(year=replace(year, year=="layer.11", 2011)) %>%
  mutate(year=replace(year, year=="layer.12", 2012)) %>%
  mutate(year=replace(year, year=="layer.13", 2013)) %>%
  mutate(year=replace(year, year=="layer.14", 2014))
mtbs_zonal$zone = as.numeric(mtbs_zonal$zone)
mtbs_zonal$year = as.factor(mtbs_zonal$year)
mtbs_zonal$severity = as.factor(mtbs_zonal$severity)
str(mtbs_zonal)



econame = datasheet(myProject, "STSim_Stratum", empty = F, optional = T)

mtbs_zonal_eco_mean = mtbs_zonal %>% group_by(zone, severity) %>% summarise(area=mean(area)) %>% spread(severity, area) %>% 
  mutate(pctH=high/(high+medium+low), pctM=medium/(high+medium+low), pctL=low/(high+medium+low)) %>% dplyr::select(-high, -medium, -low) %>% 
  rename("Fire: High Severity [Type]"="pctH", "Fire: Medium Severity [Type]"="pctM", "Fire: Low Severity [Type]"="pctL") %>%
  gather(severity, percent, 2:4) %>% mutate_if(is.numeric, round, 3) %>% rename("ID"="zone") %>% left_join(econame, by="ID") %>%
  dplyr::select(ID, Name, severity, percent)



severity_df = data.frame(StratumID=mtbs_zonal_eco_mean$Name,
                         TransitionGroupID=mtbs_zonal_eco_mean$severity,
                         Amount=mtbs_zonal_eco_mean$percent)

write_csv(severity_df, "R Inputs/Data/mtbs/severity_by_ecoregion_2001_2014.csv")




mtbs_zonal_eco_mean$severity = factor(mtbs_zonal_eco_mean$severity, levels=c("Fire: Low Severity [Type]", "Fire: Medium Severity [Type]", "Fire: High Severity [Type]"))

ggplot(mtbs_zonal_eco_mean, aes(x=Name, y=percent, fill=severity)) +
  geom_bar(stat="identity") + 
  geom_text(aes(label=percent), position = position_stack(vjust = 0.5), size=3) +
  theme_bw(8) +
  coord_flip() +
  scale_fill_manual(name="Severity Class", values=c("YellowGreen", "Orange", "DarkRed"), labels=c("low", "medium", "high")) +
  theme(legend.position="bottom",
        legend.key.height = unit(0.7, "line"))











mtbs_zonal_pct = mtbs_zonal %>% spread(severity, area) %>% 
  mutate(total=high+medium+low, high=high/total, medium=medium/total, low=low/total) %>% filter(total>0)  %>% dplyr::select(zone, year, high, medium, low) %>%
  gather(severity, percent, 3:5) 
mtbs_zonal = mtbs_zonal %>% left_join(mtbs_zonal_pct, by=c("zone", "year", "severity")) %>% mutate(percent=replace_na(percent, 0))


ggplot(mtbs_zonal, aes(x=year, y=percent, fill=severity)) + 
  geom_bar(stat="identity") +
  facet_wrap(~zone) +
  coord_flip()




mtbs_zonal_state = mtbs_zonal %>% group_by(year, severity) %>% summarise(area = sum(area))
mtbs_zonal_state_pct = mtbs_zonal_state %>% spread(severity, area) %>% 
  mutate(pctH=high/(high+medium+low), pctM=medium/(high+medium+low), pctL=low/(high+medium+low)) %>% dplyr::select(-high, -medium, -low) %>% rename("high"="pctH", "medium"="pctM", "low"="pctL") %>%
  gather(severity, percent, 2:4)
mtbs_zonal_state = mtbs_zonal_state %>% left_join(mtbs_zonal_state_pct)
mtbs_zonal_state$year = as.numeric(as.character(mtbs_zonal_state$year))

ggplot(mtbs_zonal_state, aes(x=year, y=percent, fill=severity)) + 
  geom_bar(stat="identity")

ggplot(mtbs_zonal_state, aes(x=year, y=percent, color=severity)) + 
  geom_point() +
  geom_line() +
  geom_smooth(method="lm")






start = Sys.time()
plot(rm)
end = Sys.time()
time = end-start
time