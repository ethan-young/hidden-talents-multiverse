# Primary Analyses - Covariates -------------------------------------------
si_table.01.0 <- 
  primary_effects_data %>% 
  select(spec_number,iv,dv, mod_term_group, mod_term_label, mod_term_num, mod_std_coefficient, mod_ci_high, mod_ci_low, n, mod_p.value) %>% 
  filter(mod_term_group %in% c("Covariate","Task-Type","Main Effect","Interaction")) %>% 
  mutate(mod_term_label = ifelse(mod_term_label == "Task Type", "Task Version", mod_term_label)) %>% 
  group_by(iv, dv, mod_term_label, mod_term_num, .drop = F) %>% 
  mutate(p_percent = (sum(mod_p.value < .05)/64)) %>% 
  summarize(across(where(is.numeric), median)) %>% 
  transmute(
    mod_term_num   = mod_term_num,
    mod_term_label = mod_term_label,
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
    ci             = glue::glue("[{ci_lo}, {ci_hi}]"),
    mod_term_label = fct_reorder(mod_term_label, mod_term_num)
  ) %>% 
  arrange(iv,dv,mod_term_num) %>% 
  select(
    iv, dv, mod_term_label, median_beta, ci, p_percent, median_n
  ) %>% 
  ungroup() %>% 
  pivot_wider(names_from = dv, values_from = c(median_n,median_beta,ci,p_percent)) %>% 
  select(iv, mod_term_label, ends_with("shifting"), ends_with("updating")) %>% 
  mutate(
    iv = factor(iv, c("Unpredictability","Violence", "SES"),c("Unpredictability", "Violence","Poverty")),
    iv_order = case_when(str_detect(iv, "Unp")~1, str_detect(iv, "Vio")~2, str_detect(iv,"Pov")~3),
    iv = fct_reorder(iv, iv_order),
    mod_term_label = str_replace(mod_term_label, "SES","Poverty")
  ) %>% 
  arrange(iv) %>% 
  select(-iv_order)

# SI Table 1 --------------------------------------------------------------
si_table.01.1 <- 
  si_table.01.0 %>% 
  gt(groupname_col = "iv") %>% 
  cols_label(
    mod_term_label          = "", 
    median_n_shifting       = md("*N*"),
    median_beta_shifting    = "\\Beta", 
    ci_shifting             = md("95\\% CI"),
    p_percent_shifting      = md("*p* (\\%)"),
    median_n_updating       = md("*N*"),
    median_beta_updating    = "\\Beta",  
    ci_updating             = md("95\\% CI"),
    p_percent_updating      = md("*p* (\\%)")
  ) %>% 
  cols_align(columns = "mod_term_label","left") %>% 
  tab_spanner(c("Attention Shifting"), columns = 3:6) %>% 
  tab_spanner(c("Working Memory Updating"), columns = 7:10) %>% 
  opt_table_font(font = "Palatino") %>% 
  tab_options(
    row_group.font.weight = "bold", 
    heading.align         = "left"
  )

# Secondary Analyses - Adversity Components -------------------------------
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
  group_by(iv, component, dv, mod_term_label) %>% 
  mutate(p_percent = (sum(mod_p.value < .05)/64)) %>% 
  summarize(across(where(is.numeric), median)) %>% 
  transmute(
    iv             = iv,
    component      = component,
    mod_term_label = mod_term_label,
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
    iv, component, dv, mod_term_label, median_beta, ci, p_percent, median_n
  ) %>% 
  ungroup() %>% 
  pivot_wider(names_from = dv, values_from = c(median_n,median_beta,ci,p_percent)) %>% 
  select(iv, component, mod_term_label, ends_with("shifting"), ends_with("updating"))

