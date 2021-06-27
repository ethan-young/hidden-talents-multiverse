# Setup -------------------------------------------------------------------

# Libraries
library(tidyverse)
library(sjlabelled)

# my functions
source("scripts/0-functions/create_codebook.R")

# Data
load("data/data1_raw.Rdata")

# Non-arbitrary decisions -------------------------------------------------
data2_non_arbitrary <- 
  data1_raw %>% 
  # Only completed task data
  filter(
    !(is.na(abs_updating) & is.na(eco_updating)),
    !(is.na(abs_shifting_sc) & is.na(eco_shifting_sc)),
  ) %>% 
  # No interviewer coded impairments
  filter(
    non_arb_impaired == 0, 
    non_arb_impaired_assent == 0 | is.na(non_arb_impaired_assent)
  ) %>% 
  # Only allow 1 missed attention check or all high/low responses to scales with reverse coded items
  filter(
    non_arb_attention_check <= 1 | is.na(non_arb_attention_check), 
    non_arb_q_responses < 2 | is.na(non_arb_q_responses)
  ) %>%
  # No extreme distractions during the cognitive tasks
  filter(non_arb_distractions < 2) %>%
  # No participants receiving more than 60 minutes of Special Education per day
  filter(non_arb_sped_60min != 1 | is.na(arb_sped)) %>% 
  # Deal with siblings
  mutate(
    siblings = ifelse(siblings %in% c("wjms_sibling_000","bgc_sibling_000"),"sibling_000", siblings)
  ) %>% 
  # Put anyone who no longer has a sibling because of above steps into giant group
  group_by(siblings) %>% 
  mutate(siblings_n = n()) %>% 
  ungroup() %>% 
  mutate(siblings_id = ifelse(siblings_n == 1, "sibling_000", siblings)) %>% 
  group_by(siblings_id) %>% 
  # Count number of siblings each person has
  mutate(siblings_n = n()) %>% 
  ungroup() %>% 
  select(-siblings) %>% 
  var_labels(
    siblings_id = "Sibling ID",
    siblings_n  = "The number of siblings each participant has who also participated in this study "
  )

# Create Overall Composites -----------------------------------------------
data3_composites <- 
  data2_non_arbitrary %>% 
  # Create overall IV composites
  mutate(
    unp_interview   = rowMeans(scale(across(.cols = starts_with("unp_interview"))), na.rm = T),
    unp_agg         = rowMeans(scale(across(.cols = c(unp_interview, unp_perceived))), na.rm = T),
    vio_agg         = rowMeans(scale(across(.cols = c(vio_neighborhood, vio_fighting))), na.rm = T),
    ses_interview   = rowMeans(scale(across(.cols = starts_with("ses_interview"))), na.rm = T),
    ses_school      = ifelse(ses_school_freelunch == 0, .5, -.5),
    ses_interview_z = scale(ses_interview) %>% as.numeric(),
    ses_perceived_z = scale(ses_perceived) %>% as.numeric(),
    ses_agg         = rowMeans(across(.cols = c(ses_perceived_z, ses_interview_z, ses_school)), na.rm = T),
  ) %>% 
  # Order dataset in a sensible way
  select(
    id, sample_code, interviewer, site, classroom, 
    siblings_id, has_sibling, siblings_n,
    sex, ethnicity, age, 
    starts_with("non_arb"),
    starts_with("arb"),
    matches("^test_envr"), 
<<<<<<< HEAD
<<<<<<< HEAD
    matches("^csd(\\d|\\d\\d|)$"),
=======
    matches("^csd(\\d|)$"),
>>>>>>> a0940e3bd988ef96e84639d84f581ebe385b1ee1
=======
    matches("^csd(\\d|)$"),
>>>>>>> a0940e3bd988ef96e84639d84f581ebe385b1ee1
    matches("^unp_perceived"),
    matches("^unp_interview"),
    unp_agg,
    matches("^vio_(neighborhood|fighting)"),
    vio_agg,
    matches("^ses_(perceived|interview|school)"),
    ses_agg,
    matches("^(abs|eco)_shifting"),
    matches("^(abs|eco)_updating"),
    -ends_with("z")
  ) %>% 
  # Create labels for composites
  var_labels(
    unp_interview   = "Unpredictability: interview-based measure of unpredictabilty using parental figures, moves involving new people, and a disrupted family.
                       Variables were standardized before averageing. Higher scores mean more unpredictability",
    unp_agg         = "Unpredictability: composite variable of interview-based (unp_interview) and 
                       self-report perceived childhood unpredictability (unp_perceived). Variables were standardized before averageing.
                       Higher scores mean more unpredictability",
    vio_agg         = "Violence Exposure: Average of the standardized vio_fighting and vio_exposure variables, higher scores mean more violence exposure",
    ses_interview   = "SES: Interview-based SES composite variable of parental education (standardized) and occupational prestige (standardized), 
                       higher scores indicate higher parental SES (more education and occupational prestige)",
    ses_school      = "SES: recoded school provided economic codes for combining with other SES variables, .5 = no school provided assistance, -.5 = school provided assistance",
    ses_agg         = "SES: composite variable of perceived SES (ses_perceived), parental SES (ses_interview), and school provided SES (ses_school).
                       perceived SES and parent SES were standarized prior to aggregating and school SES was coded as .5 and -.5 (to reflect 1/2 SD above and below the mean).
                       All three variables were then averaged to create the final composite.",
  )

# Multiverse base dataset -------------------------------------------------
data4_multiverse_base <- 
  data3_composites %>% 
  # Rename variables according to arbitrary decisions
  rename(
    arb_sample          = sample_code,
    arb_distractions    = non_arb_distractions,
    arb_attention_check = non_arb_attention_check,
    arb_abs_shift       = abs_shifting_correct,
    arb_eco_shift       = eco_shifting_correct,
    arb_csd             = csd
  ) %>% 
  # Leave out most variables (e.g., individual items) and focus on analysis variables
  select(
    # Basic meta data and siblings
    id, siblings_id,
    # Specification variables
    starts_with("arb"),
    # Control variables
    age, test_envr,
    # IVs
    unp_perceived, unp_interview, unp_agg,
    vio_neighborhood, vio_fighting, vio_agg,
    ses_perceived, ses_interview, ses_school, ses_agg,
    # DVs
    abs_shifting_sc, eco_shifting_sc, abs_updating, eco_updating
  )

# Create Codebooks --------------------------------------------------------
vars1_raw <- create_codebook(data1_raw)
vars2_non_arbitrary <- create_codebook(data2_non_arbitrary)
vars3_composites <- create_codebook(data3_composites)
vars4_multiverse_base <- create_codebook(data4_multiverse_base)

# Write .csv files for data and codebooks ---------------------------------
# Data
write_csv(data1_raw, "data/1-raw.csv")
write_csv(data2_non_arbitrary, "data/2-non_arbitrary.csv")
write_csv(data3_composites, "data/3-composites.csv")
write_csv(data4_multiverse_base, "data/4-multiverse_base.csv")

# Codebooks
write_csv(vars1_raw, "codebooks/vars1_raw.csv")
write_csv(vars2_non_arbitrary, "codebooks/vars2_non_arbitrary.csv")
write_csv(vars3_composites, "codebooks/vars3_composites.csv")
write_csv(vars4_multiverse_base, "codebooks/vars4_multiverse_base.csv")

# Save all data objects for use in multiverse analysis --------------------
save.image("data/data2_analysis.Rdata")
