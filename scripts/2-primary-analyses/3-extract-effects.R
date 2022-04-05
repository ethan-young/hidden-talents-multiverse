# Setup -------------------------------------------------------------------
# Libraries
library(tidyverse)

# Load results
load("multiverse-objects/2-primary-analyses/1-confirmatory-results.Rdata")
load("multiverse-objects/2-primary-analyses/2-exploratory-results.Rdata")

# Results prep ----------------------------------------------------------
primary_pmap <-
  list(
    ls() %>% str_subset("^confirm|^explore") %>% map(function(x) eval(as.symbol(x))),
    c(rep("Unpredictability",2), rep("Violence",2), rep("SES",2)),
    c(rep(c("Attention-Shifting", "Working Memory Updating"),3)),
    c(rep("Confirmatory",4), rep("Exploratory", 2))
  )

# Raw effect size data ----------------------------------------------------
primary_effects_data <- 
  primary_pmap %>% 
  pmap_df(function(multiverse, iv, dv, hypoth){
    
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
      mutate(
        # Do this to reverse code SES to match low SES to High poverty
        across(
          .cols = c(mod_estimate, mod_std.error, mod_statistic, mod_std_coefficient, mod_ci, mod_ci_low, mod_ci_high),
          .fns = ~ifelse(str_detect(mod_term,"ses"), .x * -1, .x)
        )
      ) %>% 
      mutate(
        mod_ci_low1  = ifelse(str_detect(mod_term,"ses"), mod_ci_high, mod_ci_low),
        mod_ci_high1 = ifelse(str_detect(mod_term,"ses"), mod_ci_low, mod_ci_high),
        mod_ci_low   = mod_ci_low1,
        mod_ci_high  = mod_ci_high1
      ) %>% 
      select(-mod_ci_low1, -mod_ci_high1) %>% 
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
                                   mod_term == "vio_agg_z"        ~ 2,
                                   mod_term == "unp_agg_z"        ~ 2,
                                   mod_term == "ses_agg_z"        ~ 2,
                                   str_detect(mod_term, ":")  ~ 3),
        mod_term_label = case_when(str_detect(mod_term, "Intercept") ~ "Intercept",
                                   mod_term == "age"          ~ "Age",
                                   mod_term == "test_envr"    ~ "Test Environment",
                                   mod_term == "type_z"       ~ "Task Type",
                                   mod_term == "vio_agg_z"    ~ "Violence",
                                   mod_term == "unp_agg_z"    ~ "Unpredictability",
                                   mod_term == "ses_agg_z"    ~ "SES",
                                   str_detect(mod_term, ":")  ~ "Interaction"),
        mod_term_group = factor(mod_term_num,
                                levels = c(-1,0,1,2,3), 
                                labels = c("Intercpet","Covariate","Task-Type","Main Effect", "Interaction")),
        mod_term_unique = case_when(mod_term == "vio_agg_z"        ~ "Vio",
                                    mod_term == "unp_agg_z"        ~ "Unp",
                                    mod_term == "ses_agg_z"        ~ "SES",
                                    mod_term == "vio_agg_z:type_z" ~ "Vio~symbol('\\264')~Task-Version",
                                    mod_term == "unp_agg_z:type_z" ~ "Unp~symbol('\\264')~Task-Version",
                                    mod_term == "ses_agg_z:type_z" ~ "SES~symbol('\\264')~Task-Version",
                                    T ~ mod_term_label),
        mod_term_fct   = factor(mod_term_label) %>% fct_reorder(mod_term_num),
        pval_prop      = paste0(round(pval_prop,2),"% of ps"," < .05"),
        pval_prop      = fct_reorder(pval_prop, mod_term_num),
        iv             = iv, 
        dv             = dv, 
        hypoth         = hypoth)
  })

# Medians -----------------------------------------------------------------
primary_effects_medians <- 
  primary_effects_data %>% 
  select(hypoth,iv,dv, contains("_term"), contains("median_")) %>% 
  distinct()

# Interaction Data --------------------------------------------------------
primary_effects_points <- 
  primary_pmap %>% 
  pmap_df(function(multiverse, iv, dv, hypoth){
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
        dv     = dv, 
        hypoth = hypoth
      )
  }) %>% 
  left_join(
    primary_effects_data %>% 
      filter(str_detect(mod_term_label, "Interaction")) %>% 
      select(iv, dv, hypoth, spec_number, mod_sig)
  )

# Simple Slopes -----------------------------------------------------------
primary_simple_slopes <- 
  primary_pmap %>% 
  pmap_df(function(multiverse, iv, dv, hypoth){
    multiverse %>% 
      map_df(function(x){
        specs <- 
          x$specifications %>% 
          select(-spec_expr) %>% 
          pivot_wider(names_from = "spec_var", values_from = "name") %>% 
          rename_with(.cols = !spec_number, ~paste0("spec_",.x))
        
        bind_cols(
          specs,
          bind_rows(
            x$simple_slopes[[1]][[3]] %>% 
              rename_with(~c("level","beta","beta_se","beta_lo","beta_hi","t_value","p_value")) %>% 
              mutate(level = ifelse(level == -1, "abs", "eco")), 
            x$simple_slopes[[2]][[3]] %>% 
              rename_with(~c("level","beta","beta_se","beta_lo","beta_hi","t_value","p_value")) %>% 
              mutate(level = ifelse(level == -1, "low", "high")),
            )
          )
      }) %>% 
      mutate(
        iv     = iv, 
        dv     = dv, 
        hypoth = hypoth
      )
  })

# save data ---------------------------------------------------------------
save(
  primary_effects_data,
  primary_effects_medians,
  primary_effects_points,
  primary_simple_slopes,
  file = "multiverse-objects/2-primary-analyses/3-extracted-effects.Rdata"
)
