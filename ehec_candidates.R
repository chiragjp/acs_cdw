## Chirag J Patel
## 11/30/22


## CDW ACS - downloads candidate data for the CDW (by state, year of ACS5 data)
## candidates chosen based on the sociodeprivation index (see Lakhani NG 2019) 

library(tidyverse)
library(tidycensus)
library(getopt)
source("api_key.R") # not committed

data(fips_codes)
TEST <- F
spec = matrix(c(
  'state', 's', 1, "character",
  'year'  , 'y', 1, "integer", 
  'geotype', 'g', 1, 'character'
), byrow=TRUE, ncol=4)
opt = getopt(spec)

state <- "CA";year <- 2020; geotype <- "tract"
if(!TEST) {
  state <- opt$state
  year <- opt$year
  geotype <- opt$geotype
}



directoryout <- 'out' # can also be a param
fileoutname <- sprintf('%s_%i_%s_acs5.rds', state, year, geotype)
pathout <- file.path(directoryout, fileoutname)

## get the table with the variables and the table names
variables <- load_variables(
  year=year,
  dataset = c("acs5"),
  cache = FALSE
) 
variables <- variables %>% mutate(tablename=sapply(strsplit(variables$name, "\\_"), function(arr) {arr[[1]]}))

## get population data 
get_acs_table_tracts_for_state_with_geom <- function(state, table_name, year, geometry=TRUE) {
  tab <- get_acs(geotype, year=year, key=api_key, state = state, table = table_name, geometry = geometry) ## gets all the variables for a state and census tract
  ## merge in the variable name
  tab %>% left_join(variables  %>% select(name, label, concept), by=c("variable"="name"))
}

acs_pivot_wider <- function(d) {
  d %>% select(-c(label, concept)) %>% pivot_wider(names_from = variable, values_from = c(estimate, moe))
}

cat(sprintf("ACS5;state:%s;year:%i\n", state, year ))

population <- get_acs_table_tracts_for_state_with_geom(state, "B01003", year=year) ## with geometry
big_table <- population %>% select(-variable) %>% rename(population_size=estimate, population_size_moe=moe)

## 1. Unemployment - Percentage of persons aged 16 years or older in the labor force who  are unemployed (and actively seeking work) (B23025) 
#processed_variables <- tibble()
un <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B23025", year=year, geometry = FALSE) %>% acs_pivot_wider()
un <- un %>% mutate(d_unemployed_percentage=(estimate_B23025_005/estimate_B23025_001))
big_table <- big_table %>% left_join(un %>% select(-NAME), by="GEOID") 

## 2. Below US poverty line - Percentage of persons below the federally defined poverty line (B17020)
poverty <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B17020", year=year, geometry = FALSE) %>% acs_pivot_wider()
poverty <- poverty %>% mutate(d_below_poverty_line_percentage=estimate_B17020_002/estimate_B17020_001)
# percent who are older (>60) | under poverty
poverty <- poverty %>% mutate(d_percent_older_under_poverty=(estimate_B17020_007+estimate_B17020_008+estimate_B17020_009)/estimate_B17020_002)
big_table <- big_table %>% left_join(poverty %>% select(-NAME), by="GEOID") 

## 3. Median income - Median household income (B19013)
median_income <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B19013", year=year, geometry = FALSE) %>% acs_pivot_wider()
median_income <- median_income %>% mutate(d_median_income=(estimate_B19013_001))
big_table <- big_table %>% left_join(median_income %>% select(-NAME), by="GEOID")

## 4. Property values - Median value of owner-occupied homes (B25077)
median_value <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B25077", year=year, geometry = FALSE) %>% acs_pivot_wider()
median_value <- median_value %>% mutate(d_income_median_value=(estimate_B25077_001))
big_table <- big_table %>% left_join(median_value %>% select(-NAME), by="GEOID")

