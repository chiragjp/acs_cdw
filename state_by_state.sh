#!/bin/bash
## Run ehec_candidates.R for all US states and territories
## Usage: bash state_by_state.sh <year> <geotype>
## Example: bash state_by_state.sh 2020 tract

YEAR=${1:-2020}
GEOTYPE=${2:-tract}

STATES=(AL AK AZ AR CA CO CT DE DC FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY AS GU MP PR UM VI)

echo "Running ehec_candidates.R for ${#STATES[@]} states/territories (year=$YEAR, geotype=$GEOTYPE)"

for STATE in "${STATES[@]}"; do
  echo "--- $STATE ---"
  Rscript ehec_candidates.R -s "$STATE" -y "$YEAR" -g "$GEOTYPE"
done

echo "Done."
