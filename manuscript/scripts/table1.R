table.01.0 <- 
  data4_multiverse_base %>% 
  select(matches("unp_"), starts_with("vio"), starts_with("ses_")) %>% 
  mutate(across(matches("ses_(interview|school|agg)"), ~ .x * -1)) %>% 
  mutate(ses_perceived = 6-ses_perceived) %>% 
  corr_table(
    numbered = T, 
    stats = c("min","median","max","range","mean","sd"),
    c.names = names(.) %>% str_replace("_"," ") %>% str_to_title() %>% str_replace("Ses","SES") %>% str_replace("Agg","Composite") %>% str_replace("Neighborhood","Neigh."),
    change = T
  ) %>% 
  mutate(Variable = str_remove(Variable, "Unp |Vio |SES "))


table.01.1 <- 
  table.01.0 %>% 
  mutate(across(.cols = 2:11, ~ifelse(str_detect(.x, "\\."), str_replace(.x, " ", "\\\\hspace\\{1 pt\\} "), .x))) %>% 
  gt(groupname_col = "stat_group") %>% 
  cols_label(Variable = " ") %>% 
  tab_spanner(c("Unpredictability"), columns = 2:4) %>% 
  tab_spanner(c("Violence"), columns = 5:7) %>% 
  tab_spanner(c("Poverty"), columns = 8:11) %>% 
  tab_style(
    style     = cell_text(weight = "bold"),
    locations = cells_body(columns = 2, rows = 2)
  ) %>%
  tab_style(
    style     = cell_text(weight = "bold"),
    locations = cells_body(columns = 2:3, rows = 3)
  ) %>%
  tab_style(
    style     = cell_text(weight = "bold"),
    locations = cells_body(columns = 5, rows = 5)
  ) %>%
  tab_style(
    style     = cell_text(weight = "bold"),
    locations = cells_body(columns = 5:6, rows = 6)
  ) %>%
  tab_style(
    style     = cell_text(weight = "bold"),
    locations = cells_body(columns = 8, rows = 8)
  ) %>%
  tab_style(
    style     = cell_text(weight = "bold"),
    locations = cells_body(columns = 8:9, rows = 9)
  ) %>%
  tab_style(
    style     = cell_text(weight = "bold"),
    locations = cells_body(columns = 8:10, rows = 10)
  ) %>%
  tab_options(
    table.font.size = "10px",
  )

table.01.1_export <- 
  data4_multiverse_base %>% 
  select(matches("unp_"), starts_with("vio"), starts_with("ses_")) %>% 
  mutate(across(matches("ses_(interview|school|agg)"), ~ .x * -1)) %>% 
  mutate(ses_perceived = 6-ses_perceived) %>% 
  corr_table(
    numbered = T, 
    stats = c("min","median","max","range","mean","sd"),
    c.names = names(.) %>% str_replace("_"," ") %>% str_to_title() %>% str_replace("Ses","SES") %>% str_replace("Agg","Composite") %>% str_replace("Neighborhood","Neigh."),
    change = T
  ) %>% 
  mutate(Variable = str_remove(Variable, "Unp |Vio |SES ")) %>% 
  gt(groupname_col = "stat_group") %>% 
  cols_label(Variable = " ") %>% 
  tab_spanner(c("Unpredictability"), columns = 2:4) %>% 
  tab_spanner(c("Violence"), columns = 5:7) %>% 
  tab_spanner(c("Poverty"), columns = 8:11) %>% 
  tab_style(
    style = cell_borders("all", color = "white"),
    locations = cells_body(columns = 1:11, rows = 2:16)
  ) %>% 
  tab_style(
    style     = cell_text(weight = "bold"),
    locations = cells_body(columns = 2, rows = 2)
  ) %>%
  tab_style(
    style     = cell_text(weight = "bold"),
    locations = cells_body(columns = 2:3, rows = 3)
  ) %>%
  tab_style(
    style     = cell_text(weight = "bold"),
    locations = cells_body(columns = 5, rows = 5)
  ) %>%
  tab_style(
    style     = cell_text(weight = "bold"),
    locations = cells_body(columns = 5:6, rows = 6)
  ) %>%
  tab_style(
    style     = cell_text(weight = "bold"),
    locations = cells_body(columns = 8, rows = 8)
  ) %>%
  tab_style(
    style     = cell_text(weight = "bold"),
    locations = cells_body(columns = 8:9, rows = 9)
  ) %>%
  tab_style(
    style     = cell_text(weight = "bold"),
    locations = cells_body(columns = 8:10, rows = 10)
  ) %>%
  tab_options(
    table.font.size = "10px",
  )
