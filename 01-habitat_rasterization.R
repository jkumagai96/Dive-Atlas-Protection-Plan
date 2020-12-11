# Joy Kumagai (joy.kumagai@senckenberg.de ; jkumagai@ucsd.edu.com)
# Date: Dec 10th 2020
# Purpose of Script: Rasterize habitats and MPAs
# Dive Atlas Protection Plan 


##### Load Packages #####
library(tidyverse)
library(raster)
library(sf)
library(tools)
library(fasterize)

##### Load Data #####
mexico <- read_sf("Data/eez_land/Mexico.shp")
shapefiles <- list.files("Data/habitats/", pattern = "\\.shp$")
mpas <- list.files("Data/mpas/", pattern = "\\.shp$")


eckert <- "+proj=eck4 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m no_defs"
mexico <- st_transform(mexico, crs = eckert)
r <- raster(mexico, res = 1000) # raster is square 
mexico_r <- fasterize(mexico, r) # raster is in the shape of Mexico 

##### Rasterize Habitats #####
for (i in 1:length(shapefiles)) {
  path <- paste0("Data/habitats/", shapefiles[i])
  habitat_poly <- read_sf(path)
  
  # Project Data 
  crs(habitat_poly)
  
  #@ Chosen projection: World Eckert Iv (equal area)
  habitat_poly <- st_transform(habitat_poly, crs = eckert)
  
  # Rastierze
  habitat_poly$constant <- 1 
  
  if (unique(st_geometry_type(habitat_poly)) == "MULTIPOINT") {
    habitat_poly <- st_cast(habitat_poly, "POINT")
    print("Converting Multipoints to points")
    print("Attempting to convert to raster")
    habitatR <- rasterize(habitat_poly, r, progress = "text", field = "constant")
  } else if (unique(st_geometry_type(habitat_poly)) == "POINT"){
    print("Attempting to convert to raster")
    habitatR <- rasterize(habitat_poly, r, progress = "text", field = "constant")
  } else {
    print("Attempting to convert to raster")
    habitatR <- fasterize(habitat_poly, r, field = "constant") 
  }
  
  # Trim raster to just Mexico and it's EEZ
  habitatR <- habitatR*mexico_r
  
  # Export each file 
  exportpath <- paste0("Data/habitats/", file_path_sans_ext(shapefiles[i]), ".tif")
  writeRaster(habitatR, exportpath, overwrite = TRUE)
  print(paste0("Habitat Raster has been written to ", exportpath))
}


##### Rasterize MPAs #####
for (i in 1:length(mpas)) {
  path <- paste0("Data/mpas/", mpas[i])
  mpas_poly <- read_sf(path)

  #@ Chosen projection: World Eckert Iv (equal area)
  mpas_poly <- st_transform(mpas_poly, crs = eckert)
  
  # Rastierze
  mpas_poly$constant <- 1 
  mpasR <- fasterize(mpas_poly, r, field = "constant") 
  
  # Export each file 
  exportpath <- paste0("Data/mpas/", file_path_sans_ext(mpas[i]), ".tif")
  writeRaster(mpasR, exportpath, overwrite = TRUE)
  print(paste0("Raster has been written to ", exportpath))
}
