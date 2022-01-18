si_table.06.0 <- 
  data2_non_arbitrary %>% 
  select(matches("unp_interview"), unp_perceived) %>% 
  corr_table(
    c.names = c("Family Disruption (interview)", "Parental Transitions (interview)", "Residential Moves (interview)", "Perceived (self-report"),
    numbered = T,
    stats = c("min", "median", "max", "range", "mean", "sd")
  ) %>% 
    add_row(Variable = "Possible Range", `1` = "0-3", `2` = "-", `3` = "-", `4` = "1-5")

si_table.07.0 <- 
  data2_non_arbitrary %>% 
  select(matches("vio_fighting\\d"), vio_neighborhood) %>% 
  corr_table(
    c.names = c("Witnessing Fights", "Involvement in Fights", "Perceived Neighborhood Violence"),
    numbered = T,
    stats = c("min", "median", "max", "range", "mean", "sd")
  ) %>% 
  add_row(Variable = "Possible Range", `1` = "0-8", `2` = "0-8", `3` = "1-5")

si_table.08.0 <- 
  data3_composites %>%
  select(matches("ses_(interview)_"), ses_school, ses_perceived) %>% 
  corr_table(
    c.names = c("Parental Education", "Parental Occupation", "School or Club -Provided", "Perceived"),
    numbered = T,
    stats = c("min", "median", "max", "range", "mean", "sd")
  ) %>% 
  add_row(Variable = "Possible Range", `1` = "1-3", `2` = "0-100", `3` = "-0.5, 0.5", `4` = "1-5")

