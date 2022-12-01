# Chirag J Patel
# 11/27/22
# download by state and year

# params:
# year
# table name
# state

library(tidyverse)
library(tidycensus)
library(getopt)
api_key <- "7bea2bd290231fbe8e72313e72b7957136ae6e35"
#data(fips_codes)

spec = matrix(c(
  'state', 's', 1, "character",
  'table'   , 't', 1, "character",
  'year'  , 'y', 1, "integer"
), byrow=TRUE, ncol=4)
opt = getopt(spec)

state <- opt$state #"CA"
table_name <- opt$table #"B01001"
year <- opt$year #2020

file_out_name <- sprintf('%s_%s_%i.rds', table_name, state, year)

vars <- load_variables(
  year=year,
  dataset = c("acs5"),
  cache = FALSE
) 
vars <- vars %>% mutate(tablename=sapply(strsplit(vars$name, "\\_"), function(arr) {arr[[1]]}))

get_acs_table_tracts_for_state <- function(state, table_name, ...) {
  get_acs("tract", year=year, key=api_key, state = state, table = table_name, geometry = FALSE) ## gets all the variables for a state and census tract
}

tab <- get_acs_table_tracts_for_state(state, table_name)
variable_names <- vars %>% filter(name %in% unique(tab$variable), tablename == table_name)


out <- list(data_table=tab, variable_names=variable_names, state=state, year=2020, table_name=table_name)

write_rds(out, file=file.path("out", file_out_name))





