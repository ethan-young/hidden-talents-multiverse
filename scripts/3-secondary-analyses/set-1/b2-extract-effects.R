# Setup -------------------------------------------------------------------
# Libraries
library(tidyverse)

# Load results
load("multiverse-objects/3-secondary-analyses/set-1/b1-results-ses-components.Rdata")

# Results prep ----------------------------------------------------------
secondary1b_pmap <-
  list(
    ls() %>% str_subset("^secondary1b_") %>% map(function(x) eval(as.symbol(x))),
    c("Parent SES", "Perceived SES", "School SES"),
    rep("Working Memory Updating",3)
  )

# Raw effect size data ----------------------------------------------------
secondary1b_effects_data <- 
  secondary1b_pmap %>% 
  pmap_df(function(multiverse, iv, dv){
    
    # All parameters from multiverse
    params <-
      multiverse %>% 
      map_df(function(x){ 
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
                                   mod_term == "ses_perceived_z" ~ 2,
                                   mod_term == "ses_interview_z" ~ 2,
                                   mod_term == "ses_school_z"    ~ 2,
                                   str_detect(mod_term, ":")     ~ 3),
        mod_term_label = case_when(str_detect(mod_term, "Intercept") ~ "Intercept",
                                   mod_term == "age"             ~ "Age",
                                   mod_term == "test_envr"       ~ "Test Environment",
                                   mod_term == "type_z"          ~ "Task Type",
                                   mod_term == "ses_perceived_z" ~ "Perceived SES",
                                   mod_term == "ses_interview_z" ~ "Parent SES",
                                   mod_term == "ses_school_z"    ~ "School SES",
                                   str_detect(mod_term, ":")     ~ "Interaction"),
        mod_term_group = factor(mod_term_num,
                                levels = c(-1,0,1,2,3), 
                                labels = c("Intercpet","Covariate","Task-Type","Main Effect", "Interaction")),
        mod_term_fct   = factor(mod_term_label) %>% fct_reorder(mod_term_num),
        pval_prop      = paste0(round(pval_prop,2),"% of ps"," < .05"),
        pval_prop      = fct_reorder(pval_prop, mod_term_num),
        iv             = iv, 
        dv             = dv
      )
  })

# Medians -----------------------------------------------------------------
secondary1b_effects_medians <- 
  secondary1b_effects_data %>% 
  select(iv,dv, contains("_term"), contains("median_")) %>% 
  distinct()

# Interaction Data --------------------------------------------------------
secondary1b_effects_points <- 
  secondary1b_pmap %>% 
  pmap_df(function(multiverse, iv, dv){
    multiverse %>% 
      map_df(function(x){
        specs <- x$specifications %>% 
          select(-spec_expr) %>% 
          pivot_wider(names_from = "spec_var", values_from = "name") %>% 
          rename_with(.cols = !spec_number, ~paste0("spec_",.x))
        
        bind_cols(x$model_effects, n = x$n, specs) %>% tibble()
      }) %>% 
      mutate(
        iv     = iv, 
        dv     = dv
      )
  }) %>% 
  left_join(
    secondary1b_effects_data %>% 
      filter(str_detect(mod_term_label, "Interaction")) %>% 
      select(iv, dv, spec_number, mod_sig)
  )

# save data ---------------------------------------------------------------
save(
  secondary1b_effects_data,
  secondary1b_effects_medians,
  secondary1b_effects_points,
  file = "multiverse-objects/3-secondary-analyses/set-1/b2-extracted-effects.Rdata"
)
