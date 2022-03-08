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
  filter(mod_term_group %in% c("Covariate", "Task-Type", "Main Effect", "Interaction")) %>% 
  ungroup() %>% 
  mutate(
    mod_term_unique = case_when(mod_term_unique == "Task Type" ~ "Task~Version",
                                mod_term_unique == "Test Environment" ~ "Test~Environment",
                                str_detect(mod_term_unique,"symbol") ~ str_replace(mod_term_unique,"Task-Version","Task~Version"),
                                T ~ mod_term_unique),
    mod_term_num   = case_when(str_detect(mod_term_unique, "Unp~sym") ~ 4,
                               str_detect(mod_term_unique, "Vio~sym") ~ 5,
                               str_detect(mod_term_unique, "SES~sym") ~ 6,
                               T ~ mod_term_num),
    mod_term_label = fct_reorder(mod_term_unique, mod_term_num),
  ) 

# specification curve -----------------------------------------------------
spec_curves <- 
  map(c("Attention-Shifting","Working Memory Updating"), function(x){
    
    # Setup
    dv_which <- x
    
    effs <- 
      primary_plots_data %>% 
      filter(dv == x, mod_term_group == "Interaction") %>% 
      mutate(
        hypoth = factor(hypoth, c("Exploratory", "Confirmatory")),
        mod_sig = ifelse(mod_sig != "non", "pos-sig", mod_sig)
      )
    
    medians <- 
      primary_plots_data %>% 
      filter(dv == x, mod_term_group == "Interaction") %>% 
      mutate(
        hypoth = factor(hypoth, c("Exploratory", "Confirmatory")),
        mod_sig = ifelse(mod_sig != "non", "pos-sig", mod_sig)
      )
    
    spec_grid_data <- 
      effs %>% 
      select(mod_term_label, dv, hypoth, starts_with("spec"), mod_p.value, mod_sig) %>% 
      mutate(mod_sig = ifelse(mod_sig != "non", "pos-sig", mod_sig)) %>% 
      pivot_longer(cols = spec_sub_sample:spec_shifting, names_to = "spec_var", values_to = "spec_value") %>% 
      ungroup()
    
    int_points <- 
      primary_effects_points %>% 
      filter(dv == dv_which) %>%
      mutate(
        mod_sig   = ifelse(mod_sig != "non", "pos-sig", mod_sig),
        iv        = ifelse(iv == "SES", "Poverty", iv),
        iv_order  = case_when(iv == "Poverty" ~ 3,iv == "Unpredictability" ~ 1, iv == "Violence" ~ 2),
        iv        = fct_reorder(iv, iv_order),
        hypoth    = factor(hypoth, c("Exploratory", "Confirmatory")),
        predicted = ifelse(dv == "Working Memory Updating", predicted*100, predicted),
        dv        = ifelse(dv == "Working Memory Updating", "WM Updating", dv),
        dv        = ifelse(dv == "Attention-Shifting", paste(dv,"(ms)\n"), paste(dv,"(% correct)\n")),
        x         = ifelse(iv_order == 3, x *-1, x),
        x         = factor(x, levels = c(-1,1), labels = c("Low","High")),
        x_spec    = paste0(x,"_",spec_number),
        group     = as.numeric(group),
        group_adj = ifelse(x == "Low", group - .1, group + .1),
        group_jit = jitter(group_adj,.05, .05),
        group_bx  = ifelse(group == 1, group_adj - .4, group_adj + .4)
      )
    
    # Plots
    eff_curve <- 
      effs %>% 
      ggplot(aes(y = mod_std_coefficient, x = spec_rank, color = mod_sig, alpha = hypoth)) +
      geom_ribbon(
        aes(ymin = mod_ci_low, ymax = mod_ci_high, x = spec_rank),
        fill = "gray90",
        inherit.aes = F,
        show.legend = F
      ) +
      geom_hline(aes(yintercept = 0), size = .5,linetype = "solid") +
      geom_point(size = 1, shape = 19, show.legend = F) + 
      geom_point(
        data = medians,
        aes(y = median_dbl, x = 32, alpha = hypoth),
        shape = 21,
        size  = 2.5,
        fill  = "white",
        stroke = 1,
        show.legend = F,
        inherit.aes = F
      ) +
      geom_label(
        data = medians,
        aes(y = median_dbl, label = median_chr, x = 32),
        nudge_y = .055,
        size = 2.5,
        show.legend = F,
        inherit.aes = F
      ) +
      scale_x_continuous("Specification Rank", limits = my_limits) + 
      scale_y_continuous(expression(beta)) +
      scale_color_manual(values = pval_colors_bw) +
      scale_fill_manual(values = pval_colors_bw) +
      scale_alpha_manual(values = my_alphas) +
      facet_wrap(~mod_term_label) +
      ggtitle("Effect Size Curve") +
      theme(
        strip.text   = element_blank(),
        axis.title.y = element_text(angle = 0, vjust = .5,margin = margin(0,0.25,0,0, "lines"))
      )
    
    sample_sizes <- 
      effs %>% 
      ggplot(aes(x = spec_rank, y = n, color = mod_sig, alpha = hypoth)) +
      geom_segment(aes(y = 0, yend = n, x = spec_rank, xend = spec_rank), show.legend = F) +
      geom_point(size = .75, shape = 19, show.legend = F) + 
      scale_x_continuous(limits = my_limits) +
      scale_y_continuous(expression(italic(N))) +
      scale_color_manual(values = pval_colors_bw) +
      scale_alpha_manual(values = my_alphas) +
      facet_wrap(~mod_term_label) +
      ggtitle("Sample Sizes") +
      theme(
        strip.text   = element_blank(),
        axis.text.y  = element_text(angle = 0),
        axis.title.y = element_text(angle = 0, vjust = .5,margin = margin(0,0.25,0,0, "lines"))
      )
    
    spec_grid <- 
      spec_grid_data %>% 
      ggplot(aes(x = spec_rank, y = spec_value, color = mod_sig, alpha = hypoth)) +
      geom_point(size = 4, shape = 73, show.legend = F) +
      geom_text(
        data = spec_grid_data %>% 
          group_by(mod_term_label, spec_var, spec_value) %>% 
          summarize(
            n_sig    = sum(mod_p.value < .05),
            prop_sig = (sum(mod_p.value < .05)/n()),
            prop_sig = ifelse(prop_sig %in% c(0,1), NA, round(prop_sig,2) %>% paste0() %>% str_remove("^0")),
          ) %>% ungroup(),
        aes(x = 66, y = spec_value, label = prop_sig), 
        size = 2, 
        nudge_x = 4,
        show.legend = F,
        inherit.aes = F
      ) +
      geom_vline(aes(xintercept = 66), show.legend = F) +
      geom_segment(aes(y = 1, yend = 1, x = 67, xend = 66), inherit.aes = F, show.legend = F) +
      geom_segment(aes(y = 2, yend = 2, x = 67, xend = 66), inherit.aes = F, show.legend = F) +
      scale_x_continuous("",limits = my_limits) +
      scale_y_discrete() +
      scale_color_manual(values = pval_colors_bw) +
      scale_alpha_manual(values = my_alphas) +
      facet_grid(spec_var~mod_term_label, scales = "free") +
      ggtitle("Specifications") +
      theme(
        strip.text      = element_blank(),
        panel.spacing.y = unit(0.1,"lines"), 
        axis.text.y     = element_text(angle = 0, hjust = 1, vjust = .5, size = rel(.95)),
        axis.title.y    = element_blank(),
        axis.line.x     = element_line(),
        axis.text.x     = element_text(size = rel(.75)),
        axis.ticks.x    = element_line(),
        axis.title.x    = element_text() 
      )
    
    p_curve <- 
      effs %>% 
      ggplot(aes(x = mod_p.value, alpha = hypoth)) +
      geom_histogram(color = "black", size = .2) +
      geom_vline(aes(xintercept = .05), linetype = "dashed") +
      geom_text(
        data = effs %>% group_by(mod_term_label,hypoth) %>% summarize(p = unique(pval_prop), y = 15) %>% ungroup(),
        aes(x = .125, label = p, y = y),
        size = 2.25,
        hjust = 0,
        vjust = 1,
        show.legend = F,
        inherit.aes = F
      ) +
      scale_x_continuous(expression(italic(p),"-",value), expand = c(0.05,.05)) +
      scale_y_continuous("Freq", expand = c(0,.15)) +
      scale_alpha_manual(values = my_alphas) +
      facet_wrap(~mod_term_label, labeller = label_parsed) +
      ggtitle("P-Curve") +
      theme(
        axis.line.x     = element_line(),
        axis.text.x     = element_text(size = rel(.75)),
        axis.ticks.x    = element_line(),
        axis.title.x    = element_text(),
        axis.title.y    = element_text(angle = 0, vjust = .5,margin = margin(0,0.25,0,0, "lines")),
        legend.position = "none",
        strip.text      = element_blank()
      )
    
    int_plots <- 
      int_points %>% 
      ggplot(aes(x = group_jit, y = predicted, group = x_spec, color = mod_sig, alpha = hypoth)) +
      geom_line(size = .5, show.legend = F) +
      geom_point(size = .5, shape = 19, show.legend = F) + 
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
        size = 2, 
        show.legend = T
      ) +
      geom_boxplot(
        aes(x = group_bx, y = predicted, group = interaction(x,group), fill = x),
        fatten = 1,
        color = "black",
        position = position_identity(), 
        width = .1, 
        inherit.aes = F, 
        show.legend = F
      ) +
      scale_x_continuous(" ", breaks = c(1,2), labels = c("Abstract","Ecological"), expand = c(.1,.1)) +
      scale_color_manual(values = pval_colors_bw) +
      scale_fill_manual("Adversity:", labels = c("Low", "High"),values = c("white","gray60")) +
      scale_alpha_manual(values = c(.1,.8)) +
      facet_wrap(~iv, labeller = label_parsed) +
      guides(alpha = "none", color = "none") +
      theme(
        axis.line.y          = element_line(),
        axis.text.y          = element_text(),
        axis.ticks.y         = element_line(),
        axis.line.x          = element_line(),
        axis.ticks.x         = element_line(),
        axis.text.x          = element_text(size = rel(.75)),
        legend.background    = element_blank(), 
        legend.direction     = "vertical",
        legend.key.width     = unit(.5,"lines"),
        legend.key.height    = unit(.5,"lines"),
        legend.key.size      = unit(.5,units = "points"), 
        legend.text          = element_text(size = rel(.6),margin = margin(0,0,0,0)),
        legend.margin        = margin(0,0,0,0),
        legend.position      = c(.25,.2),
        legend.title.align   = .5,
        legend.title         = element_text(size = rel(.75),margin = margin(0,0,0,0)),
        strip.text           = element_text(size = rel(1), hjust = 0.5, face = "bold", margin = margin(0,0,1,0,"lines")) 
      )
    
    if(dv_which == "Attention-Shifting"){
      int_plots <- 
        int_plots +
        scale_y_reverse(n.breaks = 5) +
        ylab("Switch Cost (ms)\n") +
        theme(legend.position = c(.25,.8))
    }
    
    if(dv_which == "Working Memory Updating"){
      int_plots <- 
        int_plots +
        scale_y_continuous(breaks = seq(69, 77, 2)) +
        ylab("% correct\n")
    }
    
    list(
      eff_curve    = eff_curve,
      sample_sizes = sample_sizes,
      spec_grid    = spec_grid,
      p_curve      = p_curve,
      interactions = int_plots
    )
  })

