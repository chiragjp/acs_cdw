## create acs table for family van project (Summer 2023)
## chirag patel
## see also 1_how_to.Rmd
directory <- './out/'
acs_files <- list.files(directory, pattern = ".rds")
acs_table <- map(acs_files, ~read_rds(file=file.path(directory,.))) %>% bind_rows() # sf file

#acs_table %>% select(starts_with("d")) %>% head()
to_out <- acs_table %>% select(c("GEOID", "NAME", "population_size", "d_median_income", "d_below_poverty_line_percentage", "d_no_health_insurance_percentage",
                       "d_white_percentage",
                       "d_black_percentage",
                       "d_asian_percentage",
                       "d_hawaii_pi_percentage",
                       "d_other_race_percentage",
                       "d_two_more_race_percentage",
                       "geometry"))

saveRDS(to_out, "./out/family_van_acs.rds")