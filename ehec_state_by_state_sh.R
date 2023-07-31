# Chirag J Patel

# create a .sh script to scale over states


library(tidycensus)
data(fips_codes)

states <- unique(fips_codes$state)

for(state in states) {
  cmd <- sprintf("Rscript ehec_candidates.R -s %s -y 2020 -g county\n", state)
  cat(cmd)
}