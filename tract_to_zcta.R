## Chirag J Patel / Claude
## 03/27/26
## Aggregate tract-level ACS CDW data to ZCTA (ZIP code) level
## Uses population-weighted averages for percentages, population-weighted sums for counts

library(tidyverse)
library(getopt)

spec <- matrix(c(
  'input',  'i', 1, "character",  # input RDS (tract-level, e.g., out/ehe_acs_tract.rds)
  'output', 'o', 1, "character",  # output RDS (zcta-level)
  'crosswalk', 'c', 2, "character"  # crosswalk CSV (default: zcta_tract_crosswalk_2020.csv)
), byrow = TRUE, ncol = 4)
opt <- getopt(spec)

## Defaults
input_file   <- opt$input   %||% "out/ehe_acs_tract.rds"
output_file  <- opt$output  %||% "out/ehe_acs_zcta.rds"
cw_file      <- opt$crosswalk %||% "zcta_tract_crosswalk_2020.csv"

cat(sprintf("Input:     %s\nOutput:    %s\nCrosswalk: %s\n", input_file, output_file, cw_file))

## --- Load crosswalk ---
if (!file.exists(cw_file)) {
  cat("Crosswalk not found. Run zcta_tract_crosswalk.R first.\n")
  source("zcta_tract_crosswalk.R")
}
crosswalk <- read_csv(cw_file, show_col_types = FALSE)

## --- Load tract-level data ---
tracts <- read_rds(input_file)
cat(sprintf("Loaded %d tracts\n", nrow(tracts)))

## Drop geometry if present (sf objects can't be aggregated this way)
if ("sf" %in% class(tracts)) {
  tracts <- tracts %>% sf::st_drop_geometry()
}

## --- Identify derived columns (d_*) and classify as percentage vs count ---
d_cols <- names(tracts)[grepl("^d_", names(tracts))]
pct_cols <- d_cols[grepl("percent", d_cols)]        # population-weighted average
count_cols <- setdiff(d_cols, pct_cols)              # population-weighted sum (or direct value)

## Also carry forward population and key identifiers
## median columns should be averaged, not summed
median_cols <- d_cols[grepl("median", d_cols)]
count_cols <- setdiff(count_cols, median_cols)
pct_cols <- c(pct_cols, median_cols)  # treat medians like percentages (weighted average)

cat(sprintf("Derived columns: %d percentage/median (weighted avg), %d count (weighted sum)\n",
            length(pct_cols), length(count_cols)))

## --- Join tracts to crosswalk ---
## w_zcta_from_tract: fraction of ZCTA population that comes from this tract
## This is the right weight for aggregating tract values UP to ZCTA level
tract_zcta <- tracts %>%
  inner_join(crosswalk %>% select(zcta, tract_geoid, w_zcta_from_tract, overlap_pop),
             by = c("GEOID" = "tract_geoid"))

cat(sprintf("Matched %d tract-ZCTA pairs (from %d tracts)\n",
            nrow(tract_zcta), n_distinct(tract_zcta$GEOID)))

## --- Aggregate to ZCTA level ---
## For percentages/medians: population-weighted average
## For counts: scale by overlap fraction and sum

## Weighted average helper: handles NAs in values (but not in weights)
weighted_mean_na <- function(x, w) {
  valid <- !is.na(x) & !is.na(w)
  if (sum(valid) == 0) return(NA_real_)
  sum(x[valid] * w[valid]) / sum(w[valid])
}

## Build aggregation expressions
agg_exprs <- list()

## Population: sum of overlap populations
agg_exprs[["population_size"]] <- expr(sum(overlap_pop, na.rm = TRUE))

## Percentage/median columns: weighted average
for (col in pct_cols) {
  agg_exprs[[col]] <- expr(weighted_mean_na(!!sym(col), w_zcta_from_tract))
}

## Count columns: weighted sum (each tract's count * fraction belonging to this ZCTA)
for (col in count_cols) {
  agg_exprs[[col]] <- expr(sum(!!sym(col) * w_zcta_from_tract, na.rm = TRUE))
}

zcta_data <- tract_zcta %>%
  group_by(zcta) %>%
  summarise(!!!agg_exprs, .groups = "drop")

cat(sprintf("Aggregated to %d ZCTAs\n", nrow(zcta_data)))

## --- Save ---
write_rds(zcta_data, output_file)
cat(sprintf("Saved: %s\n", output_file))

## Quick summary
cat("\n--- ZCTA-level summary ---\n")
cat(sprintf("ZCTAs: %d\n", nrow(zcta_data)))
cat(sprintf("Total population covered: %s\n", format(sum(zcta_data$population_size, na.rm = TRUE), big.mark = ",")))
cat(sprintf("Columns: %d\n", ncol(zcta_data)))
