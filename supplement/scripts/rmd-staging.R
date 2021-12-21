# Packages ----------------------------------------------------------------
library(tidyverse)
library(cowplot)
library(see)
library(gt)
library(psych)

# ggplot2 theme -----------------------------------------------------------
theme_set(
  theme_bw() +
    theme(
      axis.line.y       = element_line(),
      axis.text.y       = element_text(size = rel(.75)),
      axis.title.y      = element_text(size = rel(1), margin = margin(1,0,0,0,"lines")),
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
my_alphas <- c(.5, 1)
my_limits <- c(1,70)

# Multiverse Objects ----
load("multiverse-objects/1-multiverse-datasets/datalist-agg-ivs.Rdata")
load("data/data1_raw.Rdata")
load("data/data2_analysis.Rdata")
load("multiverse-objects/2-primary-analyses/3-extracted-effects.Rdata")
load("multiverse-objects/3-secondary-analyses/set-2/a1-extracted-effects.Rdata")
load("multiverse-objects/3-secondary-analyses/set-1/a2-extracted-effects.Rdata")

# Make plots and tables ----
source("supplement/scripts/0-corr_table.R")
source("supplement/scripts/1-covariates.R")
source("supplement/scripts/2-secondary1.R")
source("supplement/scripts/3-secondary2.R")
source("supplement/scripts/4-tables.R")

# Save the entire image ---------------------------------------------------
save(
  si_table.01.1,
  shifting_unp,
  shifting_vio,
  shifting_ses,
  updating_unp,
  updating_vio,
  updating_ses,
  si_table.02.0,
  si_table.03.0,
  unp_shifting,
  vio_shifting,
  ses_shifting,
  unp_updating,
  vio_updating,
  ses_updating,
  si_table.04.0,
  si_table.05.0,
  vio_ses_updating,
  file = "supplement/staged-objects.Rdata"
)
