# Setup -------------------------------------------------------------------
# Libraries
library(tidyverse)
library(cowplot)

# Load effect data.frames -------------------------------------------------
load("multiverse-objects/3-secondary-analyses/set-2/a1-extracted-effects.Rdata")

# ggplot2 theme -----------------------------------------------------------
theme_set(
  theme_bw() +
    theme(
      axis.line.x       = element_line(),
      axis.text.x       = element_text(size = rel(.75)),
      axis.title.x      = element_text(size = rel(1), margin = margin(1,0,0,0,"lines")),
      axis.ticks.x      = element_line(),
      axis.line.y       = element_blank(),
      axis.text.y       = element_blank(),
      axis.ticks.y      = element_blank(),
      axis.title.y      = element_blank(),
      panel.border      = element_blank(), 
      panel.spacing.y   = unit(.5, "lines"),
      plot.margin       = margin(2,.25,.25,.25,"lines"),
      plot.background   = element_rect(color = NA),
      plot.title        = element_text(size = rel(.9), hjust = 0.5),
      plot.subtitle     = element_blank(),
      panel.grid        = element_line(color = NA),
      strip.background  = element_blank(), 
      strip.placement   = "outside",
      strip.text        = element_text(size = rel(.85), angle = 0)
    )
)

pval_colors <- c("pos-sig" = "#FF7F00", "neg-sig" = "#1F78B4", "non" = "gray")
my_limits <- c(1,70)


# Plotting Data -----------------------------------------------------------
secondary_set2_plots_data <- 
  secondary_set2_effects_clean %>% 
  mutate(
    mod_term_group = case_when(str_detect(mod_term, "^iv$") ~ "Main Effect",
                               str_detect(mod_term, ":")    ~ "Interaction"),
    iv             = factor(iv, 
                            levels = c("unp_agg", "unp_interview","unp_perceived",
                                       "vio_agg", "vio_neighborhood","vio_fighting",
                                       "ses_agg", "ses_perceived","ses_school","ses_interview"),
                            labels = c("Composite", "Interview", "Perceived",
                                       "Composite", "Neighborhood","Fighting",
                                       "Composite", "Perceived","School","Interview")),
    pval_prop      = paste0(round(pval_prop*100,2),"% ps < .05")
  )

