# Setup -------------------------------------------------------------------
# Libraries
library(tidyverse)

# Load effect data.frames -------------------------------------------------
load("multiverse-objects/3-secondary-analyses/set-1/a1-results-ses-vio.Rdata")

# Extract Parameters ------------------------------------------------------
secondary1a_effects_data <-
  map_df(secondary1a_ses_vio_updating, function(x){ 
    bind_cols(
      n = x$n_model_obs,
      left_join(
        x$model_tidy %>% select(mod_term:mod_p.value), 
        x$model_std_effects %>% rename_with(~paste0("mod_",.x)), 
        by = c("mod_term" = "mod_Parameter")
      ),
      x$specifications %>% 
        select(-spec_expr) %>% 
        pivot_wider(names_from = "spec_var", values_from = "name") %>% 
        rename_with(.cols = !spec_number, ~paste0("spec_",.x))
    )
  }) %>% 
  rename_with(tolower) %>% 
  filter(!str_detect(mod_term, "^sd__")) %>% 
<<<<<<< HEAD
  mutate(
    # Do this to reverse code SES to match low SES to High poverty
    across(
      .cols = c(mod_estimate, mod_std.error, mod_statistic, mod_std_coefficient, mod_ci, mod_ci_low, mod_ci_high),
      .fns = ~ifelse(str_detect(mod_term,"ses"), .x * -1, .x)
    )
  ) %>% 
=======
>>>>>>> a0940e3bd988ef96e84639d84f581ebe385b1ee1
  group_by(mod_term) %>% 
  mutate(
    spec_rank  = as.numeric(fct_reorder(as_factor(spec_number), mod_std_coefficient)),
    median_dbl = median(mod_std_coefficient),
    median_chr = median_dbl %>% round(2) %>% as.character,
    pval_prop  = (sum(mod_p.value < .05)/64) * 100
  ) %>% 
  ungroup() %>% 
  mutate(
    mod_sig        = case_when(mod_p.value <  .05 & mod_std_coefficient > 0 ~ "pos-sig",
                               mod_p.value <  .05 & mod_std_coefficient < 0 ~ "neg-sig",
                               mod_p.value >= .05 ~ "non"),
    mod_term_num   = case_when(str_detect(mod_term, "Intercept") ~ -1,
                               mod_term == "age"          ~ 0,
                               mod_term == "test_envr"    ~ 0,
                               mod_term == "type_z"       ~ 1,
                               mod_term == "vio_agg_z"    ~ 2,
                               mod_term == "ses_agg_z"    ~ 2,
                               str_detect(mod_term, ":")  ~ 3),
    mod_term_label = case_when(str_detect(mod_term, "Intercept") ~ "Intercept",
                               mod_term == "age"          ~ "Age",
                               mod_term == "test_envr"    ~ "Test Environment",
                               mod_term == "type_z"       ~ "Task Type",
                               mod_term == "vio_agg_z"    ~ "Violence",
                               mod_term == "ses_agg_z"    ~ "SES",
                               str_detect(mod_term, ":")  ~ "Interaction"),
    mod_term_group = factor(mod_term_num,
                            levels = c(-1,0,1,2,3), 
                            labels = c("Intercpet","Covariate","Task-Type","Main Effect", "Interaction")),
    mod_term_fct   = factor(mod_term_label) %>% fct_reorder(mod_term_num),
    pval_prop      = paste0(round(pval_prop,2),"% of ps"," < .05"),
    pval_prop      = fct_reorder(pval_prop, mod_term_num),
    dv             = "Working Memory Updating"
  )

# Medians -----------------------------------------------------------------
secondary1a_effects_medians <- 
  secondary1a_effects_data %>% 
  select(dv, contains("_term"), contains("median_")) %>% 
  distinct()

# Interaction Data --------------------------------------------------------
secondary1a_effects_points <- 
  map_df(secondary1a_ses_vio_updating, function(x){ 
    specs <-
      x$specifications %>% 
      select(-spec_expr) %>% 
      pivot_wider(names_from = "spec_var", values_from = "name") %>% 
      rename_with(.cols = !spec_number, ~paste0("spec_",.x))
    
    bind_rows(
      bind_cols(x$model_effects1, n = x$n, specs, iv = "SES", mod_term = "ses_agg_z:type_z") %>% tibble(),
      bind_cols(x$model_effects2, n = x$n, specs, iv = "Violence", mod_term =  "type_z:vio_agg_z") %>% tibble()
    )
  }) %>% 
  left_join(
    secondary1a_effects_data %>% 
      filter(str_detect(mod_term_label, "Interaction")) %>% 
      select(mod_term, dv, spec_number, mod_sig)
  )

<<<<<<< HEAD
# Simple Slopes -----------------------------------------------------------
secondary1a_simple_slopes <- 
  secondary1a_ses_vio_updating %>% 
  map_df(function(x){
    specs <- 
      x$specifications %>% 
      select(-spec_expr) %>% 
      pivot_wider(names_from = "spec_var", values_from = "name") %>% 
      rename_with(.cols = !spec_number, ~paste0("spec_",.x))
    
    bind_cols(
      specs,
      bind_rows(
        x$ss1[[1]][[3]] %>% 
          rename_with(~c("level","beta","beta_se","beta_lo","beta_hi","t_value","p_value")) %>% 
          mutate(iv = "ses",level = ifelse(level == -1, "abs", "eco")), 
        x$ss1[[2]][[3]] %>% 
          rename_with(~c("level","beta","beta_se","beta_lo","beta_hi","t_value","p_value")) %>% 
          mutate(iv = "ses", level = ifelse(level == -1, "low", "high")),
        x$ss2[[1]][[3]] %>% 
          rename_with(~c("level","beta","beta_se","beta_lo","beta_hi","t_value","p_value")) %>% 
          mutate(iv = "vio", level = ifelse(level == -1, "abs", "eco")), 
        x$ss2[[2]][[3]] %>% 
          rename_with(~c("level","beta","beta_se","beta_lo","beta_hi","t_value","p_value")) %>% 
          mutate(iv = "vio", level = ifelse(level == -1, "low", "high")),
      )
    )
  })

=======
>>>>>>> a0940e3bd988ef96e84639d84f581ebe385b1ee1
# Save --------------------------------------------------------------------
save(
  secondary1a_effects_data,
  secondary1a_effects_medians, 
  secondary1a_effects_points, 
<<<<<<< HEAD
  secondary1a_simple_slopes,
=======
>>>>>>> a0940e3bd988ef96e84639d84f581ebe385b1ee1
  file = "multiverse-objects/3-secondary-analyses/set-1/a2-extracted-effects.Rdata"
)
