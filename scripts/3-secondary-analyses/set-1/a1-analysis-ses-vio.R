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

# Compare SES & Violence on Updating --------------------------------------
secondary1a_ses_vio_updating <- 
  multi_data_list %>% 
  map(function(x){
    
    spec_number <- unique(x$specifications$spec_number)
    
    # Filter data according to task
    data <- x$data_analysis %>% filter(task == "updating")
    
    # Run mixed model
    mod <- lmer(score ~ ses_agg_z*type_z + vio_agg_z*type_z + age + test_envr + (1|id) + (1|siblings_id), data = data)
    
    # Create tidied results data.frame
    mod_tidy <-
      mod %>% 
      tidy() %>% 
      rename_all(~paste0("mod_",.))
    
    # Create a tidy standardized coefficients data.frame
    mod_standardized <- standardize_parameters(mod)
    
    # Create a data.frame with predicted effects at high and low predictor value for each task type
    mod_effects1 <- ggpredict(mod, terms = c("ses_agg_z [-1,1]", "type_z [-1,1]"))
    mod_effects2 <- ggpredict(mod, terms = c("vio_agg_z [-1,1]", "type_z [-1,1]"))
    ss1_task <- sim_slopes(mod, pred = "ses_agg_z", modx = "type_z", modx.values = c(-1,1))
    ss1_ses  <- sim_slopes(mod, pred = "type_z", modx = "ses_agg_z", modx.values = c(-1,1))
    ss2_task <- sim_slopes(mod, pred = "vio_agg_z", modx = "type_z", modx.values = c(-1,1))
    ss2_vio  <- sim_slopes(mod, pred = "type_z", modx = "vio_agg_z", modx.values = c(-1,1))
    
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
        model_effects1    = mod_effects1,
        model_effects2    = mod_effects2,
        ss1               = list(task = ss1_task, ses = ss1_ses),
        ss2               = list(task = ss2_task, vio = ss2_vio)
      )
    
    message("dataset ", spec_number, " analyzed")
    results
  })

# Save results ------------------------------------------------------------
save(
  secondary1a_ses_vio_updating,
  file = "multiverse-objects/3-secondary-analyses/set-1/a1-results-ses-vio.Rdata"
)