# specification curve -----------------------------------------------------
spec_curves <- 
  map(c("Attention-Shifting","Working Memory Updating"), function(x){
    map(c("Main Effect","Interaction"), function(y){
      map(c("Unpredictability","Violence","SES"), function(z){
        
        effs <- 
          secondary_set2_plots_data %>% 
          filter(dv == x, mod_term_group == y, iv_group == z)
        
        medians <- 
          secondary_set2_plots_data %>% 
          filter(dv == x, mod_term_group == y,  iv_group == z)
        
        eff_curve <- 
          effs %>% 
          ggplot(aes(x = mod_std_coefficient, y = spec_rank, color = mod_sig)) +
          geom_ribbon(
            aes(xmin = mod_ci_low, xmax = mod_ci_high, y = spec_rank),
            fill = "gray80",
            inherit.aes = F,
            show.legend = F
          ) +
          geom_vline(aes(xintercept = 0), linetype = "dashed") +
          geom_point(size = 1, shape = 19, show.legend = F) + 
          geom_point(
            data = medians,
            aes(x = median_dbl, y = 32),
            shape = 4,
            size  = 7,
            show.legend = F,
            inherit.aes = F
          ) +
          geom_point(
            data = medians,
            aes(x = median_dbl, y = 32),
            shape = 21,
            size  = 3,
            fill  = "white",
            stroke = 1,
            show.legend = F,
            inherit.aes = F
          ) +
          geom_label(
            data = medians,
            aes(x = median_dbl, label = median_chr, y = 32, hjust = - .4),
            size = 2.5,
            show.legend = F,
            inherit.aes = F
          ) +
          scale_y_continuous("Specification Rank", limits = my_limits) + 
          scale_x_continuous(expression(beta)) +
          scale_color_manual(values = pval_colors) +
          scale_fill_manual(values = pval_colors) +
          facet_grid(iv~mod_term_group) +
          ggtitle("Effect Size Curve") +
          theme(
            strip.text = element_blank()
          )
        
        sample_sizes <- 
          effs %>% 
          ggplot(aes(y = spec_rank, x = n, color = mod_sig)) +
          geom_segment(aes(x = 0, xend = n, y = spec_rank, yend = spec_rank), show.legend = F) +
          geom_point(size = 1, shape = 19, show.legend = F) +
          scale_x_continuous(expression(italic(N))) +
          scale_y_continuous(limits = my_limits) +
          scale_color_manual(values = pval_colors) +
          facet_grid(iv~mod_term_group) +
          ggtitle("Sampe Size") +
          theme(
            strip.text = element_blank(),
            axis.text.x = element_text(angle = 270, hjust = 0, vjust = .5)
          )
        
        spec_grid_data <- 
          effs %>% 
          select(iv, dv, starts_with("spec"), mod_p.value, mod_sig) %>% 
          pivot_longer(cols = spec_sub_sample:spec_shifting, names_to = "spec_var", values_to = "spec_value") %>% 
          ungroup()
        
        spec_grid <- 
          spec_grid_data %>% 
          ggplot(aes(y = spec_rank, x = spec_value, color = mod_sig)) +
          geom_point(size = 4, shape = 95, show.legend = F) +
          geom_text(
            data = spec_grid_data %>% 
              group_by(iv, spec_var, spec_value) %>% 
              summarize(
                n_sig    = sum(mod_p.value < .05),
                prop_sig = (sum(mod_p.value < .05)/n()),
                prop_sig = ifelse(prop_sig %in% c(0,1), NA, round(prop_sig,2) %>% paste0() %>% str_remove("^0")),
              ) %>% ungroup(),
            aes(y = 66, x = spec_value, label = prop_sig), 
            size = 2, 
            nudge_y = 4,
            show.legend = F,
            inherit.aes = F
          ) +
          geom_hline(aes(yintercept = 66), show.legend = F) +
          geom_segment(aes(x = 1, xend = 1, y = 67, yend = 66), inherit.aes = F, show.legend = F) +
          geom_segment(aes(x = 2, xend = 2, y = 67, yend = 66), inherit.aes = F, show.legend = F) +
          scale_x_discrete() +
          scale_y_continuous(limits = my_limits) +
          scale_color_manual(values = pval_colors) +
          ggtitle("Specifications") +
          facet_grid(iv~spec_var, scales = "free") +
          theme(
            strip.text      = element_blank(),
            panel.spacing.x = unit(0.15,"lines"), 
            axis.text.x     = element_text(angle = 270, hjust = 0, vjust = .5, size = rel(.95)),
            axis.title.x    = element_blank()
          )
        
        p_curve <- 
          effs %>% 
          ggplot(aes(x = mod_p.value)) +
          geom_histogram(color = "black", size = .2) +
          geom_vline(aes(xintercept = .05), color = "red", linetype = "dashed") +
          geom_text(
            data = effs %>% group_by(iv) %>% summarize(p = unique(pval_prop), y = 12),
            aes(x = .2, label = p, y = y),
            size = 2.75,
            hjust = 0,
            show.legend = F
          ) +
          scale_x_continuous(expression(italic(p),"-",value)) +
          scale_y_continuous("Count") +
          ggtitle("P-Curve") +
          theme(
            strip.text      = element_blank(), 
            legend.position = "none"
          )
        
        if(y == "Main Effect"){
          p_curve <-
            p_curve +
            facet_grid(iv~mod_term_group, switch = "y") +
            theme(strip.text.y.left = element_text(angle = 0, size = rel(.85), hjust = 1))
        }
        
        if(y == "Interaction"){
          p_curve <-
            p_curve +
            facet_grid(iv~mod_term_group) +
            theme(strip.text.y.right = element_text(angle = 0, size = rel(.85), hjust = 0))
        }
        
        list(
          eff_curve    = eff_curve,
          sample_sizes = sample_sizes,
          spec_grid    = spec_grid,
          p_curve      = p_curve
        )
      })
    })
  })

