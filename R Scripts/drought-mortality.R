
crs = "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs"


gcm="MIROC5"
rcp="rcp85"

list = list.files(paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/orig/", sep=""), ".tif")
r = stack(paste("R Inputs/Spatial Multipliers/Mortality/", gcm, ".", rcp, "/orig/", list, sep=""))
crs(r) = crs

rhigh = subset(r,1:84)
names(rhigh) = seq(2017,2100)

rmed = subset(r,85:168)
names(rmed) = seq(2017,2100)

rlow = subset(r,169:252)
names(rlow) = seq(2017,2100)

writeRaster(rhigh, paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/high/", "droughtHigh", "_", gcm, ".", rcp, "_", seq(2017,2100), sep=""), format="GTiff", bylayer=T, overwrite=T, datatype="INT1U")
writeRaster(rmed, paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/med/", "droughtMed", "_", gcm, ".", rcp, "_", seq(2017,2100), sep=""), format="GTiff", bylayer=T, overwrite=T, datatype="INT1U")
writeRaster(rlow, paste("R Inputs/Data/drought/spatial-multipliers/", gcm, ".", rcp, "/low/", "droughtLow", "_", gcm, ".", rcp, "_", seq(2017,2100), sep=""), format="GTiff", bylayer=T, overwrite=T, datatype="INT1U")




names(rhigh)
