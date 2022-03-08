# Packages ----------------------------------------------------------------
library(tidyverse)
library(cowplot)
library(see)
library(gt)
library(psych)
library(lme4)
library(performance)

# ggplot2 theme -----------------------------------------------------------
theme_set(
  theme_bw() +
    theme(
      axis.line.y       = element_line(),
      axis.text.y       = element_text(size = rel(.75)),
      axis.title.y      = element_text(size = rel(.80), margin = margin(1,0,0,0,"lines")),
      axis.ticks.y      = element_line(),
      axis.line.x       = element_blank(),
      axis.text.x       = element_blank(),
      axis.ticks.x      = element_blank(),
      axis.title.x      = element_blank(),
      panel.border      = element_blank(), 
      panel.spacing.y   = unit(0.5, "lines"),
      plot.margin       = margin(.25,.25,.25,.25,"lines"),
      plot.background   = element_rect(color = NA),
      plot.title        = element_text(size = rel(.85), hjust = 0, margin = margin(0,0,.5,0, "lines")),
      plot.subtitle     = element_blank(),
      panel.grid        = element_line(color = NA),
      strip.background  = element_blank(), 
      strip.placement   = "outside",
      strip.text        = element_text(size = rel(.85), angle = 0)
    )
)

pval_colors <- c("pos-sig" = "#006D77", "non" = "gray70")
pval_colors_bw <- c("pos-sig" = "black", "non" = "gray70")
my_alphas <- c(.5, 1)
my_limits <- c(1,70)

# Objects -----------------------------------------------------------------
load("multiverse-objects/1-multiverse-datasets/datalist-agg-ivs.Rdata")
load("data/data1_raw.Rdata")
load("data/data2_analysis.Rdata")
load("multiverse-objects/2-primary-analyses/3-extracted-effects.Rdata")
load("multiverse-objects/2-primary-analyses/5-bootstrapped-effects.Rdata")
load("multiverse-objects/3-secondary-analyses/set-2/a1-extracted-effects.Rdata")
load("multiverse-objects/3-secondary-analyses/set-1/a2-extracted-effects.Rdata")

# Tables -----------------------------------------------------------------
source("manuscript/scripts/0-corr_table.R")
source("manuscript/scripts/table1.R")
source("manuscript/scripts/table2.R")
source("manuscript/scripts/table3.R")

# Figures -----------------------------------------------------------------
source("manuscript/scripts/figure-2-3.R")
source("manuscript/scripts/figure-2-3-bw.R")

# In-text statistics ------------------------------------------------------
## sample break downs ----
txt1_sam <-
  map(list("raw" = data1_raw, "non_arb" = data2_non_arbitrary), function(data){
    list(
      n = list(
        total = nrow(data),
        wjms  = data %>% filter(sample_code == "wjms") %>% nrow(),
        bgc   = data %>% filter(sample_code == "bgc") %>% nrow()
      ),
      age = list(
        mean = data %>% pull(age) %>% mean(na.rm = T) %>% round(2),
        sd   = data %>% pull(age) %>% sd(na.rm = T) %>% round(2),
        bgc  = list(
          mean = data %>% filter(sample_code == "bgc") %>% pull(age) %>% mean(na.rm = T),
          sd   = data %>% filter(sample_code == "bgc") %>% pull(age) %>% sd(na.rm = T)
        ) %>% map(round,digits = 2),
        wjms = list(
          mean = data %>% filter(sample_code == "wjms") %>% pull(age) %>% mean(na.rm = T),
          sd   = data %>% filter(sample_code == "wjms") %>% pull(age) %>% sd(na.rm = T)
        ) %>% map(round,digits = 2)
      ),
      sex = list(
        males   = data %>% filter(sex == 1) %>% nrow(),
        females = data %>% filter(sex == 2) %>% nrow(),
        bgc = list(
          males   = data %>% filter(sample_code == "bgc", sex == 1) %>% nrow(),
          females = data %>% filter(sample_code == "bgc", sex == 2) %>% nrow()
        ),
        wjms = list(
          males   = data %>% filter(sample_code == "wjms", sex == 1) %>% nrow(),
          females = data %>% filter(sample_code == "wjms", sex == 2) %>% nrow()
        )
      ),
      free_lunch = list(
        n    = data %>% pull(ses_school_freelunch) %>% sum(na.rm=T),
        bgc  = data %>% filter(sample_code == "bgc") %>% pull(ses_school_freelunch) %>% sum(na.rm=T),
        wjms = data %>% filter(sample_code == "wjms") %>% pull(ses_school_freelunch) %>% sum(na.rm=T)
      ),
      race = list(
        non_white = data %>% filter(race != 4) %>% nrow(),
        hispanic  = data %>% filter(hispanic == 1) %>% nrow()
      )
    )
  }) 