# Shifting Plots ----------------------------------------------------------
secondary2a_shifting_unp <- 
  plot_grid(
    spec_curves[[1]][[1]][[1]]$p_curve,
    spec_curves[[1]][[1]][[1]]$eff_curve,
    spec_curves[[1]][[1]][[1]]$sample_sizes,
    spec_curves[[1]][[1]][[1]]$spec_grid,
    spec_curves[[1]][[2]][[1]]$spec_grid,
    spec_curves[[1]][[2]][[1]]$sample_sizes,
    spec_curves[[1]][[2]][[1]]$eff_curve,
    spec_curves[[1]][[2]][[1]]$p_curve,
    ncol        = 8, 
    align       = "hv", 
    axis        = "tb",
    rel_widths  = c(.15,.125,.05,.175,.175,.05,.125,.15)
  ) +
  draw_line(c(.075,.49), c(.955,.955), size = .2) +
  draw_line(c(.51,.925), c(.955,.955), size = .2) +
  draw_label("Main Effects", x = 0.2825, y = .965, hjust = .5, vjust = 0) + 
  draw_label("Interactions", x = 0.7175, y = .965, hjust = .5, vjust = 0)

secondary2a_shifting_vio <- 
  plot_grid(
    spec_curves[[1]][[1]][[2]]$p_curve,
    spec_curves[[1]][[1]][[2]]$eff_curve,
    spec_curves[[1]][[1]][[2]]$sample_sizes,
    spec_curves[[1]][[1]][[2]]$spec_grid,
    spec_curves[[1]][[2]][[2]]$spec_grid,
    spec_curves[[1]][[2]][[2]]$sample_sizes,
    spec_curves[[1]][[2]][[2]]$eff_curve,
    spec_curves[[1]][[2]][[2]]$p_curve,
    ncol        = 8, 
    align       = "hv", 
    axis        = "tb",
    rel_widths  = c(.15,.125,.05,.175,.175,.05,.125,.15)
  ) +
  draw_line(c(.075,.49), c(.955,.955), size = .2) +
  draw_line(c(.51,.925), c(.955,.955), size = .2) +
  draw_label("Main Effects", x = 0.2825, y = .965, hjust = .5, vjust = 0) + 
  draw_label("Interactions", x = 0.7175, y = .965, hjust = .5, vjust = 0)

secondary2a_shifting_ses <- 
  plot_grid(
    spec_curves[[1]][[1]][[3]]$p_curve,
    spec_curves[[1]][[1]][[3]]$eff_curve,
    spec_curves[[1]][[1]][[3]]$sample_sizes,
    spec_curves[[1]][[1]][[3]]$spec_grid,
    spec_curves[[1]][[2]][[3]]$spec_grid,
    spec_curves[[1]][[2]][[3]]$sample_sizes,
    spec_curves[[1]][[2]][[3]]$eff_curve,
    spec_curves[[1]][[2]][[3]]$p_curve,
    ncol        = 8, 
    align       = "hv", 
    axis        = "tb",
    rel_widths  = c(.15,.125,.05,.175,.175,.05,.125,.15)
  ) +
  draw_line(c(.075,.49), c(.955,.955), size = .2) +
  draw_line(c(.51,.925), c(.955,.955), size = .2) +
  draw_label("Main Effects", x = 0.2825, y = .965, hjust = .5, vjust = 0) + 
  draw_label("Interactions", x = 0.7175, y = .965, hjust = .5, vjust = 0)