# SI Table 2 --------------------------------------------------------------
si_table.02.0 <- 
  secondary1_medians %>% 
  filter(!mod_term_label %in% c("Age","Test Environment","Task Version")) %>% 
  select(-component) %>% 
  mutate(
    iv = factor(iv, c("Unpredictability","Violence Exposure", "SES"),c("Unpredictability", "Violence","Poverty")),
    iv_order = case_when(str_detect(iv, "Unp")~1, str_detect(iv, "Vio")~2, str_detect(iv,"Pov")~3),
    iv = fct_reorder(iv, iv_order)
  ) %>% 
  arrange(iv) %>% 
  select(-iv_order) %>% 
  gt(groupname_col = "iv") %>% 
  cols_label(
    mod_term_label          = "", 
    median_n_shifting       = md("*N*"),
    median_beta_shifting    = "\\Beta", 
    ci_shifting             = md("95\\% CI"),
    p_percent_shifting      = md("*p* (\\%)"),
    median_n_updating       = md("*N*"),
    median_beta_updating    = "\\Beta",  
    ci_updating             = md("95\\% CI"),
    p_percent_updating      = md("*p* (\\%)")
  ) %>% 
  cols_align(columns = "mod_term_label","left") %>% 
  tab_spanner(c("Attention Shifting"), columns = 3:6) %>% 
  tab_spanner(c("Working Memory Updating"), columns = 7:10) %>% 
  opt_table_font(font = "Palatino") %>% 
  tab_options(
    row_group.font.weight = "bold", 
    heading.align         = "left"
  )

# SI Table 3 --------------------------------------------------------------
secondary1_simple_effects <- 
  secondary_set2_simple_slopes %>% 
  group_by(iv,dv,level) %>% 
  mutate(p_percent = (sum(p_value < .05)/64)) %>% 
  summarize(across(where(is.numeric), median)) %>% 
  select(iv, dv, level, beta, p_percent) %>% 
  mutate(
    iv_group  = str_extract(iv, "^(...)"),
    iv_group  = case_when(iv_group == "unp" ~ "Unp", iv_group == "vio" ~ "Vio", iv_group == "ses" ~ "SES"),
    iv_comp   = factor(iv, 
                       levels = c("unp_agg", "unp_interview","unp_perceived",
                                  "vio_agg", "vio_neighborhood","vio_fighting",
                                  "ses_agg", "ses_perceived","ses_school","ses_interview"),
                       labels = c("Composite", "Interview", "Perceived",
                                  "Composite", "Neighborhood","Fighting",
                                  "Composite", "Perceived","School","Interview")),
    dv        = ifelse(dv == "Attention-Shifting","Attention Shifting","WM Updating"),
    adversity = case_when(str_detect(iv, "ses") & level == "high" ~ "low",
                          str_detect(iv, "ses") & level == "low"  ~ "high",
                          T ~ level),
    beta      = ifelse(dv == "WM Updating", beta*100, beta),
    beta      = ifelse(str_detect(iv, "ses") & !level %in% c("low","high"), beta*-1, beta),
    beta      = formatC(round(beta,2), digits = 2, width = 3, flag = '0', format = 'f'),
    p_percent = formatC(round(p_percent*100, 2), digits = 2, width = 3, flag = '0', format = 'f') %>% paste0(.,"%"),
  ) %>% 
  select(-level) %>% 
  pivot_wider(names_from = adversity, values_from = c(beta, p_percent)) %>% 
  mutate(iv_group = str_replace(iv_group, "SES","Poverty")) %>% 
  unite(iv_group, iv_comp, col = "iv", sep = " ") %>% 
  mutate(
    iv_order = case_when(str_detect(iv,"Unp")~1, str_detect(iv,"Vio")~2, str_detect(iv,"Pov")~3),
  ) %>% 
  arrange(dv,iv_order)

si_table.03.0 <- 
  secondary1_simple_effects %>% 
  select(
    matches("(beta|p_percent)_abs"),
    matches("(beta|p_percent)_eco"),
    matches("(beta|p_percent)_low"),
    matches("(beta|p_percent)_high")
  ) %>%  
  gt(groupname_col = "dv") %>% 
  cols_label(
    iv             = "", 
    beta_abs       = md("*b* (abstract)"),
    beta_eco       = md("*b* (ecological)"),
    beta_low       = md("*b* (low)"),
    beta_high      = md("*b* (high)"),
    p_percent_abs  = md("*p* (\\%)"),
    p_percent_eco  = md("*p* (\\%)"),
    p_percent_low  = md("*p* (\\%)"),
    p_percent_high = md("*p* (\\%)")
  ) %>% 
  tab_spanner(c("Task Version"), columns = 3:6) %>% 
  tab_spanner(c("Adversity"), columns = 7:10) %>% 
  opt_table_font(font = "Palatino") %>% 
  tab_options(
    row_group.font.weight = "bold", 
    heading.align         = "left"
  )

