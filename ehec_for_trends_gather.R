# Chirag 
# get data ready for demographic analysis
# gather acs files in a directory
# 7/30/23
library(tidyverse)
library(tidycensus)

read_directory <- function(directory) {
  acs_files <- list.files(directory)
  acs_table <- map(acs_files, ~read_rds(file=file.path(directory,.))) %>% bind_rows() # sf file
  acs_table
}

## get counties
directory <- './out/2020_county/'
acs_by_county <- read_directory(directory)

directory <- './out/2020/'
acs_by_tract <- read_directory(directory)

## merge in places
#places_by_tract <- read_csv("./PLACES__Local_Data_for_Better_Health__Census_Tract_Data_2022_release.csv.zip")
places_by_tract <- read_csv("./PLACES__Census_Tract_Data__GIS_Friendly_Format___2023_release.csv")
#p_wide <- places_by_tract %>% select(LocationName, MeasureId, Data_Value) %>% pivot_wider(names_from=MeasureId, values_from = Data_Value) # make in wide format, disease prevalence in each column
acs_places_by_tract <- acs_by_tract %>% left_join(places_by_tract, by=c("GEOID"="TractFIPS"))

places_by_county <- read_csv("./PLACES__County_Data__GIS_Friendly_Format___2023_release.csv")
# https://data.cdc.gov/500-Cities-Places/PLACES-County-Data-GIS-Friendly-Format-2023-releas/i46a-9kgh
acs_places_by_county <- acs_by_county |> left_join(places_by_county, by=c("GEOID"="CountyFIPS"))

save(acs_places_by_county, acs_places_by_tract, file = "./out/ehe_trends_acs_places.Rdata")
saveRDS(acs_by_tract, file="./out/ehe_acs_tract.rds") 
saveRDS(acs_by_county, file = "./out/ehe_acs_counties.rds")