# Working Memory ----------------------------------------------------------
secondary2a_updating_unp <- 
  plot_grid(
    spec_curves[[2]][[1]][[1]]$p_curve,
    spec_curves[[2]][[1]][[1]]$eff_curve,
    spec_curves[[2]][[1]][[1]]$sample_sizes,
    spec_curves[[2]][[1]][[1]]$spec_grid,
    spec_curves[[2]][[2]][[1]]$spec_grid,
    spec_curves[[2]][[2]][[1]]$sample_sizes,
    spec_curves[[2]][[2]][[1]]$eff_curve,
    spec_curves[[2]][[2]][[1]]$p_curve,
    ncol        = 8, 
    align       = "hv", 
    axis        = "tb",
    rel_widths  = c(.15,.125,.05,.175,.175,.05,.125,.15)
  ) +
  draw_line(c(.075,.49), c(.955,.955), size = .2) +
  draw_line(c(.51,.925), c(.955,.955), size = .2) +
  draw_label("Main Effects", x = 0.2825, y = .965, hjust = .5, vjust = 0) + 
  draw_label("Interactions", x = 0.7175, y = .965, hjust = .5, vjust = 0)

secondary2a_updating_vio <- 
  plot_grid(
    spec_curves[[2]][[1]][[2]]$p_curve,
    spec_curves[[2]][[1]][[2]]$eff_curve,
    spec_curves[[2]][[1]][[2]]$sample_sizes,
    spec_curves[[2]][[1]][[2]]$spec_grid,
    spec_curves[[2]][[2]][[2]]$spec_grid,
    spec_curves[[2]][[2]][[2]]$sample_sizes,
    spec_curves[[2]][[2]][[2]]$eff_curve,
    spec_curves[[2]][[2]][[2]]$p_curve,
    ncol        = 8, 
    align       = "hv", 
    axis        = "tb",
    rel_widths  = c(.15,.125,.05,.175,.175,.05,.125,.15)
  ) +
  draw_line(c(.075,.49), c(.955,.955), size = .2) +
  draw_line(c(.51,.925), c(.955,.955), size = .2) +
  draw_label("Main Effects", x = 0.2825, y = .965, hjust = .5, vjust = 0) + 
  draw_label("Interactions", x = 0.7175, y = .965, hjust = .5, vjust = 0)

secondary2a_updating_ses <- 
  plot_grid(
    spec_curves[[2]][[1]][[3]]$p_curve,
    spec_curves[[2]][[1]][[3]]$eff_curve,
    spec_curves[[2]][[1]][[3]]$sample_sizes,
    spec_curves[[2]][[1]][[3]]$spec_grid,
    spec_curves[[2]][[2]][[3]]$spec_grid,
    spec_curves[[2]][[2]][[3]]$sample_sizes,
    spec_curves[[2]][[2]][[3]]$eff_curve,
    spec_curves[[2]][[2]][[3]]$p_curve,
    ncol        = 8, 
    align       = "hv", 
    axis        = "tb",
    rel_widths  = c(.15,.125,.05,.175,.175,.05,.125,.15)
  ) +
  draw_line(c(.075,.49), c(.955,.955), size = .2) +
  draw_line(c(.51,.925), c(.955,.955), size = .2) +
  draw_label("Main Effects", x = 0.2825, y = .965, hjust = .5, vjust = 0) + 
  draw_label("Interactions", x = 0.7175, y = .965, hjust = .5, vjust = 0)

# Interaction Plots -------------------------------------------------------
secondary_set2_int_data <- 
  secondary_set2_effects_points %>%
  mutate(
    iv        = factor(iv, 
                       levels = c("unp_agg", "unp_interview","unp_perceived",
                                  "vio_agg", "vio_neighborhood","vio_fighting",
                                  "ses_agg", "ses_perceived","ses_school","ses_interview"),
                       labels = c("Composite", "Interview", "Perceived",
                                  "Composite", "Neighborhood","Fighting",
                                  "Composite", "Perceived","School","Interview")),
    predicted = ifelse(dv == "Working Memory Updating", predicted*100, predicted),
    dv        = ifelse(dv == "Working Memory Updating", "WM Updating", dv),
    dv        = ifelse(dv == "Attention-Shifting", paste(dv,"(ms)\n"), paste(dv,"(% correct)\n")),
    x         = x * -1,
    x         = factor(x, levels = c(-1,1), labels = c("Low","High")),
    x_spec    = paste0(x,"_",spec_number),
    group     = as.numeric(group),
    group     = ifelse(x == "Low", group - .1, group + .1),
    group_jit = jitter(group,.05, .05),
  )