# Put them together -------------------------------------------------------
fig2_bw <- 
  ggdraw() +
  draw_plot(
    plot_grid(
      spec_curves[[1]]$interactions ,
      spec_curves[[1]]$p_curve,
      spec_curves[[1]]$eff_curve,
      spec_curves[[1]]$sample_sizes,
      spec_curves[[1]]$spec_grid,
      nrow  = 5,
      ncol  = 1, 
      align = "v", 
      axis  = "lr",
      rel_heights = c(.25,.15,.2,.1,.3)
    ) +
      draw_plot_label(c("(faster)","(slower)"), x = 0.15, y = c(.95, .78), size = 8, vjust = 1, hjust = 1, fontface = "italic") +
      draw_plot_label(c("a","b","c","d","e"), x = 1, y = c(.95, .75, .6, .4, .3), size = 10, vjust = 1, hjust = 1), 
    x = 0, y = 0, width = 1, height = .95
  ) + 
  draw_label("Attention Shifting", x = 0.6, y = .975, hjust = .5, vjust = 0, fontface = "bold")

fig3_bw <- 
  ggdraw() +
  draw_plot(
    plot_grid(
      spec_curves[[2]]$interactions,
      spec_curves[[2]]$p_curve,
      spec_curves[[2]]$eff_curve,
      spec_curves[[2]]$sample_sizes,
      spec_curves[[2]]$spec_grid,
      nrow  = 5,
      ncol  = 1, 
      align = "v", 
      axis  = "lr",
      rel_heights = c(.25,.15,.2,.1,.3)
    ) +
      draw_plot_label(c("(more accurate)","(less accurate)"), x = 0.15, y = c(.95, .78), size = 8, vjust = 1, hjust = 1, fontface = "italic") +
      draw_plot_label(c("a","b","c","d","e"), x = 1, y = c(.95, .75, .6, .4, .3), size = 10, vjust = 1, hjust = 1), 
    x = 0, y = 0, width = 1, height = .95
  ) + 
  draw_label("Working Memory Updating", x = 0.6, y = .975, hjust = .5, vjust = 0, fontface = "bold")

