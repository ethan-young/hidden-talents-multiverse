# Bootstrapped medians ----------------------------------------------------
boot_medians <- 
  boot_effects %>% 
  filter((null_term == "main" & mod_term == "iv") | (null_term == "int" & mod_term == "iv:type_z")) %>% 
  rename(term = mod_term) %>% 
  mutate(
    across(
      .cols = c(mod_estimate, mod_std.error, mod_statistic, mod_std_coefficient, mod_ci, mod_ci_low, mod_ci_high),
      .fns = ~ifelse(str_detect(iv,"ses"), .x * -1, .x)
    )
  ) %>%
  group_by(boot_num, iv, dv, null_term) %>% 
  summarize(median_null = median(mod_std_coefficient))

# Primary Analysis Medians ------------------------------------------------
primary_medians <- 
  primary_effects_data %>% 
  select(spec_number,iv,dv, mod_term_group, mod_std_coefficient, mod_ci_high, mod_ci_low, n, mod_p.value) %>% 
  filter(mod_term_group %in% c("Main Effect","Interaction")) %>% 
  group_by(iv, dv, mod_term_group) %>% 
  mutate(p_percent = (sum(mod_p.value < .05)/n())) %>% 
  summarize(across(where(is.numeric), median)) %>% 
  rename(null_term = mod_term_group) %>% 
  transmute(
    iv          = case_when(iv == "Unpredictability" ~ "unp", iv == "Violence" ~ "vio", iv == "SES" ~ "ses"),
    dv          = ifelse(dv == "Attention-Shifting","shifting","updating"),
    null_term   = ifelse(null_term == "Main Effect", "main", "int"),
    median_beta = mod_std_coefficient,
    median_lo   = mod_ci_low,
    median_hi   = mod_ci_high,
    median_n    = n,
    p_percent   = p_percent
  )

# Table - Base ------------------------------------------------------------
table.02.0 <- 
  left_join(boot_medians, primary_medians, by = c("iv","dv", "null_term")) %>% 
  arrange(dv, iv, boot_num) %>% 
  group_by(iv, dv, null_term) %>% 
  mutate(
    is_sig = if_else(median_beta < 0, median_null < median_beta, median_null > median_beta)
  ) %>% 
  summarize(
    p_overall   = sum(is_sig)/n(),
    p_percent   = unique(p_percent),
    median_beta = unique(median_beta),
    median_lo   = unique(median_lo),
    median_hi   = unique(median_hi),
    median_n    = unique(median_n)
  ) %>% 
  arrange(dv, iv, desc(null_term)) %>% 
  mutate(
    median_beta = formatC(round(median_beta,2), digits = 2, width = 3, flag = '0', format = 'f'),
    median_n    = formatC(round(median_n), digits = 0, format = 'f'),
    p_percent   = formatC(round(p_percent*100, 2), digits = 2, width = 3, flag = '0', format = 'f') %>% paste0(.,"%"),
    p_overall   = formatC(round(p_overall,3), digits = 3, width = 4, flag = '0', format = 'f'),
    ci_lo          = formatC(round(median_lo,2), digits = 2, width = 3, flag = '0', format = 'f'),
    ci_hi          = formatC(round(median_hi,2), digits = 2, width = 3, flag = '0', format = 'f'),
    ci             = glue::glue("[{ci_lo}, {ci_hi}]")
  ) %>% 
  select(iv,dv,null_term,p_overall, p_percent, median_beta, ci, median_n) %>% 
  pivot_wider(names_from = null_term, values_from = c(p_overall, p_percent, median_beta, ci, median_n)) %>% 
  mutate(
    dv          = ifelse(dv == "shifting", "Attention Shifting","WM Updating"),
    iv          = case_when(iv == "ses" ~ "Poverty",
                            iv == "unp" ~ "Unpredictability",
                            iv == "vio" ~ "Violence")
  ) %>% 
  select(
    iv,dv, 
    matches("(beta|ci)_main"), p_percent_main, p_overall_main, 
    matches("(beta|ci)_int"), p_percent_int, p_overall_int
  )

# Table 2 - Mixed Models --------------------------------------------------
table.02.1 <- 
  table.02.0 %>% 
  gt(groupname_col = "dv") %>% 
  cols_label(
    iv = "", 
    median_beta_main = "\\Beta", 
    ci_main          = md("95\\% CI"),
    p_percent_main   = md("*p* (\\%)"),
    p_overall_main   = md("*p*"), 
    median_beta_int  = "\\Beta", 
    ci_int           = md("95\\% CI"),
    p_percent_int    = md("*p* (\\%)"),
    p_overall_int    = md("*p*")
  ) %>% 
  tab_spanner(c("Main Effect"), columns = 3:6) %>% 
  tab_spanner(c("Interaction"), columns = 7:10) %>% 
  tab_options(
    row_group.font.weight = "bold"
  )

table.02.1_export <- 
  table.02.0 %>% 
  mutate(iv = factor(iv, levels =  c("Unpredictability","Violence","Poverty"))) %>% 
  arrange(dv,iv) %>% 
  mutate(iv = as.character(iv)) %>% 
  gt(groupname_col = "dv") %>% 
  cols_label(
    iv = "", 
    median_beta_main = "&Beta;", 
    ci_main          = md("95% CI"),
    p_percent_main   = md("*p* (%)"),
    p_overall_main   = md("*p*"), 
    median_beta_int  = "&Beta;", 
    ci_int           = md("95% CI"),
    p_percent_int    = md("*p* (%)"),
    p_overall_int    = md("*p*")
  ) %>% 
  tab_style(
    style = cell_borders("all",weight = "0px"),
    locations = cells_body(columns = 1:10, rows = 1:6)
  ) %>% 
  tab_spanner(c("Main Effect"), columns = 3:6) %>% 
  tab_spanner(c("Interaction"), columns = 7:10) %>% 
  tab_options(
    row_group.font.weight = "bold"
  )