secondary2a_int_unp <- 
  secondary_set2_int_data %>% 
  filter(iv_group == "Unpredictability") %>% 
  ggplot(aes(x = group_jit, y = predicted, group = x_spec, color = mod_sig)) +
  geom_line(size = .5, show.legend = F) +
  geom_point(size = .75, shape = 19, show.legend = F) +
  stat_summary(
    aes(x = group, y = predicted, group = x), 
    geom = "line", 
    fun = "median", 
    color = "black", 
    alpha = 1,
    size = 1,
    show.legend = F
  ) +
  stat_summary(
    aes(x = group, y = predicted, group = x, fill = x),
    geom = "point", 
    fun = "median", 
    color = "black", 
    shape = 21,
    stroke = 1, 
    alpha = 1,
    size = 5, 
    show.legend = T
  ) +
  scale_x_continuous("", breaks = c(1,2), labels = c("Abstract","Ecological"), expand = c(.15,.15)) +
  scale_color_manual(values = pval_colors) +
  scale_fill_manual("Adversity", labels = c("Low (-1 SD)", "High (+1 SD)"), values = c("white","black")) +
  guides(alpha = F, color = F) +
  facet_grid(cols = vars(iv), rows = vars(dv), scales = "free_y", switch = "y") +
  ggtitle("Unpredictability") +
  theme(
    axis.line.y     = element_line(),
    axis.text.y     = element_text(),
    axis.ticks.y    = element_line(),
    axis.text.x     = element_text(size = rel(1.25)),
    axis.title.x    = element_blank(),
    panel.spacing.x = unit(1, "lines"),
    panel.spacing.y = unit(1, "lines"),
    plot.margin     = margin(1,1,1,1,"lines"),
    plot.title      = element_text(size = rel(2), face = "bold", hjust = 0),
    strip.text      = element_text(size = rel(1.25))
  )

secondary2a_int_vio <- 
  secondary_set2_int_data %>% 
  filter(iv_group == "Violence") %>% 
  ggplot(aes(x = group_jit, y = predicted, group = x_spec, color = mod_sig)) +
  geom_line(size = .5, show.legend = F) +
  geom_point(size = .75, shape = 19, show.legend = F) +
  stat_summary(
    aes(x = group, y = predicted, group = x), 
    geom = "line", 
    fun = "median", 
    color = "black", 
    alpha = 1,
    size = 1,
    show.legend = F
  ) +
  stat_summary(
    aes(x = group, y = predicted, group = x, fill = x),
    geom = "point", 
    fun = "median", 
    color = "black", 
    shape = 21,
    stroke = 1, 
    alpha = 1,
    size = 5, 
    show.legend = T
  ) +
  scale_x_continuous("", breaks = c(1,2), labels = c("Abstract","Ecological"), expand = c(.15,.15)) +
  scale_color_manual(values = pval_colors) +
  scale_fill_manual("Adversity", labels = c("Low (-1 SD)", "High (+1 SD)"), values = c("white","black")) +
  guides(alpha = F, color = F) +
  facet_grid(cols = vars(iv), rows = vars(dv), scales = "free_y", switch = "y") +
  ggtitle("Violence") +
  theme(
    axis.line.y     = element_line(),
    axis.text.y     = element_text(),
    axis.ticks.y    = element_line(),
    axis.text.x     = element_text(size = rel(1.25)),
    axis.title.x    = element_blank(),
    panel.spacing.x = unit(1, "lines"),
    panel.spacing.y = unit(1, "lines"),
    plot.margin     = margin(1,1,1,1,"lines"),
    plot.title      = element_text(size = rel(2), face = "bold", hjust = 0),
    strip.text      = element_text(size = rel(1.25))
  )

