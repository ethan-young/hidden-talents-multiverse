# Setup -------------------------------------------------------------------
# Libraries
library(tidyverse)
library(cowplot)
library(see)

# Load effect data.frames -------------------------------------------------
load("multiverse-objects/2-primary-analyses/3-extracted-effects.Rdata")
load("multiverse-objects/2-primary-analyses/5-bootstrapped-effects.Rdata")

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
my_alphas <- c(.3, 1)
my_limits <- c(1,70)

# Get bootstrapped medians ------------------------------------------------
boot_medians <- 
  boot_effects %>% 
  filter((null_term == "main" & mod_term == "iv") | (null_term == "int" & mod_term == "iv:type_z")) %>% 
  rename(term = mod_term) %>% 
  group_by(spec_num, iv, dv, null_term) %>% 
  summarize(
    across(
      starts_with("mod"), 
      list(median = ~median(.x), lower = ~quantile(.x, probs = .025, names = F), upper = ~quantile(.x, probs = .975, names = F)),
      .names = "{.col}_{.fn}")
  ) %>%
  group_by(iv, dv, null_term) %>% 
  mutate(spec_rank = as.numeric(fct_reorder(as_factor(spec_num), mod_std_coefficient_median))) %>% 
  select(iv, dv, null_term, contains("mod_std_coefficient"), spec_rank) %>% 
  rename(
    null_effect = mod_std_coefficient_median,
    null_lower  = mod_std_coefficient_lower,
    null_upper  = mod_std_coefficient_upper
  ) %>% 
  mutate(
    iv_long = case_when(iv == "ses" ~ "SES",
                        iv == "unp" ~ "Unpredictability",
                        iv == "vio" ~ "Violence"),
    dv_long = case_when(dv == "shifting" ~ "Attention-Shifting",
                        dv == "updating" ~ "Working Memory Updating"),
    term_long = case_when(null_term == "main" ~ "Main Effect",
                          null_term == "int" ~ "Interaction")
  ) %>% 
  ungroup()

# Merge primary effects with bootstrapped effects -------------------------
primary_plots_data <- 
  left_join(
    primary_effects_data,
    boot_medians %>% select(ends_with("long"), spec_rank, null_effect, null_lower, null_upper),
    by = c("iv" = "iv_long", "dv" = "dv_long", "mod_term_group" = "term_long", "spec_rank" = "spec_rank")
  ) %>% 
  filter(mod_term_group %in% c("Main Effect", "Interaction")) %>% 
  ungroup()