## 5. Low education - Percentage of persons aged > 25 years with less than a 12th-grade education (B15001, sex by educational attainment)
## 6. High education - Percentage of persons aged > 25 years with at least 4 years of college   (B15001)
education <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B15001", year=year, geometry = FALSE) %>% acs_pivot_wider()
education <- education %>% mutate(d_total_male_over_age_25 = estimate_B15001_011 + estimate_B15001_019 + estimate_B15001_027 + estimate_B15001_035)
education <- education %>% mutate(d_total_male_over_age_65 = estimate_B15001_035)
education <- education %>% mutate(d_total_female_over_age_25 = estimate_B15001_052 + estimate_B15001_060 + estimate_B15001_068 + estimate_B15001_076)
education <- education %>% mutate(d_total_female_over_age_65 = estimate_B15001_076)

education <- education %>% mutate(d_education_less_hs_male_over_25_percentage = 
                                    (estimate_B15001_012 + estimate_B15001_013 + estimate_B15001_020 + estimate_B15001_021 + estimate_B15001_028 + estimate_B15001_029 +  estimate_B15001_036 + estimate_B15001_037) / d_total_male_over_age_25)
education <- education %>% mutate(d_education_less_hs_female_over_25_percentage = 
                                    (estimate_B15001_053 + estimate_B15001_054 + estimate_B15001_061 + estimate_B15001_062 + estimate_B15001_069 + estimate_B15001_070 + estimate_B15001_077 + estimate_B15001_078) / d_total_female_over_age_25) 
education <- education %>% mutate(d_education_greater_four_year_college_male_over_25_percentage = 
                                    (estimate_B15001_017 + estimate_B15001_018 + estimate_B15001_025 + estimate_B15001_026 + estimate_B15001_033 + estimate_B15001_034 + estimate_B15001_041 + estimate_B15001_042) / d_total_male_over_age_25)
education <- education %>% mutate(d_education_greater_four_year_college_female_over_25_percentage = 
                                    (estimate_B15001_058 + estimate_B15001_059 + estimate_B15001_066 + estimate_B15001_067 + estimate_B15001_074 + estimate_B15001_075 + estimate_B15001_082 + estimate_B15001_083) / d_total_female_over_age_25)

education <- education %>% mutate(d_education_less_hs_over_25_percentage = 
                                    (estimate_B15001_012 + estimate_B15001_013 + estimate_B15001_020 + estimate_B15001_021 + estimate_B15001_028 + estimate_B15001_029 +  estimate_B15001_036 + estimate_B15001_037
                                     +estimate_B15001_053 + estimate_B15001_054 + estimate_B15001_061 + estimate_B15001_062 + estimate_B15001_069 + estimate_B15001_070 + estimate_B15001_077 + estimate_B15001_078) 
                                  / (d_total_male_over_age_25+d_total_female_over_age_25))

education <- education %>% mutate(d_education_greater_four_year_college_over_25_percentage = 
                                    (estimate_B15001_017 + estimate_B15001_018 + estimate_B15001_025 + estimate_B15001_026 + estimate_B15001_033 + estimate_B15001_034 + estimate_B15001_041 + estimate_B15001_042 +
                                       estimate_B15001_058 + estimate_B15001_059 + estimate_B15001_066 + estimate_B15001_067 + estimate_B15001_074 + estimate_B15001_075 + estimate_B15001_082 + estimate_B15001_083)
                                  / (d_total_male_over_age_25+d_total_female_over_age_25))

big_table <- big_table %>% left_join(education %>% select(-NAME), by="GEOID")
## 7. Crowded households - Percentage of households containing one or more person per room (B25014)
crowded <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B25014", year=year, geometry = FALSE) %>% acs_pivot_wider()
crowded <- crowded %>% mutate(d_households_containing_greater_1_per_room = (estimate_B25014_007 + estimate_B25014_013) / estimate_B25014_001)
big_table <- big_table %>% left_join(crowded %>% select(-NAME), by="GEOID")

