library(raster)
library(rgdal)
library(sf)
library(tidyverse)
library(rsyncrosim)


gcm="MIROC5"
rcp="rcp85"

# List the raster files and subset for the years 2018-2100
list = list.files(paste("R Inputs/Data/westerling/",gcm,".",rcp,"/data/",sep=""), ".tif")
r = stack(paste("R Inputs/Data/westerling/",gcm,".",rcp,"/data/",list,sep=""))
r = subset(r,65:147)

# Caluclate the area of each 1/16th degree cell
a = area(r)*100
plot(a$layer)

# Calculate the percentage of each cell burned
r1 = r/a
plot(r1$layer.1)

# Project to albers projection and convert NA's to zeros; then mask to ecoregion extent
r2 = projectRaster(r1, ecoreg)
r2[is.na(r2)] = 0
r2 = mask(r2, ecoreg)
plot(r2$layer.1)

# Convert to integer value
r3 = r2*100
plot(r3$layer.1)

crs(r3) = crs

# Write relative spatial multipliers
writeRaster(r3, paste("R Inputs/Data/westerling/",gcm,".",rcp, "/fire_", gcm, ".", rcp, "_", seq(2018,2100), sep=""), format="GTiff", overwrite=T, bylayer=T, datatype="INT1U")








