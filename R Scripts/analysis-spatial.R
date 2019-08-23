library(raster)
library(rasterVis)

##### Urbanization #####
r = stack("ccf_v5_export/atp/scn115.tgap_Urbanization.ts2011.tif",
          "ccf_v5_export/atp/scn115.tgap_Urbanization.ts2021.tif",
          "ccf_v5_export/atp/scn115.tgap_Urbanization.ts2031.tif",
          "ccf_v5_export/atp/scn115.tgap_Urbanization.ts2041.tif",
          "ccf_v5_export/atp/scn115.tgap_Urbanization.ts2051.tif")
r1 = mean(r)*50
levelplot(r1)
writeRaster(r1, "ccf_v5_export/output/prob_urbanization.tif", format="GTiff", overwrite=T)

##### Intensification Open to Low #####
r = stack("ccf_v5_export/atp/scn115.tgap_Intensification_ Open to Low [Type].ts2011.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Open to Low [Type].ts2021.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Open to Low [Type].ts2031.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Open to Low [Type].ts2041.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Open to Low [Type].ts2051.tif")
r2 = mean(r)*50
levelplot(r2)
writeRaster(r2, "ccf_v5_export/output/prob_intensification_open_low.tif", format="GTiff", overwrite=T)

##### Intensification Open to Medium #####
r = stack("ccf_v5_export/atp/scn115.tgap_Intensification_ Open to Medium [Type].ts2011.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Open to Medium [Type].ts2021.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Open to Medium [Type].ts2031.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Open to Medium [Type].ts2041.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Open to Medium [Type].ts2051.tif")
r3 = mean(r)*50
levelplot(r3)
writeRaster(r3, "ccf_v5_export/output/prob_intensification_open_medium.tif", format="GTiff", overwrite=T)

##### Intensification Open to High #####
r = stack("ccf_v5_export/atp/scn115.tgap_Intensification_ Open to High [Type].ts2011.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Open to High [Type].ts2021.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Open to High [Type].ts2031.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Open to High [Type].ts2041.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Open to High [Type].ts2051.tif")
r4 = mean(r)*50
levelplot(r4)
writeRaster(r4, "ccf_v5_export/output/prob_intensification_open_high.tif", format="GTiff", overwrite=T)

##### Intensification Low to Medium #####
r = stack("ccf_v5_export/atp/scn115.tgap_Intensification_ Low to Medium [Type].ts2011.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Low to Medium [Type].ts2021.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Low to Medium [Type].ts2031.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Low to Medium [Type].ts2041.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Low to Medium [Type].ts2051.tif")
r5 = mean(r)*50
levelplot(r5)
writeRaster(r5, "ccf_v5_export/output/prob_intensification_low_medium.tif", format="GTiff", overwrite=T)

##### Intensification Low to High #####
r = stack("ccf_v5_export/atp/scn115.tgap_Intensification_ Low to High [Type].ts2011.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Low to High [Type].ts2021.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Low to High [Type].ts2031.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Low to High [Type].ts2041.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Low to High [Type].ts2051.tif")
r6 = mean(r)*50
levelplot(r6)
writeRaster(r6, "ccf_v5_export/output/prob_intensification_low_high.tif", format="GTiff", overwrite=T)

##### Intensification Medium to High #####
r = stack("ccf_v5_export/atp/scn115.tgap_Intensification_ Medium to High [Type].ts2011.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Medium to High [Type].ts2021.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Medium to High [Type].ts2031.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Medium to High [Type].ts2041.tif",
          "ccf_v5_export/atp/scn115.tgap_Intensification_ Medium to High [Type].ts2051.tif")
r7 = mean(r)*50
levelplot(r7)
writeRaster(r7, "ccf_v5_export/output/prob_intensification_medium_high.tif", format="GTiff", overwrite=T)



r8 = stack(r2,r3,r4,r5,r6,r7)
r8[r8==0] = NA
names(r8) = c("open_to_low", "open_to_medium", "open_to_high", "low_to_medium", "low_to_high", "medium_to_high")

r9 = which.max(r8)
plot(r9)
writeRaster(r9, "ccf_v5_export/output/prob_intensification_max.tif", format="GTiff", overwrite=T)









r8 = max(r8)
plot(r8)