#8. sex by age B01001
sex_by_age <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B01001", year=year, geometry = FALSE) %>% acs_pivot_wider()
## get percentage of older individuals
sex_by_age <- sex_by_age %>% mutate(d_male_total=estimate_B01001_002, d_female_total=estimate_B01001_026)
sex_by_age <- sex_by_age %>% mutate(d_male_over_65_percent= (estimate_B01001_020+estimate_B01001_021+estimate_B01001_022+estimate_B01001_023 + estimate_B01001_024 + estimate_B01001_025) / d_male_total)
sex_by_age <- sex_by_age %>% mutate(d_male_over_75_percent= (estimate_B01001_023 + estimate_B01001_024 + estimate_B01001_025) / d_male_total)
sex_by_age <- sex_by_age %>% mutate(d_male_over_85_percent= (estimate_B01001_025) / d_male_total)

sex_by_age <- sex_by_age %>% mutate(d_female_over_65_percent= (estimate_B01001_044+estimate_B01001_045+estimate_B01001_046+estimate_B01001_047 + estimate_B01001_048 + estimate_B01001_049) / d_female_total)
sex_by_age <- sex_by_age %>% mutate(d_female_over_75_percent= (estimate_B01001_047 + estimate_B01001_048 + estimate_B01001_049) / d_female_total)
sex_by_age <- sex_by_age %>% mutate(d_female_over_85_percent= (estimate_B01001_049) / d_female_total)
big_table <- big_table %>% left_join(sex_by_age %>% select(-NAME), by="GEOID")

## 9. median age by sex B01002
median_age <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B01002", year=year, geometry = FALSE) %>% acs_pivot_wider()
median_age <- median_age %>% mutate(d_median_age=estimate_B01002_001, d_median_male_age=estimate_B01002_002, d_median_female_age=estimate_B01002_003)
big_table <- big_table %>% left_join(median_age %>% select(-NAME), by="GEOID")  

## 10 Health insurance by employment (B27011)
insurance <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B27011", year=year, geometry = FALSE) %>% acs_pivot_wider()
insurance <- insurance %>% mutate(d_no_health_insurance_percentage= (estimate_B27011_007 + estimate_B27011_012 + estimate_B27011_017) / estimate_B27011_001)
insurance <- insurance %>% mutate(d_public_health_insurance_percentage= (estimate_B27011_006 + estimate_B27011_011 + estimate_B27011_016) / estimate_B27011_001)
insurance <- insurance %>% mutate(d_no_insurance_unemployed_percentage= (estimate_B27011_012) / estimate_B27011_008)
big_table <- big_table %>% left_join(insurance %>% select(-NAME), by="GEOID")

## 11. sex by age by disability B18101
sex_by_age_dis <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B18101", year=year, geometry = FALSE) %>% acs_pivot_wider()
sex_by_age_dis <- sex_by_age_dis %>% mutate(d_disability_male_over65_percentage = (estimate_B18101_016 + estimate_B18101_019)/(estimate_B18101_015 + estimate_B18101_018))
sex_by_age_dis <- sex_by_age_dis %>% mutate(d_disability_female_over65_percentage = (estimate_B18101_035 + estimate_B18101_038)/(estimate_B18101_034 + estimate_B18101_037))
big_table <- big_table %>% left_join(sex_by_age_dis %>% select(-NAME), by="GEOID")

## 12. Sex by age by hearing difficulty (B18102)
sex_by_age_hearing <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B18102", year=year, geometry = FALSE) %>% acs_pivot_wider()
sex_by_age_hearing <- sex_by_age_hearing %>% mutate(d_hearing_male_over65_percentage = (estimate_B18102_016 + estimate_B18102_019)/(estimate_B18102_015 + estimate_B18102_018))
sex_by_age_hearing <- sex_by_age_hearing %>% mutate(d_hearing_female_over65_percentage = (estimate_B18102_035 + estimate_B18102_038)/(estimate_B18102_034 + estimate_B18102_037))
big_table <- big_table %>% left_join(sex_by_age_hearing %>% select(-NAME), by="GEOID")


