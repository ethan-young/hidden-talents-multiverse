# Simple Slope medians ----------------------------------------------------
primary_simple_effects <- 
  primary_simple_slopes %>% 
  group_by(iv,dv,level) %>% 
  mutate(p_percent = (sum(p_value < .05)/64)) %>% 
  summarize(across(where(is.numeric), median)) %>% 
  select(iv, dv, level, beta, p_percent) %>% 
  mutate(
    dv        = ifelse(dv == "Working Memory Updating","WM Updating", "Attention Shifting"),
    adversity = case_when(iv == "SES" & level == "high" ~ "low",
                          iv == "SES" & level == "low"  ~ "high",
                          T ~ level),
    #adversity = level,
    beta      = ifelse(dv == "WM Updating", beta*100, beta),
    beta      = ifelse(str_detect(iv, "SES") & !level %in% c("low","high"), beta*-1, beta),
    beta      = formatC(round(beta,2), digits = 2, width = 3, flag = '0', format = 'f'),
    p_percent = formatC(round(p_percent*100, 2), digits = 2, width = 3, flag = '0', format = 'f') %>% paste0(.,"%"),
    iv        = ifelse(iv == "SES", "Poverty", iv)
  ) %>% 
  select(-level) %>% 
  pivot_wider(names_from = adversity, values_from = c(beta, p_percent))

# Table 2 - Simple Slopes -------------------------------------------------
table.03.0 <- 
  primary_simple_effects %>% 
  select(
    matches("(beta|p_percent)_abs"),
    matches("(beta|p_percent)_eco"),
    matches("(beta|p_percent)_low"),
    matches("(beta|p_percent)_high")
  )

table.03.1 <- 
  table.03.0 %>% 
  gt(groupname_col = "dv") %>% 
  cols_label(
    iv             = "", 
    beta_abs       = md("*b* (abs)"),
    beta_eco       = md("*b* (eco)"),
    beta_low       = md("*b* (low)"),
    beta_high      = md("*b* (high)"),
    p_percent_abs  = md("*p* (\\%)"),
    p_percent_eco  = md("*p* (\\%)"),
    p_percent_low  = md("*p* (\\%)"),
    p_percent_high = md("*p* (\\%)")
  ) %>% 
  tab_spanner(c("Task Version"), columns = 3:6) %>% 
  tab_spanner(c("Adversity"), columns = 7:10) %>% 
  tab_options(
    row_group.font.weight = "bold"
  )

table.03.0_export <- 
  primary_simple_effects %>% 
  mutate(iv = factor(iv, levels =  c("Unpredictability","Violence","Poverty"))) %>% 
  arrange(dv,iv) %>% 
  mutate(iv = as.character(iv)) %>% 
  select(
    matches("(beta|p_percent)_abs"),
    matches("(beta|p_percent)_eco"),
    matches("(beta|p_percent)_low"),
    matches("(beta|p_percent)_high")
  ) %>%  
  gt(groupname_col = "dv") %>% 
  cols_label(
    iv             = "", 
    beta_abs       = md("*b* (abs)"),
    beta_eco       = md("*b* (eco)"),
    beta_low       = md("*b* (low)"),
    beta_high      = md("*b* (high)"),
    p_percent_abs  = md("*p* (\\%)"),
    p_percent_eco  = md("*p* (\\%)"),
    p_percent_low  = md("*p* (\\%)"),
    p_percent_high = md("*p* (\\%)")
  ) %>% 
  tab_spanner(c("Task Version"), columns = 3:6) %>% 
  tab_spanner(c("Adversity"), columns = 7:10) %>% 
  tab_options(
    row_group.font.weight = "bold"
  )