## DVs ----
txt2_dvs <- 
  data2_non_arbitrary %>% 
  summarize(across(.cols = matches("shifting|updating"), list(mean = mean, sd = sd), na.rm=T, .names = "{.fn}.{.col}")) %>% 
  mutate(across(everything(), ~round(.x, 2))) %>% 
  pivot_longer(everything()) %>% 
  separate(name, into = c("stat","var"), sep = "\\.") %>% 
  pivot_wider(names_from = var, values_from = c(value)) %>% 
  select(-stat) %>% 
  map(function(x) list(mean = x[1], sd = x[2]))

## IVs ----
txt3_ivs <- 
  data2_non_arbitrary %>% 
  mutate(across(matches("ses_(interview|school|agg)"), ~ .x * -1)) %>% 
  mutate(ses_perceived = 6-ses_perceived) %>% 
  summarize(
    across(
      .cols = matches("(unp|ses)_perceived$|vio_neighborhood$|vio_fighting$|unp_interview|ses_interview|csd$|test_envr$"), 
      list(mean = mean, sd = sd), na.rm=T, .names = "{.fn}.{.col}")
  ) %>% 
  mutate(across(contains("mean.ses_int"), ~ .x * -1)) %>% 
  mutate(across(everything(), ~round(.x, 2))) %>% 
  pivot_longer(everything()) %>% 
  separate(name, into = c("stat","var"), sep = "\\.") %>% 
  pivot_wider(names_from = var, values_from = c(value)) %>% 
  select(-stat) %>% 
  map(function(x) list(mean = x[1], sd = x[2]))

## Reliabilities ----
txt4_rel <- 
  list(
    unp = alpha(data2_non_arbitrary %>% select(matches("unp_perceived\\d")), keys = c(-1,1,1,1,1,1))$total$raw_alpha,
    vio = alpha(data2_non_arbitrary %>% select(matches("vio_neighborhood\\d")), keys = c(-1,1,-1,1,1,1,1))$total$raw_alpha,
    ses = alpha(data2_non_arbitrary %>% select(matches("ses_perceived\\d")), keys = c(1,1,1,1,1,1,-1))$total$raw_alpha,
    csd = alpha(data2_non_arbitrary %>% select(matches("csd\\d|csd\\d\\d")), keys = c(-1,1,-1,-1,1,-1,1,-1,-1,-1,-1,1,-1,-1))$total$raw_alpha,
    unp_int = alpha(data3_composites %>% select(unp_interview_disrupted, unp_interview_figures, unp_interview_moves) %>% scale())$total$raw_alpha
  ) %>% 
  map(round,2)

## Correlations ----
txt5_cor <- 
  map(
    c(
      "sc$", 
      "updating$",
      "^unp_(perceived|interview)$",
      "^vio_(neighborhood|fighting)$",
      "csd$|vio_agg","csd$|unp_agg", 
      "csd$|ses_agg",
      "^vio_agg|^ses_agg",
      "ses_interview_edu|ses_interview_occup"
    ), 
    function(x){
      corrs <- 
        data3_composites %>% 
        select(matches(x)) %>% 
        corr.test()
      
      if(is.matrix(corrs$n)){
        n <- corrs$n[1,2]
      }else{
        n <- corrs$n
      }
      
      print(corrs$r)
      
      list(r = corrs$r[1,2] %>% round(2), n = n)
    }) %>% 
  set_names(c("shifting","updating","unp","vio","csd_vio","csd_unp","csd_ses","ses_vio","edu_int")) 

## Siblings ----
txt6_sib <- 
  list(
    n = data2_non_arbitrary %>% 
      filter(siblings_id != "sibling_000") %>%
      summarize(n = n()) %>% pull(n),
    families = data2_non_arbitrary %>% 
      filter(siblings_id != "sibling_000") %>% 
      group_by(siblings_id) %>% 
      summarize(n = n()) %>% 
      nrow(),
    sizes = data2_non_arbitrary %>% 
      filter(siblings_id != "sibling_000") %>% 
      group_by(siblings_id) %>% 
      summarize(n = n()) %>% 
      group_by(n) %>% 
      summarize(size = n()) %>% 
      pivot_wider(names_from = n, values_from = size) %>% 
      as.list() %>% 
      set_names(c("two","three","four")),
    iccs =
      map2(rep("updating",2), rep(c("abs","eco"),1), function(x,y){
        data <- 
          data4_multiverse_base %>% 
          pivot_longer(cols = matches("^abs_|^eco_"), names_to = "task_type", values_to = "score") %>% 
          separate(task_type, c("type", "task"), "_", extra = "drop") %>% 
          arrange(id, task, type) %>% 
          filter(task == x, type == y)
        
        icc_mod <- icc(lmer(score ~ 1 + (1|siblings_id), data = data))
        
        list(iccs = icc_mod$ICC_adjusted %>% round(2))
      }) %>% 
      set_names("abs_update","eco_update")
  )

