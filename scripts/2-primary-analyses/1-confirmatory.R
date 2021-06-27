# Setup -------------------------------------------------------------------
# Libraries
library(tidyverse)
library(lmerTest)
library(broom.mixed)
library(tidymodels)
library(ggeffects)
library(interactions)
library(effectsize)

# Data
load("multiverse-objects/1-multiverse-datasets/datalist-agg-ivs.Rdata")

# Unpredictability and Shifting -------------------------------------------
confirm_unp_shifting <- 
  multi_data_list %>% 
  map(function(x){
    
    spec_number <- unique(x$specifications$spec_number)
    
    # Filter data according to task
    data <- x$data_analysis %>% filter(task == "shifting")
    
    # Run mixed model
    mod <- lmer(score ~ unp_agg_z*type_z + age + test_envr + (1|id), data = data)
    
    # Create tidied results data.frame
    mod_tidy <-
      mod %>% 
      tidy() %>% 
      rename_all(~paste0("mod_",.))
    
    # Create a tidy standardized coefficients data.frame
    mod_standardized <- standardize_parameters(mod)
    
    # Create a data.frame with predicted effects at high and low predictor value for each task type
    mod_effects <- ggpredict(mod, terms = c("unp_agg_z [-1,1]", "type_z [-1,1]"))
    ss_task <- sim_slopes(mod, pred = "unp_agg_z", modx = "type_z", modx.values = c(-1,1))
    ss_unp  <- sim_slopes(mod, pred = "type_z", modx = "unp_agg_z", modx.values = c(-1,1))
    
    results <- 
      list(
        n                 = x$n,
        n_model           = nrow(mod@frame),
        n_model_obs       = mod@frame %>% distinct(id) %>% nrow,
        data_raw          = x$data_raw,
        data_analysis     = data,
        data_model        = mod@frame,
        specifications    = x$specifications,
        model             = mod,
        model_tidy        = mod_tidy,
        model_std_effects = mod_standardized,
        model_effects     = mod_effects,
        simple_slopes     = list(task = ss_task, unp = ss_unp)
      )
    
    message("dataset ", spec_number, " analyzed")
    results
  })

# Unpredictability and Updating -------------------------------------------
confirm_unp_updating <- 
  multi_data_list %>% 
  map(function(x){
    
    spec_number <- unique(x$specifications$spec_number)
    
    # Filter data according to task
    data <- x$data_analysis %>% filter(task == "updating")
    
    # Run mixed model
    mod <- lmer(score ~ unp_agg_z*type_z + age + test_envr + (1|id) + (1|siblings_id), data = data)
    
    # Create tidied results data.frame
    mod_tidy <-
      mod %>% 
      tidy() %>% 
      rename_all(~paste0("mod_",.))
    
    # Create a tidy standardized coefficients data.frame
    mod_standardized <- standardize_parameters(mod)
    
    # Create a data.frame with predicted effects at high and low predictor value for each task type
    mod_effects <- ggpredict(mod, terms = c("unp_agg_z [-1,1]", "type_z [-1,1]"))
    ss_task <- sim_slopes(mod, pred = "unp_agg_z", modx = "type_z", modx.values = c(-1,1))
    ss_unp  <- sim_slopes(mod, pred = "type_z", modx = "unp_agg_z", modx.values = c(-1,1))
    
    results <- 
      list(
        n                 = x$n,
        n_model           = nrow(mod@frame),
        n_model_obs       = mod@frame %>% distinct(id) %>% nrow,
        data_raw          = x$data_raw,
        data_analysis     = data,
        data_model        = mod@frame,
        specifications    = x$specifications,
        model             = mod,
        model_tidy        = mod_tidy,
        model_std_effects = mod_standardized,
        model_effects     = mod_effects,
        simple_slopes     = list(task = ss_task, unp = ss_unp)
      )
    
    message("dataset ", spec_number, " analyzed")
    results
  })

# Violence and Shifting ---------------------------------------------------
confirm_vio_shifting <- 
  multi_data_list %>% 
  map(function(x){
    
    spec_number <- unique(x$specifications$spec_number)
    
    # Filter data according to task
    data <- x$data_analysis %>% filter(task == "shifting")
    
    # Run mixed model
    mod <- lmer(score ~ vio_agg_z*type_z + age + test_envr + (1|id), data = data)
    
    # Create tidied results data.frame
    mod_tidy <-
      mod %>% 
      tidy() %>% 
      rename_all(~paste0("mod_",.))
    
    # Create a tidy standardized coefficients data.frame
    mod_standardized <- standardize_parameters(mod)
    
    # Create a data.frame with predicted effects at high and low predictor value for each task type
    mod_effects <- ggpredict(mod, terms = c("vio_agg_z [-1,1]", "type_z [-1,1]"))
    ss_task <- sim_slopes(mod, pred = "vio_agg_z", modx = "type_z", modx.values = c(-1,1))
    ss_vio  <- sim_slopes(mod, pred = "type_z", modx = "vio_agg_z", modx.values = c(-1,1))
    
    results <- 
      list(
        n                 = x$n,
        n_model           = nrow(mod@frame),
        n_model_obs       = mod@frame %>% distinct(id) %>% nrow,
        data_raw          = x$data_raw,
        data_analysis     = data,
        data_model        = mod@frame,
        specifications    = x$specifications,
        model             = mod,
        model_tidy        = mod_tidy,
        model_std_effects = mod_standardized,
        model_effects     = mod_effects,
        simple_slopes     = list(task = ss_task, vio = ss_vio)
      )
    
    message("dataset ", spec_number, " analyzed")
    results
  })

# Violence and Updating ---------------------------------------------------
confirm_vio_updating <- 
  multi_data_list %>% 
  map(function(x){
    
    spec_number <- unique(x$specifications$spec_number)
    
    # Filter data according to task
    data <- x$data_analysis %>% filter(task == "updating")
    
    # Run mixed model
    mod <- lmer(score ~ vio_agg_z*type_z + age + test_envr + (1|id) + (1|siblings_id), data = data)
    
    # Create tidied results data.frame
    mod_tidy <-
      mod %>% 
      tidy() %>% 
      rename_all(~paste0("mod_",.))
    
    # Create a tidy standardized coefficients data.frame
    mod_standardized <- standardize_parameters(mod)
    
    # Create a data.frame with predicted effects at high and low predictor value for each task type
    mod_effects <- ggpredict(mod, terms = c("vio_agg_z [-1,1]", "type_z [-1,1]"))
    ss_task <- sim_slopes(mod, pred = "vio_agg_z", modx = "type_z", modx.values = c(-1,1))
    ss_vio  <- sim_slopes(mod, pred = "type_z", modx = "vio_agg_z", modx.values = c(-1,1))
    
    results <- 
      list(
        n                 = x$n,
        n_model           = nrow(mod@frame),
        n_model_obs       = mod@frame %>% distinct(id) %>% nrow,
        data_raw          = x$data_raw,
        data_analysis     = data,
        data_model        = mod@frame,
        specifications    = x$specifications,
        model             = mod,
        model_tidy        = mod_tidy,
        model_std_effects = mod_standardized,
        model_effects     = mod_effects,
        simple_slopes     = list(task = ss_task, vio = ss_vio)
      )
    
    message("dataset ", spec_number, " analyzed")
    results
  })

# Save results ------------------------------------------------------------
save(
  confirm_unp_shifting,
  confirm_unp_updating,
  confirm_vio_shifting,
  confirm_vio_updating,
  file = "multiverse-objects/2-primary-analyses/1-confirmatory-results.Rdata"
)