# specification curve -----------------------------------------------------
spec_curves <- 
  map(c("Attention-Shifting","Working Memory Updating"), function(x){
    map(c("Main Effect","Interaction"), function(y){
      
      effs <- 
        primary_plots_data %>% 
        filter(dv == x, mod_term_group == y) %>% 
        mutate(
          iv     = factor(iv, c("Unpredictability","Violence","SES")),
          hypoth = factor(hypoth, c("Exploratory", "Confirmatory"))
        )
      
      medians <- 
        primary_plots_data %>% 
        filter(dv == x, mod_term_group == y) %>% 
        mutate(
          iv     = factor(iv, c("Unpredictability","Violence","SES")),
          hypoth = factor(hypoth, c("Exploratory", "Confirmatory"))
        )
      
      eff_curve <- 
        effs %>% 
        ggplot(aes(x = mod_std_coefficient, y = spec_rank, color = mod_sig, alpha = hypoth)) +
        geom_ribbon(
          aes(xmin = mod_ci_low, xmax = mod_ci_high, y = spec_rank, alpha = hypoth),
          fill = "gray80",
          inherit.aes = F,
          show.legend = F
        ) +
        #geom_vline(aes(xintercept = 0), linetype = "dashed") +
        geom_point_borderless(size = 1, shape = 19, show.legend = F) + 
        geom_ribbon(
          aes(x = null_effect, xmin = null_lower, xmax = null_upper, y = spec_rank),
          size = .5,
          color = "black",
          fill = NA,
          linetype = "dotted",
          alpha = .5,
          inherit.aes = F
        ) +
        geom_line(
          aes(x = null_effect, y = spec_rank),
          size = .5,
          color = "black",
          linetype = "dashed",
          inherit.aes = F
        ) +
        geom_point(
          data = medians,
          aes(x = median_dbl, y = 32, alpha = hypoth),
          shape = 4,
          size  = 7,
          show.legend = F,
          inherit.aes = F
        ) +
        geom_point(
          data = medians,
          aes(x = median_dbl, y = 32, alpha = hypoth),
          shape = 21,
          size  = 3,
          fill  = "white",
          stroke = 1,
          show.legend = F,
          inherit.aes = F
        ) +
        geom_label(
          data = medians,
          aes(x = median_dbl, label = median_chr, y = 32, hjust = - .4, alpha = hypoth),
          size = 2.5,
          show.legend = F,
          inherit.aes = F
        ) +
        scale_y_continuous("Specification Rank", limits = my_limits) + 
        scale_x_continuous(expression(beta)) +
        scale_color_manual(values = pval_colors) +
        scale_fill_manual(values = pval_colors) +
        scale_alpha_manual(values = my_alphas) +
        facet_grid(iv~mod_term_group) +
        ggtitle("Effect Size Curve") +
        theme(
          strip.text = element_blank()
        )
      
      sample_sizes <- 
        effs %>% 
        ggplot(aes(y = spec_rank, x = n, color = mod_sig, alpha = hypoth)) +
        geom_segment(aes(x = 0, xend = n, y = spec_rank, yend = spec_rank), show.legend = F) +
        geom_point_borderless(size = 1, shape = 19, show.legend = F) +
        scale_x_continuous(expression(italic(N))) +
        scale_y_continuous(limits = my_limits) +
        scale_color_manual(values = pval_colors) +
        scale_alpha_manual(values = my_alphas) +
        facet_grid(iv~mod_term_group) +
        ggtitle("Sample Sizes") +
        theme(
          strip.text = element_blank(),
          axis.text.x = element_text(angle = 270, hjust = 0, vjust = .5)
        )
      
      spec_grid_data <- 
        effs %>% 
        select(iv, dv, hypoth, starts_with("spec"), mod_p.value, mod_sig) %>% 
        pivot_longer(cols = spec_sub_sample:spec_shifting, names_to = "spec_var", values_to = "spec_value") %>% 
        ungroup()
      
      spec_grid <- 
        spec_grid_data %>% 
        ggplot(aes(y = spec_rank, x = spec_value, color = mod_sig, alpha = hypoth)) +
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
        scale_alpha_manual(values = my_alphas) +
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
        ggplot(aes(x = mod_p.value, alpha = hypoth)) +
        geom_histogram(color = "black", size = .2) +
        geom_vline(aes(xintercept = .05), color = "red", linetype = "dashed") +
        geom_text(
          data = effs %>% group_by(iv,hypoth) %>% summarize(p = unique(pval_prop), y = 12) %>% ungroup(),
          aes(x = .125, label = p, y = y, alpha = hypoth),
          size = 2.25,
          hjust = 0,
          show.legend = F
        ) +
        scale_x_continuous(expression(italic(p),"-",value)) +
        scale_y_continuous("Count") +
        scale_alpha_manual(values = my_alphas) +
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

# Put them together -------------------------------------------------------
primary_attention_shifting <- 
  plot_grid(
    spec_curves[[1]][[1]]$p_curve,
    spec_curves[[1]][[1]]$eff_curve,
    spec_curves[[1]][[1]]$sample_sizes,
    spec_curves[[1]][[1]]$spec_grid,
    spec_curves[[1]][[2]]$spec_grid,
    spec_curves[[1]][[2]]$sample_sizes,
    spec_curves[[1]][[2]]$eff_curve,
    spec_curves[[1]][[2]]$p_curve,
    ncol        = 8, 
    align       = "hv", 
    axis        = "tb",
    rel_widths  = c(.15,.125,.05,.175,.175,.05,.125,.15)
  ) +
  draw_line(c(.075,.49), c(.955,.955), size = .2) +
  draw_line(c(.51,.925), c(.955,.955), size = .2) +
  draw_label("Main Effects", x = 0.2825, y = .965, hjust = .5, vjust = 0) + 
  draw_label("Interactions", x = 0.7175, y = .965, hjust = .5, vjust = 0)

primary_working_memory <- 
  plot_grid(
    spec_curves[[2]][[1]]$p_curve,
    spec_curves[[2]][[1]]$eff_curve,
    spec_curves[[2]][[1]]$sample_sizes,
    spec_curves[[2]][[1]]$spec_grid,
    spec_curves[[2]][[2]]$spec_grid,
    spec_curves[[2]][[2]]$sample_sizes,
    spec_curves[[2]][[2]]$eff_curve,
    spec_curves[[2]][[2]]$p_curve,
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
primary_interactions <- 
  primary_effects_points %>% 
  mutate(
    iv        = factor(iv, c("Unpredictability","Violence","SES")),
    hypoth    = factor(hypoth, c("Exploratory", "Confirmatory")),
    predicted = ifelse(dv == "Working Memory Updating", predicted*100, predicted),
    dv        = ifelse(dv == "Working Memory Updating", "WM Updating", dv),
    dv        = ifelse(dv == "Attention-Shifting", paste(dv,"(ms)\n"), paste(dv,"(% correct)\n")),
    x         = ifelse(iv == "SES", x *-1, x),
    x         = factor(x, levels = c(-1,1), labels = c("Low","High")),
    x_spec    = paste0(x,"_",spec_number),
    group     = as.numeric(group),
    group_adj = ifelse(x == "Low", group - .1, group + .1),
    group_jit = jitter(group_adj,.05, .05),
    group_bx  = ifelse(group == 1, group_adj - .35, group_adj + .35)
  ) %>% 
  ggplot(aes(x = group_jit, y = predicted, group = x_spec, color = mod_sig, alpha = hypoth)) +
  geom_line(size = .5, show.legend = F) +
  geom_point_borderless(size = .75, shape = 19, show.legend = F) +
  stat_summary(
    aes(x = group_adj, y = predicted, group = x), 
    geom = "line", 
    fun = "median", 
    color = "black", 
    alpha = 1,
    size = 1,
    show.legend = F
  ) +
  stat_summary(
    aes(x = group_adj, y = predicted, group = x, fill = x),
    geom = "point", 
    fun = "median", 
    color = "black", 
    shape = 21,
    stroke = 1, 
    alpha = 1,
    size = 5, 
    show.legend = T
  ) +
  geom_boxplot(
    aes(x = group_bx, y = predicted, group = interaction(x,group), fill = x), 
    color = "black",
    position = position_identity(), 
    width = .1, 
    inherit.aes = F, 
    show.legend = F
  ) +
  scale_x_continuous("", breaks = c(1,2), labels = c("Abstract","Real-World"), expand = c(.15,.15)) +
  scale_color_manual(values = pval_colors) +
  scale_fill_manual("Adversity", labels = c("Low (-1 SD)", "High (+1 SD)"),values = c("white","black")) +
  scale_alpha_manual(values = c(.1,.8)) +
  facet_grid(cols = vars(iv), rows = vars(dv), scales = "free_y", switch = "y") +
  guides(alpha = F, color = F) +
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
  plot     = primary_attention_shifting, 
  device   = "pdf", 
  filename = "figures/primary/spec-curve-shifting.pdf", 
  width    = 14,
  height   = 7.5,
  units    = "in",
  dpi      = "retina"
)

ggsave(
  plot     = primary_working_memory, 
  device   = "pdf", 
  filename = "figures/primary/spec-curve-updating.pdf", 
  width    = 14,
  height   = 7.5,
  units    = "in",
  dpi      = "retina"
)

 ggsave(
  plot     = primary_interactions, 
  device   = "pdf", 
  filename = "figures/primary/interactions.pdf", 
  width    = 13.33,
  height   = 6.5,
  units    = "in",
  dpi      = "retina"
)
 