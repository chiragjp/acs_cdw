# Geospatial social determinants for demographic and epidemiological applications

Chirag J Patel (chirag@hms.harvard.edu)

Repository start date: 12/01/22


## Preparing candidate ACS variables by state

- See script: ehec_candidates.R

Usage:
Rscript cdw_candidates.R -y <year> -s <state> -g <geography_type>
Example:
Rscript cdw_candidates.R -y 2020 -s CA -g tract

Derived variables begin with 'd_'


### Papers

- [Repurposing large health insurance claims data to estimate genetic and environmental contributions in 560 phenotypes](https://www.nature.com/articles/s41588-018-0313-7)
- [Association and Interaction of Genetics and Area-Level Socioeconomic Factors on the Prevalence of Type 2 Diabetes and Obesity](https://diabetesjournals.org/care/article/46/5/944/148426/Association-and-Interaction-of-Genetics-and-Area)



### Grants and support

#### The confluence of extreme heat cold on the health and longevity of an Aging Population with Alzheimers and related Dementia

Project Summary/Abstract About ten percent of Americans older than 65 (5.8 million) are estimated to live with Alzheimer’s dementia (AD) or related dementias (ADRD), constituting the 5th leading cause of death among 65 and older in the U.S. Yet, our estimates from the prevalence of AD/ADRD outdated and the vulnerabilities of the older adults living with AD/ADRD to extreme environmental change remain unknown. Understanding the vulnerabilities of these populations is critical due to two of the most prominent upcoming global challenges: a growing aging population and a changing climate. On the one hand, the number of Americans ages 65 and older is projected to nearly double, while those with AD/ADRD are projected to nearly triple by 2050. On the other hand, the severity and frequency of the extreme environmental changes, such as extreme heat and cold events, are expected to increase due to climate change. Extreme heat/cold events can increase mortality and healthcare utilization outcomes (e.g., hospitalization) among older adults. More frequent and intense extreme heat and cold events can pose disproportionate risks to the elderly population living with AD/ADRD through certain cognitive biologic pathways. However, we do not know about potential pathways through which exposure to extreme changes in ambient temperature may directly (or indirectly through other stressors) impact older AD/ADRD patients, whose responses to extreme environmental change may be disrupted/delayed due to memory loss, challenges in planning and solving problems, trouble in understanding visual images, and confusion with time and place. Our goal is to characterize the extent of the exacerbation of cause-specific healthcare utilization outcomes (i.e., hospitalizations, hospital readmissions within 30 days, primary care visits, and specialist visits) and mortality due to extreme heat/cold events, among the older adults living with AD/ADRD. Using a longitudinal cohort of over 63 million Medicare enrollees (≥65 years), we will apply comprehensive and well-validated computational approaches to study the immediate, short-, and long-term effects of extreme heat and cold events on healthcare utilization outcomes and mortality. 

[NIH project on REPORTER](https://reporter.nih.gov/search/zDlE7cswwk2lQCp1bgIQLw/project-details/10448053)


#### Data science tools to identify robust exposure-phenotype associations for precision medicine

Phenotypic variability across demographically diverse populations are driven by environmental factors. The overall goal of this proposal is to deploy data science approaches to drive discovery of associations between exposures (E) and phenotypes (P) in demographically diverse populations. We lack data science methods to associate, replicate, and prioritize exposure variables of the exposome (E) in phenotypes (P) and disease incidence (D), required for the delivery of precision medicine. Observational studies are fraught with 4 unsolved data science challenges. First, E-based studies are: (1) limited to associating a few hypothesized exposure- phenotype pairs (E-P) at a time, leading to a fragmented literature of environmental associations. Machine learning (ML) approaches for feature selection and prediction hold promise, however, (2) most extant E-based cohorts contain missing data, challenging the use of ML to detect complex E-P associations, Third, (3) biases, such as confounding and study design influence associations and hinder translation. Fourth, (4) there are few well-powered data resources that systematically document longitudinal E-P and E-D associations across massive precision medicine. It is a challenge to systematically associate a number of exposures in multiple phenotypes and replicate these associations across cohorts. (Aim 1). The “vibration of effects”, or the degree to which associations change as a function of study design (e.g., analytic method, sample size) and model choice is a hidden bias in observational studies (Aim 2). Third, an outstanding question is the degree to which environmental differences lead to health disparities. To address these challenges and gaps, we propose to Aim 1: develop and test machine learning methods to associate multiple environmental exposure indicators with multiple phenotypes: EP-WAS. We hypothesize that exposures will explain a significant amount of variation in phenotype in populations and will deposit all data and models in a novel EP-WAS Catalog. Aim 2: Quantitate how study design influences associations between exposure biomarkers and phenotype. We will scale up, extend, and test a method called “vibration of effects” (VoE) to measure how study criteria influences the stability of associations (how reproducible associations are as a function of analytic choice). Aim 3. Leverage EP-WAS and VoE to disentangle biological, demographic, and environmental influences of phenotypic disparities in hypercholesterolemia. We will deploy EP-WAS and VoE packaged libraries in the largest cohort study to partition phenotypic variation across demographic groups in factors for hypercholesterolemia. We will equip the biomedical community with data science approaches for robust data-driven discovery and interpretation of exposure-phenotype factors in observational datasets, required for the identification of environmental health disparities. For the first time, investigators will ascertain the collective role of the environment in heart disease at scale just in time for the All of Us program.

[NIH Project on REPORTER](https://reporter.nih.gov/project-details/10653214)
