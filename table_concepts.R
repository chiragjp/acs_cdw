## write out table concepts for selection

library(tidyverse)
library(tidycensus)

vars <- load_variables(
  year=2020,
  dataset = c("acs5"),
  cache = FALSE
)


vars <- vars %>% mutate(table_name=sapply(strsplit(vars$name, "\\_"), function(arr) {arr[[1]]}))
table_concepts <- vars %>% select(table_name, name, concept, geography,  label)
table_concepts <- table_concepts %>% mutate(col_size = nchar(concept))
table_concepts %>% write_csv("table_concepts.csv")

