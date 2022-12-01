# Adding Geospatial social determinants: Climate Data Warehouse

## Author

Chirag J Patel (chirag@hms.harvard.edu)
12/01/22

## Introduction: The confluence of extreme heat cold on the health and longevity of an Aging Population with Alzheimers and related Dementia

Project Summary/Abstract About ten percent of Americans older than 65 (5.8 million) are estimated to live with Alzheimer’s dementia (AD) or related dementias (ADRD), constituting the 5th leading cause of death among 65 and older in the U.S. Yet, our estimates from the prevalence of AD/ADRD outdated and the vulnerabilities of the older adults living with AD/ADRD to extreme environmental change remain unknown. Understanding the vulnerabilities of these populations is critical due to two of the most prominent upcoming global challenges: a growing aging population and a changing climate. On the one hand, the number of Americans ages 65 and older is projected to nearly double, while those with AD/ADRD are projected to nearly triple by 2050. On the other hand, the severity and frequency of the extreme environmental changes, such as extreme heat and cold events, are expected to increase due to climate change. Extreme heat/cold events can increase mortality and healthcare utilization outcomes (e.g., hospitalization) among older adults. More frequent and intense extreme heat and cold events can pose disproportionate risks to the elderly population living with AD/ADRD through certain cognitive biologic pathways. However, we do not know about potential pathways through which exposure to extreme changes in ambient temperature may directly (or indirectly through other stressors) impact older AD/ADRD patients, whose responses to extreme environmental change may be disrupted/delayed due to memory loss, challenges in planning and solving problems, trouble in understanding visual images, and confusion with time and place. Our goal is to characterize the extent of the exacerbation of cause-specific healthcare utilization outcomes (i.e., hospitalizations, hospital readmissions within 30 days, primary care visits, and specialist visits) and mortality due to extreme heat/cold events, among the older adults living with AD/ADRD. Using a longitudinal cohort of over 63 million Medicare enrollees (≥65 years), we will apply comprehensive and well-validated computational approaches to study the immediate, short-, and long-term effects of extreme heat and cold events on healthcare utilization outcomes and mortality. 

[NIH project](https://reporter.nih.gov/search/zDlE7cswwk2lQCp1bgIQLw/project-details/10448053)



## Preparing candidate ACS variables for climate-related analyses

- See script: ehec_candidates.R

Usage:
Rscript cdw_candidates.R -y <year> -s <state>
Example:
Rscript cdw_candidates.R -y 2020 -s CA

Derived variables begin with 'd_'

