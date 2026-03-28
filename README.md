# ACS CDW — Geospatial Social Determinants for Demographic & Epidemiological Applications

> Census-tract, county, and ZIP code (ZCTA) level socioeconomic indicators derived from the American Community Survey, linked to CDC PLACES health data.

**Chirag J Patel** | [chirag@hms.harvard.edu](mailto:chirag@hms.harvard.edu) | Harvard Medical School

---

## Overview

This pipeline uses [`tidycensus`](https://walker-data.com/tidycensus/) to download **ACS 5-year estimates** and derive **50+ socioeconomic and demographic indicators** per geographic unit. Indicators are based on the sociodeprivation index framework (Lakhani, *Nature Genetics*, 2019).

**Supported geographies:** Census tracts | Counties | ZIP Code Tabulation Areas (ZCTAs)

```
Census API (tidycensus)
       |
       v
 ehec_candidates.R        Download 20 ACS tables, derive d_* variables (per state)
       |
       v
 ehec_for_trends_gather.R  Consolidate states, merge with CDC PLACES
       |
       v
 tract_to_zcta.R           Aggregate tracts to ZIP codes (population-weighted)
```

---

## Quick start

### 1. Setup

Get a [Census API key](https://api.census.gov/data/key_signup.html), then create `api_key.R` (gitignored):

```r
api_key <- "YOUR_KEY_HERE"
```

### 2. Download ACS data

```bash
# Single state
Rscript ehec_candidates.R -y 2020 -s CA -g tract

# All states and territories
bash state_by_state.sh 2020 tract
bash state_by_state.sh 2020 county
```

### 3. Consolidate & merge with PLACES

```bash
Rscript ehec_for_trends_gather.R -y 2020
```

### 4. Aggregate to ZIP codes

```bash
Rscript zcta_tract_crosswalk.R                                        # one-time download
Rscript tract_to_zcta.R -i out/ehe_acs_tract.rds -o out/ehe_acs_zcta.rds
```

---

## Scripts

| Script | What it does |
|:---|:---|
| **`ehec_candidates.R`** | Downloads 20 ACS tables for one state/year/geography, derives `d_*` indicators |
| **`state_by_state.sh`** | Loops over all 56 states & territories: `bash state_by_state.sh <year> <geotype>` |
| **`ehec_for_trends_gather.R`** | Gathers per-state RDS files, merges with CDC PLACES |
| **`zcta_tract_crosswalk.R`** | Downloads Census Bureau 2020 ZCTA-to-tract relationship file with population weights |
| **`tract_to_zcta.R`** | Aggregates tract-level data to ZCTA using population-weighted averages/sums |
| **`download_acs_table.R`** | Lightweight single-table downloader |
| **`table_concepts.R`** | Generates CSV mapping ACS variable codes to labels |
| `1_how_to.Rmd` | Tutorial: loading data, joining with PLACES |
| `2_pca.Rmd` | PCA-based composite deprivation index |
| `ehe_ecs_acs_places_merge.Rmd` | Merge ACS/PLACES with extreme heat/cold event catalog |

---

## Derived variables

All derived variables are prefixed with **`d_`**. Examples below; see `ehec_candidates.R` for the full list.

| Category | Variables | ACS Table(s) |
|:---|:---|:---|
| **Economic** | Median income, median property value, % below poverty | B19013, B25077, B17020 |
| **Employment** | % unemployed | B23025 |
| **Education** | % < HS diploma, % 4-yr college (by sex/age) | B15001 |
| **Demographics** | Race/ethnicity %, % over 65/75/85 (by sex), median age | B02001, B01001, B01002 |
| **Disability** | Cognitive, hearing, ambulatory, self-care, independent living, general (% over 65) | B18101-B18107 |
| **Housing** | % crowded households, heating fuel type | B25014, B25040 |
| **Health insurance** | % uninsured, % public insurance, % uninsured + unemployed | B27011 |
| **Fertility** | Births by marital status and age group | B13002 |

---

## Output structure

```
out/
├── {year}/                       # Per-state tract-level RDS files
├── {year}_county/                # Per-state county-level RDS files
├── ehe_acs_tract.rds             # All tracts, consolidated
├── ehe_acs_counties.rds          # All counties, consolidated
├── ehe_acs_zcta.rds              # All ZCTAs (from crosswalk aggregation)
└── ehe_trends_acs_places.Rdata   # ACS + CDC PLACES merged
```

---

## Data sources

| Source | Description |
|:---|:---|
| [ACS 5-year estimates](https://www.census.gov/programs-surveys/acs) | Tables B01001 through B27011 via `tidycensus` |
| [CDC PLACES](https://www.cdc.gov/places/) | Tract and county level health indicator estimates (2023 release) |
| [Census ZCTA-tract relationship file](https://www.census.gov/geographies/reference-files/time-series/geo/relationship-files.2020.html) | 2020 population-weighted geographic crosswalk |

---

## Papers

- Patel CJ *et al.* [Repurposing large health insurance claims data to estimate genetic and environmental contributions in 560 phenotypes.](https://www.nature.com/articles/s41588-018-0313-7) *Nature Genetics*, 2019.
- Patel CJ *et al.* [Association and Interaction of Genetics and Area-Level Socioeconomic Factors on the Prevalence of Type 2 Diabetes and Obesity.](https://diabetesjournals.org/care/article/46/5/944/148426/Association-and-Interaction-of-Genetics-and-Area) *Diabetes Care*, 2023.

---

## Funding

<details>
<summary><b>The confluence of extreme heat/cold on the health and longevity of an aging population with AD/ADRD</b></summary>

Characterizing the exacerbation of cause-specific healthcare utilization outcomes and mortality due to extreme heat/cold events among older adults living with Alzheimer's disease and related dementias. Uses a longitudinal cohort of 63M+ Medicare enrollees (age 65+).

[NIH RePORTER](https://reporter.nih.gov/search/zDlE7cswwk2lQCp1bgIQLw/project-details/10448053)

</details>

<details>
<summary><b>Data science tools to identify robust exposure-phenotype associations for precision medicine</b></summary>

Developing machine learning methods (EP-WAS) to associate multiple environmental exposure indicators with multiple phenotypes across demographically diverse populations, and quantifying the "vibration of effects" to measure how study design influences association stability.

[NIH RePORTER](https://reporter.nih.gov/project-details/10653214)

</details>
