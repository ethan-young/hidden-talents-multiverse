# Setup -------------------------------------------------------------------
# Libraries
library(tidyverse)
library(cowplot)

# Load Data ---------------------------------------------------------------
load("multiverse-objects/3-secondary-analyses/set-1/a2-extracted-effects.Rdata")

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
      plot.title        = element_text(size = rel(.9), hjust = .5),
      plot.subtitle     = element_blank(),
      panel.grid        = element_line(color = NA),
      strip.background  = element_blank(), 
      strip.placement   = "outside",
      strip.text        = element_text(size = rel(.85), angle = 0)
    )
)

pval_colors <- c("pos-sig" = "#FF7F00", "neg-sig" = "#1F78B4", "non" = "gray")
my_limits <- c(1,70)

# Spec Curve --------------------------------------------------------------
spec_curves <- 
  map(c("Main Effect","Interaction"), function(x){
    
    effs <- 
      secondary1a_effects_data %>% 
      filter(mod_term_group == x) %>% 
      mutate(iv = ifelse(str_detect(mod_term,"vio"),"Violence","SES"))
    
    medians <- 
      secondary1a_effects_medians %>% 
      filter(mod_term_group == x) %>% 
      mutate(iv = ifelse(str_detect(mod_term,"vio"),"Violence","SES"))
    
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
      scale_y_continuous("Specification Rank") + 
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
      scale_color_manual(values = pval_colors) +
      facet_grid(iv~mod_term_group) +
      ggtitle("Sampe Sizes") +
      theme(
        strip.text = element_blank(),
        axis.text.x = element_text(angle = 270, hjust = 0, vjust = .5)
      )
    
    spec_grid_data <- 
      effs %>% 
      select(iv, dv, starts_with("spec"), mod_p.value, mod_sig) %>% 
      pivot_longer(cols = spec_sub_sample:spec_shifting, names_to = "spec_var", values_to = "spec_value")
    
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
          ),
        aes(y = 66, x = spec_value, label = prop_sig), 
        size = 2, 
        nudge_y = 4,
        show.legend = F,
        inherit.aes = F
      ) +
      geom_hline(aes(yintercept = 66), inherit.aes = F, show.legend = F) +
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
        data = effs %>% group_by(iv) %>% summarize(p = unique(pval_prop)),
        aes(x = .2, label = p, y = 12),
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
    
    if(x == "Main Effect"){
      p_curve <-
        p_curve +
        facet_grid(iv~mod_term_group, switch = "y") +
        theme(strip.text.y.left = element_text(angle = 0, size = rel(.85), hjust = 1))
    }
    
    if(x == "Interaction"){
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

# Put them together -------------------------------------------------------
secondary1a_working_memory <- 
  plot_grid(
    spec_curves[[1]]$p_curve,
    spec_curves[[1]]$eff_curve,
    spec_curves[[1]]$sample_sizes,
    spec_curves[[1]]$spec_grid,
    spec_curves[[2]]$spec_grid,
    spec_curves[[2]]$sample_sizes,
    spec_curves[[2]]$eff_curve,
    spec_curves[[2]]$p_curve,
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
secondary1a_interactions <- 
  secondary1a_effects_points %>% 
  mutate(
    predicted = ifelse(dv == "Working Memory Updating", predicted*100, predicted),
    dv        = ifelse(dv == "Working Memory Updating", "WM Updating", dv),
    dv        = ifelse(dv == "Attention-Shifting", paste(dv,"(ms)\n"), paste(dv,"(% correct)\n")),
    x         = ifelse(iv == "SES", x *-1, x),
    x         = factor(x, levels = c(-1,1), labels = c("Low","High")),
    x_spec    = paste0(x,"_",iv,"_",spec_number),
    group     = as.numeric(group),
    group     = ifelse(x == "Low", group - .1, group + .1),
    group_jit = jitter(group,.05, .05),
  ) %>% 
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
    show.legend = T
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
  theme(
    axis.line.y     = element_line(),
    axis.text.y     = element_text(),
    axis.ticks.y    = element_line(),
    axis.text.x     = element_text(size = rel(1.25)),
    axis.title.x    = element_blank(),
    panel.spacing.x = unit(1, "lines"),
    panel.spacing.y = unit(1, "lines"),
    strip.text      = element_text(size = rel(1.25)),
    plot.margin     = margin(1,1,1,1,"lines") 
  )

# Save Plots --------------------------------------------------------------
ggsave(
  plot     = secondary1a_working_memory, 
  device   = "pdf", 
  filename = "figures/secondary/set-1/a1-spec-curve-updating.pdf", 
  width    = 14,
  height   = 6,
  units    = "in",
  dpi      = "retina"
)

ggsave(
  plot     = secondary1a_interactions, 
  device   = "pdf", 
  filename = "figures/secondary/set-1/a1-interactions.pdf", 
  width    = 8.83,
  height   = 3.75,
  units    = "in",
  dpi      = "retina"
)