secondary2a_int_ses <- 
  secondary_set2_int_data %>% 
  filter(iv_group == "SES") %>% 
  ggplot(aes(x = group_jit, y = predicted, group = x_spec, color = mod_sig)) +
  geom_line(size = .5, show.legend = F) +
  geom_point(size = .75, shape = 19, show.legend = F) +
  stat_summary(
    aes(x = group, y = predicted, group = x), 
    geom = "line", 
    fun = "median", 
    color = "black", 
    alpha = 1,
    size = 1,
    show.legend = F
  ) +
  stat_summary(
    aes(x = group, y = predicted, group = x, fill = x),
    geom = "point", 
    fun = "median", 
    color = "black", 
    shape = 21,
    stroke = 1, 
    alpha = 1,
    size = 5, 
    show.legend = T
  ) +
  scale_x_continuous("", breaks = c(1,2), labels = c("Abstract","Ecological"), expand = c(.15,.15)) +
  scale_color_manual(values = pval_colors) +
  scale_fill_manual("Adversity", labels = c("Low (-1 SD)", "High (+1 SD)"), values = c("white","black")) +
  guides(alpha = F, color = F) +
  facet_grid(cols = vars(iv), rows = vars(dv), scales = "free_y", switch = "y") +
  ggtitle("Socioeconomic Status") +
  theme(
    axis.line.y     = element_line(),
    axis.text.y     = element_text(),
    axis.ticks.y    = element_line(),
    axis.text.x     = element_text(size = rel(1.25)),
    axis.title.x    = element_blank(),
    panel.spacing.x = unit(1, "lines"),
    panel.spacing.y = unit(1, "lines"),
    plot.margin     = margin(1,1,1,1,"lines"),
    plot.title      = element_text(size = rel(2), face = "bold", hjust = 0),
    strip.text      = element_text(size = rel(1.25))
  )

# Save Plots --------------------------------------------------------------
# Unpredictability
ggsave(
  plot     = secondary2a_shifting_unp, 
  device   = "pdf", 
  filename = "figures/secondary/set-2/a1-unp-shifting.pdf", 
  width    = 14,
  height   = 7.5,
  units    = "in",
  dpi      = "retina"
)

ggsave(
  plot     = secondary2a_updating_unp, 
  device   = "pdf", 
  filename = "figures/secondary/set-2/a1-unp-updating.pdf", 
  width    = 14,
  height   = 7.5,
  units    = "in",
  dpi      = "retina"
)

ggsave(
  plot     = secondary2a_int_unp, 
  device   = "pdf", 
  filename = "figures/secondary/set-2/a1-unp-interactions.pdf", 
  width    = 14,
  height   = 7.5,
  units    = "in",
  dpi      = "retina"
)

# Violence
ggsave(
  plot     = secondary2a_shifting_vio, 
  device   = "pdf", 
  filename = "figures/secondary/set-2/a1-vio-shifting.pdf", 
  width    = 14,
  height   = 7.5,
  units    = "in",
  dpi      = "retina"
)

ggsave(
  plot     = secondary2a_updating_vio, 
  device   = "pdf", 
  filename = "figures/secondary/set-2/a1-vio-updating.pdf", 
  width    = 14,
  height   = 7.5,
  units    = "in",
  dpi      = "retina"
)

ggsave(
  plot     = secondary2a_int_vio, 
  device   = "pdf", 
  filename = "figures/secondary/set-2/a1-vio-interactions.pdf", 
  width    = 14,
  height   = 7.5,
  units    = "in",
  dpi      = "retina"
)

# SES
ggsave(
  plot     = secondary2a_shifting_ses, 
  device   = "pdf", 
  filename = "figures/secondary/set-2/a1-ses-shifting.pdf", 
  width    = 14,
  height   = 7.5,
  units    = "in",
  dpi      = "retina"
)

ggsave(
  plot     = secondary2a_updating_ses, 
  device   = "pdf", 
  filename = "figures/secondary/set-2/a1-ses-updating.pdf", 
  width    = 14,
  height   = 7.5,
  units    = "in",
  dpi      = "retina"
)

ggsave(
  plot     = secondary2a_int_ses, 
  device   = "pdf", 
  filename = "figures/secondary/set-2/a1-ses-interactions.pdf", 
  width    = 14,
  height   = 7.5,
  units    = "in",
  dpi      = "retina"
)