# Secondary Analyses - Vio vs SES -----------------------------------------
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
  group_by(mod_term_label, mod_term_num, .drop = F) %>% 
  mutate(p_percent = (sum(mod_p.value < .05)/64)) %>% 
  summarize(across(where(is.numeric), median)) %>% 
  transmute(
    mod_term_num   = mod_term_num,
    mod_term_label = mod_term_label,
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
    ci             = glue::glue("[{ci_lo}, {ci_hi}]"),
    mod_term_label = fct_reorder(mod_term_label, mod_term_num)
  ) %>% 
  select(
    mod_term_label, median_beta, ci, p_percent, median_n
  ) %>% 
  ungroup() 

si_table.04.0 <- 
  secondary2_medians %>% 
  mutate(mod_term_label = str_replace(mod_term_label, "SES", "Poverty")) %>% 
  gt() %>% 
  cols_label(
    mod_term_label = "", 
    median_n       = md("*N*"),
    median_beta    = "\\Beta", 
    ci             = md("95\\% CI"),
    p_percent      = md("*p* (\\%)")
  ) %>% 
  cols_align(columns = "mod_term_label","left") %>% 
  opt_table_font(font = "Palatino") %>% 
  tab_options(
    row_group.font.weight = "bold", 
    heading.align         = "left"
  )

secondary2_simple_effects <- 
  secondary1a_simple_slopes %>% 
  group_by(iv, level) %>% 
  mutate(p_percent = (sum(p_value < .05)/64)) %>% 
  summarize(across(where(is.numeric), median)) %>% 
  select(iv, level, beta, p_percent) %>% 
  mutate(
    adversity = case_when(str_detect(iv, "ses") & level == "high" ~ "low",
                          str_detect(iv, "ses") & level == "low"  ~ "high",
                          T ~ level),
    iv        = case_when(iv == "vio" ~ "Violence", iv == "ses" ~ "Poverty"),
    beta      = beta*100, beta,
    beta      = ifelse(str_detect(iv, "SES") & !level %in% c("low","high"), beta*-1, beta),
    beta      = formatC(round(beta,2), digits = 2, width = 3, flag = '0', format = 'f'),
    p_percent = formatC(round(p_percent*100, 2), digits = 2, width = 3, flag = '0', format = 'f') %>% paste0(.,"%"),
  ) %>% 
  select(-level) %>% 
  pivot_wider(names_from = adversity, values_from = c(beta, p_percent)) %>% 
  ungroup()

si_table.05.0 <- 
  secondary2_simple_effects %>% 
  arrange(desc(iv)) %>% 
  select(
    iv,
    matches("(beta|p_percent)_abs"),
    matches("(beta|p_percent)_eco"),
    matches("(beta|p_percent)_low"),
    matches("(beta|p_percent)_high")
  ) %>%  
  gt() %>% 
  cols_label(
    iv             = "", 
    beta_abs       = md("*b* (abstract)"),
    beta_eco       = md("*b* (ecological)"),
    beta_low       = md("*b* (low)"),
    beta_high      = md("*b* (high)"),
    p_percent_abs  = md("*p* (\\%)"),
    p_percent_eco  = md("*p* (\\%)"),
    p_percent_low  = md("*p* (\\%)"),
    p_percent_high = md("*p* (\\%)")
  ) %>% 
  tab_spanner(c("Task Version"), columns = 2:6) %>% 
  tab_spanner(c("Adversity"), columns = 6:9) %>% 
  opt_table_font(font = "Palatino") %>% 
  tab_options(
    row_group.font.weight = "bold", 
    heading.align         = "left"
  )
