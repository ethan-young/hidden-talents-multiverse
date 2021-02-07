# Setup -------------------------------------------------------------------

# Libraries
library(tidyverse)
library(tidymodels)

# Data
load("data/data2_analysis.Rdata")

# Specification Grid -----------------------------------------------------------
## Create a grid of all possible combinations of arbitrary data processing decisions
## First, `expand_grid` creates all possible combinations from arbitrary variables
## There are 6 variables each with two alternatives
## For our expanded multiverse, we are adding IV subcomponent to our grid
### 2*2*2*2*2*2 = 64 unique specifications
### 64 * 3 = 192 specs for unpredictability
### 64 * 3 = 192 specs for violence
### 64 * 4 = 256 specs for SES
### We'll keep them all in one data list of 192+192+256 = 640 datasest
spec_grid <- 
  expand_grid(
    iv              = c(0:9),
    sub_sample      = c(0,1),
    distractions    = c(0,1),
    attention_check = c(0,1),
    sped            = c(0,1),
    csd             = c(0,1),
    shifting        = c(0,1)
  ) %>% 
  rownames_to_column("spec_number") %>% 
  mutate(spec_number = as.numeric(spec_number)) %>% 
  pivot_longer(!spec_number, names_to = "spec_var", values_to = "spec_value") %>% 
  left_join(
    tribble(
      ~spec_var,         ~spec_value, ~spec_expr,                                              ~name,
      "sub_sample",      0,           "arb_sample %in% c('wjms','bgc')",                       "Both Samples",
      "sub_sample",      1,           "arb_sample == 'wjms'",                                  "Middle School Only",
      "distractions",    0,           "arb_distractions %in% c(1,0)",                          "Minor Distract. Included",
      "distractions",    1,           "arb_distractions == 0",                                 "Minor Distract. Excluded",
      "attention_check", 0,           "arb_attention_check <= 1 | is.na(arb_attention_check)", "1 >= missed",
      "attention_check", 1,           "arb_attention_check == 0 | is.na(arb_attention_check)", "None missed",
      "sped",            0,           "arb_sped %in% c(1,0) | is.na(arb_sped)",                "Sp.Ed. Included",
      "sped",            1,           "arb_sped == 0 | is.na(arb_sped)",                       "Sp.Ed. Excluded",
      "csd",             0,           "0",                                                     "Not Included",
      "csd",             1,           "1",                                                     "Residualized",
      "shifting",        0,           "(arb_abs_shift/32) > 0 & (arb_eco_shift/32) > 0",       "Include Acc. < 65%",
      "shifting",        1,           "(arb_abs_shift/32) > .65 & (arb_eco_shift/32) > .65",   "Exclude Acc. < 65%",
      "iv",              0,           "unp_agg",                                               "Unp Composite",
      "iv",              1,           "unp_interview",                                         "Unp Perceived",
      "iv",              2,           "unp_perceived",                                         "Unp Interview",
      "iv",              3,           "vio_agg",                                               "Vio Composite",
      "iv",              4,           "vio_neighborhood",                                      "Vio Neighborhood",
      "iv",              5,           "vio_fighting",                                          "Vio Fighting",
      "iv",              6,           "ses_agg",                                               "SES Composite",
      "iv",              7,           "ses_perceived",                                         "SES Perceived",
      "iv",              8,           "ses_school",                                            "SES School",
      "iv",              9,           "ses_interview",                                         "SES Parents"
    ),
    by = c("spec_var", "spec_value")
  )

# Multiverse dataset list -----------------------------------------------------
## This loop applies specifications from the grid from above to the data
## We proceed in 3 steps
### 1. Split the grid by specification
### 2. Apply the expression associated with the specifications for each variable to the data
### 3. For residualizing, check the current specs
#### 3a. If TRUE, residualize the IVs by taking out the shared variance with arb_csd from IV and then standardize
#### 3b. If FALSE, do not residualize and simply standardize IVs
### 4. Arrange the data in long form for mixed-models
### 5. Let the user know the data were created and return a list of the data in long and wide form, the specs, and the n
multi_data_list <-
  # 1
  spec_grid %>% 
  split(.$spec_number) %>% 
  map(function(x){
    spec_number <- unique(x$spec_number)
    spec_expressions <- 
      x %>% 
      select(spec_var, spec_expr) %>% 
      pivot_wider(names_from = "spec_var", values_from = "spec_expr")
    
    spec_iv <- spec_expressions$iv
    residualize <- spec_expressions$csd == "1"
    
    # 2
    data <-
      data4_multiverse_base %>% 
      filter(
        eval(parse(text = paste(spec_expressions$sub_sample))), 
        eval(parse(text = paste(spec_expressions$distractions))), 
        eval(parse(text = paste(spec_expressions$attention_check))),
        eval(parse(text = paste(spec_expressions$sped))),
        eval(parse(text = paste(spec_expressions$shifting)))
      ) %>% 
      mutate(
        mt_dataset = spec_number
      ) 
    
    # 3
    if(residualize){
      # 3a
      data <- 
        data %>% 
        select(matches("^unp|^vio|^ses")) %>% 
        names() %>% 
        map(function(z){
          resid_mod <- lm(eval(parse(text = z)) ~ arb_csd, data = data)
          
          augment_columns(resid_mod, data = data) %>% 
            rename_with(~paste0(z,"_resid"), matches("^.resid$")) %>% 
            select(id, ends_with("_resid"))
        }) %>% 
        reduce(left_join, by = c("id" = "id")) %>% 
        mutate(across(.cols = ends_with("_resid"), .fns = ~as.numeric(scale(.x)), .names = "{str_remove(.col,'_resid')}_z")) %>% 
        right_join(data)
    } else{
      # 3b
      data <- 
        data %>% 
        mutate(across(.cols = matches("^unp|^vio|^ses"), .fns = ~as.numeric(scale(.x)), .names = "{.col}_z"))
    }
    
    # 4
    data_long <- 
      data %>% 
      gather(task_type, score, matches("^abs_|^eco_")) %>% 
      separate(task_type, c("type", "task"), "_") %>% 
      mutate(type_z = ifelse(type =="abs", -1, 1)) %>% 
      arrange(id, task, type)
    
    results <- list(
      iv             = spec_iv,
      n              = nrow(data),
      data_raw       = data,
      data_analysis  = data_long, 
      specifications = x %>% select(-spec_value)
    )
    
    # 5
    message("dataset ", spec_number, " created, iv = ", paste0(spec_iv,"_z"), ", n = ", results$n)
    results
  })

# Save environment --------------------------------------------------------
save.image(file = "multiverse-objects/1-multiverse-datasets/datalist-all-ivs.Rdata")
