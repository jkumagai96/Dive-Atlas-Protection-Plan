
library(tidyverse)
library(sf)
library(raster)
library(rasterVis) 
library(RColorBrewer)
library(rgdal)

p <- read_sf("Data_Original/seagrasses/01_Data/WCMC_013_014_SeagrassesPy_v6.shp")

eez <- read_sf("Data_original/eez/eez_Mexico.shp")
#eez2 <- readOGR("Data_original/eez/eez_Mexico.shp")

head(eez)

head(p)


## Cropping for Mexico 

seagr_mex <- st_crop(p, st_bbox(eez))


## Rasterization 

# Create empty raster
r <- raster(as(seagr_mex, "Spatial"), res = 0.1)

# Create rasterization
rr <- rasterize(as(seagr_mex, "Spatial"), r, getCover = TRUE, progress = "text")

cols <- colorRampPalette(brewer.pal(9,"YlGn"))

rr[rr==0] <- NA

levelplot(rr, col.regions=cols)


