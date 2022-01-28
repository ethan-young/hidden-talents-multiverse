# Secondary effects -------------------------------------------------------
secondary1a_plot_data <- 
  secondary1a_effects_data %>% 
  mutate(
    iv = case_when(str_detect(mod_term, "ses")~"SES", str_detect(mod_term,"vio") ~ "Violence", T ~ NA_character_),
    iv = factor(iv, c("Violence","SES")),
    mod_sig = ifelse(mod_sig != "non", "pos-sig", mod_sig)
  )

# specification curve -----------------------------------------------------
spec_curves3 <- 
  map(c("Working Memory Updating"), function(x){
    
    # Setup
    dv_which <- x
    
    effs <- 
      secondary1a_plot_data %>% 
      filter(dv == x, mod_term_group == "Interaction")
    
    medians <- 
      secondary1a_plot_data %>% 
      filter(dv == x, mod_term_group == "Interaction")
    
    spec_grid_data <- 
      effs %>% 
      select(iv, dv, starts_with("spec"), mod_p.value, mod_sig) %>% 
      pivot_longer(cols = spec_sub_sample:spec_shifting, names_to = "spec_var", values_to = "spec_value") %>% 
      ungroup()
    
    int_points <- 
      secondary1a_effects_points %>% 
      mutate(
        iv        = factor(iv, c("Violence","SES")),
        predicted = ifelse(dv == "Working Memory Updating", predicted*100, predicted),
        dv        = ifelse(dv == "Working Memory Updating", "WM Updating", dv),
        dv        = ifelse(dv == "Attention-Shifting", paste(dv,"(ms)\n"), paste(dv,"(% correct)\n")),
        x         = ifelse(iv == "SES", x *-1, x),
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
      ggplot(aes(y = mod_std_coefficient, x = spec_rank, color = mod_sig)) +
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
        aes(y = median_dbl, x = 32),
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
      scale_color_manual(values = pval_colors) +
      scale_fill_manual(values = pval_colors) +
      facet_wrap(~iv) +
      ggtitle("Effect Size Curve") +
      theme(
        strip.text   = element_blank(),
        axis.title.y = element_text(angle = 0, vjust = .5,margin = margin(0,0.25,0,0, "lines"))
      )
    
    sample_sizes <- 
      effs %>% 
      ggplot(aes(x = spec_rank, y = n, color = mod_sig)) +
      geom_segment(aes(y = 0, yend = n, x = spec_rank, xend = spec_rank), show.legend = F) +
      geom_point(size = .75, shape = 19, show.legend = F) +
      scale_x_continuous(limits = my_limits) +
      scale_y_continuous(expression(italic(N))) +
      scale_color_manual(values = pval_colors) +
      facet_wrap(~iv) +
      ggtitle("Sample Sizes") +
      theme(
        strip.text   = element_blank(),
        axis.text.y  = element_text(angle = 0),
        axis.title.y = element_text(angle = 0, vjust = .5,margin = margin(0,0.25,0,0, "lines"))
      )
    
    spec_grid <- 
      spec_grid_data %>% 
      ggplot(aes(x = spec_rank, y = spec_value, color = mod_sig)) +
      geom_point(size = 4, shape = 73, show.legend = F) +
      geom_text(
        data = spec_grid_data %>% 
          group_by(iv, spec_var, spec_value) %>% 
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
      scale_color_manual(values = pval_colors) +
      facet_grid(spec_var~iv, scales = "free") +
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
      ggplot(aes(x = mod_p.value)) +
      geom_histogram(color = "black", size = .2) +
      geom_vline(aes(xintercept = .05), linetype = "dashed", alpha = .5) +
      geom_text(
        data = effs %>% group_by(iv) %>% summarize(p = unique(pval_prop), y = 15) %>% ungroup(),
        aes(x = .125, label = p, y = y),
        size = 2.25,
        hjust = 0,
        vjust = 1,
        show.legend = F,
        inherit.aes = F
      ) +
      scale_x_continuous(expression(italic(p),"-",value), expand = c(0.05,.05)) +
      scale_y_continuous("Freq", expand = c(0,.15)) +
      ggtitle("P-Curve") +
      facet_wrap(~iv, labeller = label_parsed) +
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
      ggplot(aes(x = group_jit, y = predicted, group = x_spec, color = mod_sig)) +
      geom_line(size = .5, show.legend = F) +
      geom_point_borderless(size = .75, show.legend = F) +
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
      scale_color_manual(values = pval_colors) +
      scale_fill_manual("Adversity:", labels = c("Low", "High"),values = c("white","gray60")) +
      ylab("% correct\n") +
      facet_wrap(~iv) +
      guides(color = F) +
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
        legend.position      = c(.45,.2),
        legend.title.align   = .5,
        legend.title         = element_text(size = rel(.75),margin = margin(0,0,0,0)),
        strip.text           = element_text(size = rel(1), hjust = 0.5, face = "bold", margin = margin(0,0,1,0,"lines")) 
      )
    
    list(
      eff_curve    = eff_curve,
      sample_sizes = sample_sizes,
      spec_grid    = spec_grid,
      p_curve      = p_curve,
      interactions = int_plots
    )
  })

# Put it together ---------------------------------------------------------
vio_ses_updating <- 
  plot_grid(
    spec_curves3[[1]]$interactions,
    spec_curves3[[1]]$p_curve,
    spec_curves3[[1]]$eff_curve,
    spec_curves3[[1]]$sample_sizes,
    spec_curves3[[1]]$spec_grid,
    nrow  = 5,
    ncol  = 1, 
    align = "v", 
    axis  = "lr",
    rel_heights = c(.25,.15,.2,.1,.3)
  ) +
  draw_plot_label(c("(more accurate)","(less accurate)"), x = 0.2, y = c(.95, .78), size = 8, vjust = 1, hjust = 1, fontface = "italic")