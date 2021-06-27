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
load("multiverse-objects/2-primary-analyses/4-bootstrapped-data.Rdata")

# Bootstrap Specifications Description ------------------------------------------------
## Conduct specification analyses over 500 null datasets
## The result should be 64 effect sizes * 500 null data sets
## This will be done for each iv and dv combination
## It will also be done for main effects of iv and interactions
## For example, take Unpredictability. We Should have:
## 500 bootstraps * 64 specifications * 2 DVs categories * 2 types of null effects

# Bootstrap Loop -----------------------------------
## The technique will be carried out in following steps:
### 1 Iterate over 500 bootstrapped samples
### 2 Do original specification analyses per bootstrap sample
#### 2a Set up specifications
#### 2b Create data
#### 2c Create analysis data
#### 2d Do specification analyses
### 3 Save effect sizes 
boot_effects <- 
  map2_df(
    boot_data_list,
    seq_along(boot_data_list),
    function(boot_data, boot_index){
      
      # 1 Iterate over bootstrap data sets ---------------
      ## Tell user the current bootstrap dataset
      ## Create a list of specifications and break them up per specification index
      message("Starting specificaiton analysis for bootstrapped dataset ", boot_index)
      spec_list <- split(spec_grid, spec_grid$spec_number)
      
      # 2 run specification analysis per bootstrap ---------------
      # Loop through specifications to create data and run analysis
      ## The loop takes two inputs: spec_list and an index
      ### 1. `spec_list` is the list of all specifications from above
      ### 2. `seq_along(spec_list)` generates a numeric vector from 1:64
      ## This produces one output: a data.frame of the relevant effect sizes
      spec_results <- map2_df(
        spec_list,
        seq_along(spec_list), 
        function(boot_specs, boot_spec_number){
          ## 2a meta info for specifications -----------------------------------------
          ### tell user which specification we are starting
          ### create data based on specifications
          ### Determine if residulizing will occur
          message("    bootstrap sample: ", boot_index, ", specification: ", boot_spec_number, " -- start")
          
          spec_expressions <- 
            boot_specs %>% 
            filter(spec_number == boot_spec_number) %>% 
            select(spec_var, spec_expr) %>% 
            pivot_wider(names_from = "spec_var", values_from = "spec_expr")
          
          residualize <- spec_expressions$csd == "1"
          
          ## 2b create multiverse data ---------------
          ## Take current bootstrapped data from 1st level loop
          ## Filter data using current specs from nested loop
          ## If `residulize` == TRUE, create residualized ivs, standardize, and proceed
          ## If `residulize` == FALSE, standardize ivs and proceed
          data <-
            boot_data %>% 
            filter(
              eval(parse(text = paste(spec_expressions$sub_sample))), 
              eval(parse(text = paste(spec_expressions$distractions))), 
              eval(parse(text = paste(spec_expressions$attention_check))),
              eval(parse(text = paste(spec_expressions$sped))),
              eval(parse(text = paste(spec_expressions$shifting)))
            ) %>% 
            mutate(
              mt_dataset = boot_spec_number
            ) 
          
          if(residualize){
            ### 2b.1 Residualize  ---------------
            #### Get IVs only (one row per person)
            #### Feed them to a loop to create residualized IVs
            #### Add residulized versions to the rest of the data
            #### Standardize them and put a '_z' suffix after each IV
            #### Put standardized IVs back into larger data (4 rows per person: task and type)
            data <- 
              boot_data %>% 
              select(id_boot, matches("agg$"), arb_csd) %>% 
              distinct() 
            
            data_resids <- 
              data %>% 
              select(matches("agg$")) %>% 
              names() %>% 
              map(function(z){
                resid_mod <- lm(eval(parse(text = z)) ~ arb_csd, data = data)
                resid_cols <- 
                  resid_mod %>% 
                  augment_columns(data = data) %>% 
                  rename_with(~paste0(z,"_resid"), matches("^.resid$")) %>% 
                  select(id_boot, ends_with("_resid"))
                
                resid_cols
              })
            
            data_ivs <- 
              reduce(data_resids, left_join, by = c("id_boot" = "id_boot")) %>% 
              mutate(across(.cols = ends_with("_resid"), .fns = ~as.numeric(scale(.x)), .names = "{str_remove(.col,'_resid')}_z")) %>% 
              right_join(data, by = "id_boot") %>% 
              select(-ends_with("resid"))
            
            data_analysis <- 
              full_join(
                data_ivs,
                boot_data %>% select(-contains("agg")),
                by = "id_boot"
              )
            
          } else{
            ### 2b.2 Don't residualize ---------------
            #### Get IVs only (one row per person)
            #### Standardize them and put a '_z' suffix after each IV
            #### Put standardized IVs back into larger data (4 rows per person: task and type)
            #### Let the user know the data were created
            data_ivs <- 
              boot_data %>% 
              select(id_boot, matches("agg$")) %>% 
              distinct() %>% 
              mutate(across(.cols = matches("^unp|^vio|^ses"), .fns = ~as.numeric(scale(.x)), .names = "{.col}_z")) %>% 
              select(-matches("agg$"))
            
            data_analysis <- 
              full_join(
                data_ivs,
                boot_data %>% select(-contains("agg")),
                by = "id_boot"
              )
          }
          
          ## 2c Get data ready for mixed models ---------------
          ### Select the relevant null DVs
          ### Make the centered type variable for eco vs abs: `type_z`
          ### Let the user know the data were created
          data_null_analysis <-
            data_analysis %>% 
            select(
              contains("id"), 
              age, test_envr, 
              matches("_agg_z$"),
              task, type, 
              matches(paste0("_",boot_spec_number,"$"))
            ) %>% 
            mutate(type_z = ifelse(type =="abs", -1, 1)) %>% 
            arrange(id, task, type)
          
          message("    bootstrap sample: ", boot_index, ", specification: ", boot_spec_number, " -- data created")
          
          ## 2d Mixed models ---------------
          ### In principle, these are no different than original analyses
          ### The main difference is that we are using null dvs
          ### To do this, we loop through iv, dv, and null dv combinations
          ### First, create a list with 3 elements for looping
          #### 1st contains the ivs that will be analyzed 
          #### 2nd contains the dv category
          #### 3rd contains whether the null dv with the subtracted main or interaction effect 
          mixed_mod_results <- pmap_df(
            list(
              c(rep("unp",4), rep("vio",4),rep("ses",4)),
              rep(c(rep("shifting",2),rep("updating",2)),3),
              rep(c("main","int"),6)
            ),
            function(iv, dv, null_term){
              ### 2d.1 Get the right null dv  ---------------
              #### Build a string so we can find the right null DV
              #### Use the string in a selection statement to find the null DVs we want
              #### Also select the right iv and feed it to a mixed model
              mod_dv_string <- paste0("_", iv, "_", null_term)
              mod_data <- 
                data_null_analysis %>% 
                rename_with(.cols = matches(mod_dv_string), ~c("score")) %>% 
                mutate(iv = eval(parse(text = paste0(iv,"_agg_z"))))
              
              ### 2d.2 Run the mixed models ---------------
              #### Using our current iv and null dv, run mixed models
              #### For shifting, just a random intercept for each person
              #### For updating, random intercept for each person and one for sibling pairs
              if(dv == "shifting"){
                mod <-lmer(
                  score ~ iv*type_z + age + test_envr + (1|id_boot), 
                  data = mod_data %>% filter(task == "shifting")
                )
              } else if(dv == "updating"){
                mod <-lmer(
                  score ~ iv*type_z + age + test_envr + (1|id_boot) + (1|siblings_id), 
                  data = mod_data %>% filter(task == "updating")
                )
              }
              
              ### 2d.3 Compile results---------------
              #### Create a tidied data.frame of coefficients
              #### Do the same for standardized coefficients
              #### Merge the unstandardized and standardized coefficients
              #### Add some meta data to keep things straight
              #### Let the user know that these specifications were analyzed
              mod_tidy <- 
                mod %>% 
                tidy() %>% 
                rename_all(~paste0("mod_",.)) %>% 
                select(mod_term:mod_p.value)
              
              mod_std <- 
                mod %>% 
                standardize_parameters() %>% 
                rename_with(~paste0("mod_",tolower(.x)))
              
              mod_results <- 
                left_join(mod_tidy, mod_std, by = c("mod_term" = "mod_parameter")) %>% 
                mutate(
                  boot_num  = boot_index,
                  spec_num  = boot_spec_number,
                  iv        = iv,
                  dv        = dv,
                  null_term = null_term,
                  n         = nrow(mod@frame),
                  n_id      = mod@frame %>% distinct(id_boot) %>% nrow
                ) %>% 
                select(
                  boot_num, spec_num, iv, dv, n, n_id, everything()
                ) %>% 
                arrange(boot_num, spec_num, iv, dv, n)
              
              mod_results
            })
          
          message("    bootstrap sample: ", boot_index, ", specification: ", boot_spec_number, " -- data analyzed\n")
          mixed_mod_results
        })
      # 3 add effect sizes to our giant bootstrapped effect size list  ---------------
      ## Let the user know we did it!
      ## Return `spec_result`
      message("** Bootstrap ", boot_index, " effects compiled **\n")
      spec_results
    })

# Save bootstrap effects --------------------------------------------------
save(
  boot_effects,
  file = "multiverse-objects/2-primary-analyses/5-bootstrapped-effects.Rdata"
)
