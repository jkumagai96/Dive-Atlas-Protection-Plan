# Joy Kumagai (joy.kumagai@senckenberg.de ; jkumagai@ucsd.edu.com)
# Date: Dec 10th 2020
# Purpose of Script: Extract counts of habitats per mpa
# Dive Atlas Protection Plan 

#### Load Packages ####
library(tidyverse)
library(raster)
library(stringr)

#### Load Data ####
mpas_files <- list.files("data/mpas/", pattern = "*.tif$") #list files (in this case raster TIFFs)
habitat_files <- list.files("data/habitats/", pattern = "*.tif$") #list files (in this case raster TIFFs)

# Set up table to be filled in 
data <- data.frame(matrix(ncol = length(mpas_files) + 1, nrow = length(habitat_files)))
colnames(data) <- c("habitat", str_sub(mpas_files, end = -5))
data$habitat <- str_sub(habitat_files, end = -5)

# Go through each pair of habitat and mpas and calculate percentage protected based off of pixel counts 
for (i in 1:length(habitat_files)) {
  r1 <- raster(paste0("data/habitats/", habitat_files[i]))
  for (ii in 1:length(mpas_files)) {
    r2 <- raster(paste0("data/mpas/", mpas_files[ii]))
    r3 <- r1*r2 # intersection of habitat and mpa layer 
    
    r1_count <- cellStats(r1, 'sum') # calculates pixel counts for habitat layer
    r3_count <- cellStats(r3, 'sum') # calculates pixesl counts for habitats within mpas 
    
    percent_protected <- (r3_count/r1_count)*100
    data[i, ii+1] <- percent_protected # enters values into data frame
  }
}

#### Export ####
write.csv(data, "data/results/protection_table.csv", row.names = F)