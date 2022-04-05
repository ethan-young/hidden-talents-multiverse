# Setup -------------------------------------------------------------------
# Libraries
library(tidyverse)

# Load results
load("multiverse-objects/3-secondary-analyses/set-2/a1-results-expanded-shifting.Rdata")
load("multiverse-objects/3-secondary-analyses/set-2/a1-results-expanded-updating.Rdata")

# Results prep ----------------------------------------------------------
secondary_pmap <-
  list(
    ls() %>% str_subset("^secondary_expanded") %>% map(function(x) eval(as.symbol(x))),
    c("Attention-Shifting", "Working Memory Updating")
  )

# Raw effect size data ----------------------------------------------------
secondary_set2_effects <- 
  secondary_pmap %>% 
  pmap_df(function(multiverse, dv){
    # All parameters from multiverse
    params <-
      multiverse %>% 
      map_df(function(x){ 
        bind_cols(
          iv = x$iv,
          dv = dv,
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
          .fns = ~ifelse(str_detect(iv,"ses") & str_detect(mod_term,"iv"), .x * -1, .x)
        )
      ) %>% 
      mutate(
        mod_ci_low1  = ifelse(str_detect(iv,"ses") & str_detect(mod_term,"iv"), mod_ci_high, mod_ci_low),
        mod_ci_high1 = ifelse(str_detect(iv,"ses") & str_detect(mod_term,"iv"), mod_ci_low, mod_ci_high),
        mod_ci_low   = mod_ci_low1,
        mod_ci_high  = mod_ci_high1
      ) %>% 
      select(-mod_ci_low1, -mod_ci_high1)
  })

secondary_set2_effects_clean <- 
  secondary_set2_effects %>% 
  mutate(
    iv_group = case_when(str_detect(iv, "^ses") ~ "SES",
                         str_detect(iv, "^unp") ~ "Unpredictability",
                         str_detect(iv, "^vio") ~ "Violence")
  ) %>% 
  group_by(iv, dv, mod_term) %>% 
  mutate(
    spec_sub_number = 1:n(),
    spec_rank  = as.numeric(fct_reorder(as_factor(spec_number), mod_std_coefficient)),
    median_dbl = median(mod_std_coefficient),
    median_chr = median_dbl %>% round(2) %>% as.character,
    pval_prop  = (sum(mod_p.value < .05)/64)
  ) %>% 
  ungroup() %>% 
  mutate(
    mod_sig = case_when(mod_p.value <  .05 & mod_std_coefficient > 0 ~ "pos-sig",
                        mod_p.value <  .05 & mod_std_coefficient < 0 ~ "neg-sig",
                        mod_p.value >= .05 ~ "non")
  )

# Interaction Data --------------------------------------------------------
secondary_set2_effects_points <- 
  secondary_pmap %>% 
  pmap_df(function(multiverse, dv){
    map_df(multiverse, function(x){
      iv = x$iv
      spec_number = unique(x$specifications$spec_number)
      
      x$model_effects %>% 
        mutate(
          iv = iv,
          dv = dv,
          spec_number = spec_number
        )
    })
  }) %>% 
  left_join(
    secondary_set2_effects_clean %>% 
      filter(str_detect(mod_term, ":")) %>% 
      select(spec_number, spec_sub_number,iv_group,iv, dv, mod_sig),
    by = c("iv" = "iv", "dv" = "dv", "spec_number" = "spec_number")
  )

# Simple Slopes -----------------------------------------------------------
secondary_set2_simple_slopes <- 
  secondary_pmap %>% 
  pmap_df(function(multiverse, dv){
    multiverse %>% 
      map_df(function(x){
        iv = x$iv
        
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
        ) %>% 
          mutate(
            iv = iv,
            dv = dv
          )
      })
  })

# save data ---------------------------------------------------------------
save(
  secondary_set2_effects_clean,
  secondary_set2_effects_points,
  secondary_set2_simple_slopes,
  file = "multiverse-objects/3-secondary-analyses/set-2/a1-extracted-effects.Rdata"
)