## Primary Effects ----
mod_terms1 <- 
  primary_effects_data %>% 
  select(spec_number, iv, dv, mod_term, mod_std_coefficient, mod_ci_high, mod_ci_low, n, mod_p.value) %>% 
  filter(mod_term %in% c("age", "test_envr", "type_z")) %>% 
  group_by(iv, dv, mod_term) %>% 
  mutate(p_percent = (sum(mod_p.value < .05)/n())) %>% 
  summarize(across(where(is.numeric), median)) %>% 
  transmute(
    iv          = case_when(iv == "Unpredictability" ~ "unp", iv == "Violence" ~ "vio", iv == "SES" ~ "ses"),
    dv          = ifelse(dv == "Attention-Shifting","shifting","updating"),
    term        = mod_term,
    median_beta = mod_std_coefficient %>% round(2),
    median_lo   = mod_ci_low,
    median_hi   = mod_ci_high,
    median_n    = n,
    p_percent   = p_percent
  ) %>% 
  split(.$dv~ .$iv + .$term)

mod_terms2 <- 
  table.02.0 %>% 
  mutate(
    iv = case_when(iv == "Unpredictability" ~ "unp", iv == "Violence" ~ "vio", iv == "Poverty" ~ "ses"),
    dv = ifelse(dv == "Attention Shifting","shifting","updating")
  ) %>% 
  split(.$dv~ .$iv)

## Simple Effects ----
simple_effects <- 
  table.03.0 %>% 
  mutate(
    iv = case_when(iv == "Unpredictability" ~ "unp", iv == "Violence" ~ "vio", iv == "Poverty" ~ "ses"),
    dv = ifelse(dv == "Attention Shifting","shifting","updating")
  ) %>% 
  split(.$dv~ .$iv)

## Secondary - Set 1 ----
secondary1_medians <- 
  secondary_set2_effects_clean %>% 
  select(spec_number,spec_iv,dv, mod_term, mod_std_coefficient, mod_ci_high, mod_ci_low, n, mod_p.value) %>% 
  filter(!str_detect(mod_term, "\\Intercept\\)")) %>% 
  separate(spec_iv, into = c("iv","component"), sep = " ", remove = F) %>% 
  mutate(
    iv             = case_when(iv == "Unp" ~ "Unpredictability", iv=="Vio" ~ "Violence Exposure", iv == "SES" ~ "SES"),
    mod_term_label = case_when(mod_term == "iv"~ component, 
                               mod_term == "age" ~ "Age", 
                               mod_term == "type_z" ~ "Task Version",
                               mod_term == "test_envr" ~ "Test Environment",
                               mod_term == "iv:type_z" ~ paste(component, "$\\times$", "Task Version")),
    mod_term_label = ifelse(mod_term_label == "Parents", "Interview", mod_term_label),
    mod_term_num   = case_when(mod_term == "age" ~ 1,
                               mod_term == "test_envr" ~ 2,
                               mod_term == "type_z" ~ 3,
                               mod_term == "iv" ~ 4,
                               str_detect(mod_term, ":") ~ 5),
    mod_term_label = fct_reorder(mod_term_label, mod_term_num)
  ) %>% 
  group_by(iv, component, dv, mod_term) %>% 
  mutate(p_percent = (sum(mod_p.value < .05)/64)) %>% 
  summarize(across(where(is.numeric), median)) %>% 
  transmute(
    iv             = iv,
    component      = component,
    mod_term       = mod_term,
    median_beta    = mod_std_coefficient,
    median_lo      = mod_ci_low,
    median_hi      = mod_ci_high,
    median_n       = n,
    p_percent      = p_percent
  ) %>% 
  mutate(
    dv             = ifelse(dv == "Attention-Shifting","shifting","updating"),
    median_beta    = formatC(round(median_beta,2), digits = 2, width = 3, flag = '0', format = 'f'),
    median_n       = formatC(round(median_n), digits = 0, format = 'f'),
    p_percent      = formatC(round(p_percent*100, 2), digits = 2, width = 3, flag = '0', format = 'f') %>% paste0(.,"%"),
    ci_lo          = formatC(round(median_lo,2), digits = 2, width = 3, flag = '0', format = 'f'),
    ci_hi          = formatC(round(median_hi,2), digits = 2, width = 3, flag = '0', format = 'f'),
    ci             = glue::glue("[{ci_lo}, {ci_hi}]")
  ) %>% 
  select(
    iv, component, dv, mod_term, median_beta, ci, p_percent, median_n
  ) %>% 
  mutate(iv = case_when(iv == "Unpredictability" ~ "unp", iv == "Violence Exposure" ~ "vio", iv == "SES" ~ "ses"),
         mod_term = str_replace(mod_term,":","_")) %>% 
  ungroup() %>% 
  split(.$dv~.$iv+.$component+.$mod_term)

