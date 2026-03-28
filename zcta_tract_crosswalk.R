## Chirag J Patel / Claude
## 03/27/26
## Download and prepare ZCTA-to-Census Tract crosswalk
## Uses Census Bureau 2020 relationship files with population/area overlap weights

library(tidyverse)

## --- 2020 ZCTA-to-Tract relationship file from Census Bureau ---
## Documentation: https://www.census.gov/geographies/reference-files/time-series/geo/relationship-files.2020.html
crosswalk_url_2020 <- "https://www2.census.gov/geo/docs/maps-data/data/rel2020/zcta520-tract20/tab20_zcta520_tract20_natl.txt"
crosswalk_file <- "zcta_tract_crosswalk_2020.csv"

if (!file.exists(crosswalk_file)) {
  cat("Downloading 2020 ZCTA-to-Tract crosswalk from Census Bureau...\n")
  raw <- read_delim(crosswalk_url_2020, delim = "|", show_col_types = FALSE)

  ## Key columns:
  ## GEOID_ZCTA5_20  - 5-digit ZCTA code
  ## GEOID_TRACT_20  - 11-digit tract GEOID (state+county+tract)
  ## AREALAND_PART   - land area of the overlap region (sq meters)
  ## OVR_POP_2020    - 2020 population in the overlap region (from PL94-171)
  ## OVR_HU_2020     - 2020 housing units in the overlap region

  crosswalk <- raw %>%
    select(
      zcta = GEOID_ZCTA5_20,
      tract_geoid = GEOID_TRACT_20,
      overlap_area_land = AREALAND_PART,
      overlap_pop = OVR_POP_2020,
      overlap_hu = OVR_HU_2020
    ) %>%
    mutate(
      zcta = as.character(zcta),
      tract_geoid = as.character(tract_geoid)
    )

  ## Compute population-based weight: what fraction of each tract's population falls in each ZCTA
  crosswalk <- crosswalk %>%
    group_by(tract_geoid) %>%
    mutate(
      tract_total_pop = sum(overlap_pop, na.rm = TRUE),
      w_tract_to_zcta = if_else(tract_total_pop > 0, overlap_pop / tract_total_pop, 0)
    ) %>%
    ungroup()

  ## Also compute ZCTA-side weight: what fraction of each ZCTA's population comes from each tract
  crosswalk <- crosswalk %>%
    group_by(zcta) %>%
    mutate(
      zcta_total_pop = sum(overlap_pop, na.rm = TRUE),
      w_zcta_from_tract = if_else(zcta_total_pop > 0, overlap_pop / zcta_total_pop, 0)
    ) %>%
    ungroup()

  write_csv(crosswalk, crosswalk_file)
  cat(sprintf("Crosswalk saved: %s (%d rows, %d unique ZCTAs, %d unique tracts)\n",
              crosswalk_file, nrow(crosswalk),
              n_distinct(crosswalk$zcta), n_distinct(crosswalk$tract_geoid)))
} else {
  cat(sprintf("Crosswalk already exists: %s\n", crosswalk_file))
  crosswalk <- read_csv(crosswalk_file, show_col_types = FALSE)
}

cat(sprintf("Summary: %d ZCTA-tract pairs, %d ZCTAs, %d tracts\n",
            nrow(crosswalk), n_distinct(crosswalk$zcta), n_distinct(crosswalk$tract_geoid)))