## 13. Sex by age by cognitive difficulty (B18104)
sex_by_age_cog <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B18104", year=year, geometry = FALSE) %>% acs_pivot_wider()
sex_by_age_cog <- sex_by_age_cog %>% mutate(d_cognitive_male_over65_percentage = (estimate_B18104_013 + estimate_B18104_016)/(estimate_B18104_012 + estimate_B18104_015))
sex_by_age_cog <- sex_by_age_cog %>% mutate(d_cognitive_female_over65_percentage = (estimate_B18104_029 + estimate_B18104_032)/(estimate_B18104_028 + estimate_B18104_031))
big_table <- big_table %>% left_join(sex_by_age_cog %>% select(-NAME), by="GEOID")


## 14. Sex by age by ambulatory difficulty (B18105)
sex_by_age_amb <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B18105", year=year, geometry = FALSE) %>% acs_pivot_wider()
sex_by_age_amb <- sex_by_age_amb %>% mutate(d_ambulatory_male_over65_percentage = (estimate_B18105_013 + estimate_B18105_016)/(estimate_B18105_012 + estimate_B18105_015))
sex_by_age_amb <- sex_by_age_amb %>% mutate(d_ambulatory_female_over65_percentage = (estimate_B18105_029 + estimate_B18105_032)/(estimate_B18105_028 + estimate_B18105_031))
big_table <- big_table %>% left_join(sex_by_age_amb %>% select(-NAME), by="GEOID")

## 15. Sex by age by self-care difficulty (B18106)
sex_by_age_sc <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B18106", year=year, geometry = FALSE) %>% acs_pivot_wider()
sex_by_age_sc <- sex_by_age_sc %>% mutate(d_selfcare_male_over65_percentage = (estimate_B18106_013 + estimate_B18106_016)/(estimate_B18106_012 + estimate_B18106_015))
sex_by_age_sc <- sex_by_age_sc %>% mutate(d_selfcare_female_over65_percentage = (estimate_B18106_029 + estimate_B18106_032)/(estimate_B18106_028 + estimate_B18106_031))
big_table <- big_table %>% left_join(sex_by_age_sc %>% select(-NAME), by="GEOID")

## 16. Sex by age by independent living status difficulty (B18107)
sex_by_age_ild <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B18107", year=year, geometry = FALSE) %>% acs_pivot_wider()
sex_by_age_ild <- sex_by_age_ild %>% mutate(d_inddifficulty_male_over65_percentage = (estimate_B18107_010 + estimate_B18107_013)/(estimate_B18107_009 + estimate_B18107_012))
sex_by_age_ild <- sex_by_age_ild %>% mutate(d_inddifficulty_female_over65_percentage = (estimate_B18107_023 + estimate_B18107_026)/(estimate_B18107_022 + estimate_B18107_025))
big_table <- big_table %>% left_join(sex_by_age_ild %>% select(-NAME), by="GEOID")

## 17. Age by disability status by health coverage (B18135)
# skip for now, overlap with previous

## 18. Women who had a birth  B13002
women_birth <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B13002", year=year, geometry = FALSE) %>% acs_pivot_wider()
## keep as total counts
women_birth <- women_birth %>% mutate(d_total_women_with_birth=estimate_B13002_001)
women_birth <- women_birth %>% mutate(d_total_births_last_year=estimate_B13002_002)
women_birth <- women_birth %>% mutate(d_total_births_married_last_year=estimate_B13002_003)
women_birth <- women_birth %>% mutate(d_total_births_married1519_last_year=estimate_B13002_004)
women_birth <- women_birth %>% mutate(d_total_births_married2034_last_year=estimate_B13002_005)
women_birth <- women_birth %>% mutate(d_total_births_married3550_last_year=estimate_B13002_006)