## Secondary - Set 2 ----
secondary2_medians <- 
  secondary1a_effects_data %>% 
  select(spec_number,dv, mod_term, mod_std_coefficient, mod_ci_high, mod_ci_low, n, mod_p.value) %>% 
  filter(!str_detect(mod_term, "\\Intercept\\)")) %>% 
  mutate(
    mod_term_label = case_when(mod_term == "ses_agg_z" ~ "SES", 
                               mod_term == "vio_agg_z" ~ "Violence",
                               mod_term == "age" ~ "Age", 
                               mod_term == "type_z" ~ "Task Version",
                               mod_term == "test_envr" ~ "Test Environment",
                               mod_term == "ses_agg_z:type_z" ~"SES $\\times$ Task Version",
                               mod_term == "type_z:vio_agg_z"~ "Violence $\\times$ Task Version"),
    mod_term_label = ifelse(mod_term_label == "Parents", "Interview", mod_term_label),
    mod_term_num   = case_when(mod_term == "age" ~ 1,
                               mod_term == "test_envr" ~ 2,
                               mod_term == "type_z" ~ 3,
                               mod_term == "ses_agg_z" ~ 4,
                               mod_term == "vio_agg_z" ~ 5,
                               str_detect(mod_term, ":") ~ 6),
    mod_term_label = fct_reorder(mod_term_label, mod_term_num)
  ) %>% 
  group_by(mod_term, .drop = F) %>% 
  mutate(p_percent = (sum(mod_p.value < .05)/64)) %>% 
  summarize(across(where(is.numeric), median)) %>% 
  transmute(
    mod_term       = mod_term %>% str_replace(":","_"),
    median_beta    = mod_std_coefficient,
    median_lo      = mod_ci_low,
    median_hi      = mod_ci_high,
    median_n       = n,
    p_percent      = p_percent
  ) %>% 
  mutate(
    median_beta    = formatC(round(median_beta,2), digits = 2, width = 3, flag = '0', format = 'f'),
    median_n       = formatC(round(median_n), digits = 0, format = 'f'),
    p_percent      = formatC(round(p_percent*100, 2), digits = 2, width = 3, flag = '0', format = 'f') %>% paste0(.,"%"),
    ci_lo          = formatC(round(median_lo,2), digits = 2, width = 3, flag = '0', format = 'f'),
    ci_hi          = formatC(round(median_hi,2), digits = 2, width = 3, flag = '0', format = 'f'),
    ci             = glue::glue("[{ci_lo}, {ci_hi}]")
  ) %>% 
  select(
    mod_term, median_beta, ci, p_percent, median_n
  ) %>% 
  ungroup() %>% 
  split(.$mod_term)

# Save the entire image ---------------------------------------------------
save(
  data1_raw,
  data2_non_arbitrary,
  data3_composites,
  multi_data_list,
  txt1_sam,
  txt2_dvs,
  txt3_ivs,
  txt4_rel,
  txt5_cor,
  txt6_sib,
  table.01.0,
  table.02.0,
  table.03.0,
  fig2,
  fig3,
  mod_terms1,
  mod_terms2,
  simple_effects,
  secondary1_medians,
  secondary2_medians,
  file = "manuscript/staged-objects.Rdata"
)

# save black and white figures --------------------------------------------
ggsave(filename = "manuscript/figures/figure2-1-bw.pdf", fig2_bw, width = 6.5, height = 7.25, dpi = 600)
ggsave(filename = "manuscript/figures/figure3-1-bw.pdf", fig3_bw, width = 6.5, height = 7.25, dpi = 600)
