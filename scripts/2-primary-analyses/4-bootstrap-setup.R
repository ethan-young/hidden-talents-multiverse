# Setup -------------------------------------------------------------------
library(tidyverse)
library(lmerTest)
library(broom.mixed)
library(tidymodels)
library(ggeffects)
library(interactions)
library(effectsize)

# Multiverse data-list for primary analyses
load("multiverse-objects/1-multiverse-datasets/datalist-agg-ivs.Rdata")

# Coefficients from primary analyses
load("multiverse-objects/2-primary-analyses/3-extracted-effects.Rdata")

# Set seed for reproducibility
set.seed(1234)

# Create null data --------------------------------------------------------
# Create K 'null' dvs, in my case 64
## 1. Get coefficients from original multiverse
## 2. Subtract coefficients from original dv, this creates K null dvs
## 3. Compile a null dataset with all K outcomes

# 1. All Unstandardized Effects -------------------------------------------
boot_effects <- 
  primary_effects_data %>% 
  filter(str_detect(mod_term, "_z")) %>% 
  select(iv, dv, spec_number,mod_term_group, mod_estimate) %>% 
  pivot_wider(names_from = "mod_term_group",values_from = "mod_estimate") %>% 
  mutate(iv = iv %>% str_to_lower() %>% str_replace("unpredictability","unp")) %>% 
  rename(main_iv = `Main Effect`, main_type = `Task-Type`, int = Interaction) %>% 
  arrange(spec_number,iv,dv)


# 2. Giant null dataset ---------------------------------------------------
## Input: 
### - specification index (1:64)
### - boot_effects, unstandardized effects from each spec index per iv-dv combination
### - original data
## Output:
### - original data with null dvs per iv-dv-specification combination, in long form (data are row-binded per specification)
boot1_null <- 
  seq_along(multi_data_list) %>% 
  map_df(function(x){
    
    # Unstandardized coefficients from shifting analyses
    shifting <- 
      boot_effects %>%
      filter(spec_number == x, dv == "Attention-Shifting") %>% 
      split(.$iv) %>% 
      map(function(x){
        x %>% select(main_iv, int) %>% as_vector()
      })
    
    # Unstandardized coefficients from updating analyses
    updating <- 
      boot_effects %>%
      filter(spec_number == x, dv == "Working Memory Updating") %>% 
      split(.$iv) %>% 
      map(function(x){
        x %>% select(main_iv, int) %>% as_vector()
      })
    
    # Remove Effects of interest by subtracting iv*coefficients from the outcome
    null_dv <- 
      data4_multiverse_base %>%
      pivot_longer(matches("^(eco|abs)_"), names_to = "type_task", values_to = "score") %>% 
      separate(type_task, into = c("type","task"), sep = "_", extra = "drop") %>% 
      mutate(
        spec_number     = x,
        type_z          = ifelse(type == "abs", -1, 1),
        unp_agg_z       = scale(unp_agg) %>% as.numeric(),
        vio_agg_z       = scale(vio_agg) %>% as.numeric(),
        ses_agg_z       = scale(ses_agg) %>% as.numeric(),
        # Unpredictability
        null_unp_main = case_when(task == "shifting" ~ score - (shifting$unp[["main_iv"]]*unp_agg_z),
                                  task == "updating" ~ score - (updating$unp[["main_iv"]]*unp_agg_z)),
        null_unp_int  = case_when(task == "shifting" ~ score - (shifting$unp[["int"]]*unp_agg_z*type_z),
                                  task == "updating" ~ score - (updating$unp[["int"]]*unp_agg_z*type_z)),
        # Violence
        null_vio_main = case_when(task == "shifting" ~ score - (shifting$vio[["main_iv"]]*vio_agg_z),
                                  task == "updating" ~ score - (updating$vio[["main_iv"]]*vio_agg_z)),
        null_vio_int  = case_when(task == "shifting" ~ score - (shifting$vio[["int"]]*vio_agg_z*type_z),
                                  task == "updating" ~ score - (updating$vio[["int"]]*vio_agg_z*type_z)),
        # SES
        null_ses_main = case_when(task == "shifting" ~ score - (shifting$ses[["main_iv"]]*ses_agg_z),
                                  task == "updating" ~ score - (updating$ses[["main_iv"]]*ses_agg_z)),
        null_ses_int  = case_when(task == "shifting" ~ score - (shifting$ses[["int"]]*ses_agg_z*type_z),
                                  task == "updating" ~ score - (updating$ses[["int"]]*ses_agg_z*type_z)),
      )
  })

# 3. Wide null dataset ----------------------------------------------------
## Take null dvs and spread them out into their own columns, per specification
## Result will be a data frame with 4 rows per id (eco v abs for shifting and updating)
## Null dvs will be indicated by the following format: null_[iv]_[effect]_[specification]
## Example: null main effect dv for unp, specification 26 would be: null_unp_main_26
boot2_null <- 
  boot1_null %>% 
  pivot_wider(names_from = c(spec_number), values_from = starts_with("null"), names_sep = "_") %>% 
  select(
    contains("id"),
    starts_with("arb"),
    test_envr, age, 
    contains("agg"), 
    type, task, type_z, 
    starts_with("null")
  )

# Bootstrap Resampling Procedure --------------------------------------
## Create 500 random bootstrap samples from null data:
### Take null data and resample rows
#### 1. Widen data to one row per participant
#### 2. Sample n rows (for me 618) with replacement
#### 3. Create a new row identifier because my participant id will be repeated (because of replacement)
#### 4. Put data back in to long format for mixed models. id_boot will be ID for mixed models
#### Do steps 1-4 500 times and put into a giant list
boot_data_list <- 
  map(1:500, function(x){
    boot_list_element <- 
      boot2_null %>% 
      # 1
      pivot_wider(id_cols = c(1:18), names_from = c(type, task), values_from = starts_with("null"), names_glue = "{type}.{task}.{.value}") %>% 
      # 2
      slice_sample(n = nrow(boot2_null)/4, replace = T) %>% 
      # 3
      mutate(id_boot = 1:n()) %>% 
      select(contains("id"), everything()) %>% 
      # 4
      pivot_longer(cols = matches("_(\\d\\d|\\d)$"), names_to = c("type", "task", "null"), names_sep = "\\.") %>% 
      pivot_wider(names_from = null, values_from = value)
    
    message("bootstrapped dataset ", x, " created\n")
    boot_list_element
  })

# Save bootstrap data -----------------------------------------------------
save(
  boot_data_list,
  file = "multiverse-objects/2-primary-analyses/4-bootstrapped-data.Rdata"
  )