women_birth <- women_birth %>% mutate(d_total_births_unmarried_last_year=estimate_B13002_007)
women_birth <- women_birth %>% mutate(d_total_births_unmarried1519_last_year=estimate_B13002_008)
women_birth <- women_birth %>% mutate(d_total_births_unmarried2034_last_year=estimate_B13002_009)
women_birth <- women_birth %>% mutate(d_total_births_unmarried3550_last_year=estimate_B13002_010)

women_birth <- women_birth %>% mutate(d_total_no_births_last_year=estimate_B13002_011)
women_birth <- women_birth %>% mutate(d_total_no_births_married_last_year=estimate_B13002_012)
women_birth <- women_birth %>% mutate(d_total_no_births_married1519_last_year=estimate_B13002_013)
women_birth <- women_birth %>% mutate(d_total_no_births_married2034_last_year=estimate_B13002_014)
women_birth <- women_birth %>% mutate(d_total_no_births_married3550_last_year=estimate_B13002_015)

women_birth <- women_birth %>% mutate(d_total_no_births_unmarried_last_year=estimate_B13002_016)
women_birth <- women_birth %>% mutate(d_total_no_births_unmarried1519_last_year=estimate_B13002_017)
women_birth <- women_birth %>% mutate(d_total_no_births_unmarried2034_last_year=estimate_B13002_018)
women_birth <- women_birth %>% mutate(d_total_no_births_unmarried3550_last_year=estimate_B13002_019)


big_table <- big_table %>% left_join(women_birth %>% select(-NAME), by="GEOID")


## 19. Race (B02001)
race <- get_acs_table_tracts_for_state_with_geom(state, table_name = "B02001", year=year, geometry = FALSE) %>% acs_pivot_wider()
race <- race %>% mutate(d_white_percentage = estimate_B02001_002/estimate_B02001_001,
                        d_black_percentage = estimate_B02001_003/estimate_B02001_001,
                        d_native_percentage = estimate_B02001_004/estimate_B02001_001,
                        d_asian_percentage = estimate_B02001_005/estimate_B02001_001,
                        d_hawaii_pi_percentage = estimate_B02001_006/estimate_B02001_001,
                        d_other_race_percentage = estimate_B02001_007/estimate_B02001_001,
                        d_two_more_race_percentage = estimate_B02001_008/estimate_B02001_001,
                        d_other_race_percentage = estimate_B02001_009/estimate_B02001_001)
big_table <- big_table %>% left_join(race %>% select(-NAME), by="GEOID")

## 20. house heating and fuel
heating <- get_acs_table_tracts_for_state_with_geom(state, "B25040", year=year, geometry = FALSE) %>% acs_pivot_wider()
heating <- heating %>% mutate(d_energy_gas_percentage=estimate_B25040_002/estimate_B25040_001)
heating <- heating %>% mutate(d_energy_bottledgas_percentage=estimate_B25040_003/estimate_B25040_001)
heating <- heating %>% mutate(d_energy_electricity_percentage=estimate_B25040_004/estimate_B25040_001)
heating <- heating %>% mutate(d_energy_fueloil_percentage=estimate_B25040_005/estimate_B25040_001)
heating <- heating %>% mutate(d_energy_coal_percentage=estimate_B25040_006/estimate_B25040_001)
heating <- heating %>% mutate(d_energy_wood_percentage=estimate_B25040_007/estimate_B25040_001)
heating <- heating %>% mutate(d_energy_solar_percentage=estimate_B25040_008/estimate_B25040_001)
heating <- heating %>% mutate(d_energy_otherfuel_percentage=estimate_B25040_009/estimate_B25040_001)
heating <- heating %>% mutate(d_energy_nofuel_percentage=estimate_B25040_010/estimate_B25040_001)
big_table <- big_table %>% left_join(heating %>% select(-NAME), by="GEOID")

cat(sprintf("ACS5;state:%s;year:%i... done!\n", state, year ))
big_table <- big_table %>% mutate(state=state, year=year)
big_table %>% write_rds(file=pathout)
