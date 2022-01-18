# Analysis effect sizes ---------------------------------------------------
secondary1b_plots_data <- 
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
    pval_prop      = paste0(round(pval_prop*100,2),"% ps < .05"),
    mod_sig = ifelse(mod_sig != "non", "pos-sig", mod_sig)
  )

secondary1b_int_plots <- 
  secondary_set2_effects_points %>% 
  mutate(
    iv = factor(iv, 
                levels = c("unp_agg", "unp_interview","unp_perceived",
                           "vio_agg", "vio_neighborhood","vio_fighting",
                           "ses_agg", "ses_perceived","ses_school","ses_interview"),
                labels = c("Composite", "Interview", "Perceived",
                           "Composite", "Neighborhood","Fighting",
                           "Composite", "Perceived","School","Interview")),
    mod_sig = ifelse(mod_sig != "non", "pos-sig", mod_sig)
  )

# specification curve -----------------------------------------------------
spec_curves2 <- 
  map(c("Attention-Shifting","Working Memory Updating"), function(x){
    
    # Setup
    dv_which <- x
    
    map(c("Unpredictability", "Violence", "SES"), function(y){
      
      effs <- 
        secondary1b_plots_data %>% 
        filter(dv == x, iv_group == y, mod_term_group == "Interaction")
      
      medians <- 
        secondary1b_plots_data %>% 
        filter(dv == x, iv_group == y, mod_term_group == "Interaction") 
      
      spec_grid_data <- 
        effs %>% 
        select(iv, dv, starts_with("spec"), mod_p.value, mod_sig) %>% 
        pivot_longer(cols = spec_sub_sample:spec_shifting, names_to = "spec_var", values_to = "spec_value") %>% 
        ungroup()
      
      int_points <- 
        secondary1b_int_plots %>% 
        filter(dv == dv_which, iv_group == y) %>%
        mutate(
          predicted = ifelse(dv == "Working Memory Updating", predicted*100, predicted),
          dv        = ifelse(dv == "Working Memory Updating", "WM Updating", dv),
          dv        = ifelse(dv == "Attention-Shifting", paste(dv,"(ms)\n"), paste(dv,"(% correct)\n")),
          x         = ifelse(iv_group == "SES", x *-1, x),
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
          nudge_y = .03,
          size = 2.5,
          show.legend = F,
          inherit.aes = F
        ) +
        scale_x_continuous("Specification Rank", limits = my_limits) + 
        scale_y_continuous(expression(beta)) +
        scale_color_manual(values = pval_colors) +
        scale_fill_manual(values = pval_colors) +
        facet_wrap(~iv, nrow = 1) +
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
        facet_wrap(~iv, nrow = 1) +
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
        facet_wrap(~iv, nrow = 1, labeller = label_parsed) +
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
        facet_wrap(~iv, nrow = 1) +
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
      
      if(y == "SES" & dv_which == "Attention-Shifting"){
        int_plots <- 
          int_plots +
            theme(legend.position = c(.2,.8))
      }
      
      if(y == "SES" & dv_which == "Working Memory Updating"){
        int_plots <- 
          int_plots +
            theme(legend.position = c(.2,.2))
      }
      
      list(
        eff_curve    = eff_curve,
        sample_sizes = sample_sizes,
        spec_grid    = spec_grid,
        p_curve      = p_curve,
        interactions = int_plots
      )
    })
  })

# Put them together -------------------------------------------------------
unp_shifting <- 
  plot_grid(
    spec_curves2[[1]][[1]]$interactions,
    spec_curves2[[1]][[1]]$p_curve,
    spec_curves2[[1]][[1]]$eff_curve,
    spec_curves2[[1]][[1]]$sample_sizes,
    spec_curves2[[1]][[1]]$spec_grid,
    nrow  = 5,
    ncol  = 1, 
    align = "v", 
    axis  = "lr",
    rel_heights = c(.25,.15,.2,.1,.3)
  ) +
  draw_plot_label(c("(faster)","(slower)"), x = 0.15, y = c(.95, .78), size = 8, vjust = 1, hjust = 1, fontface = "italic")

unp_updating <- 
  plot_grid(
    spec_curves2[[2]][[1]]$interactions,
    spec_curves2[[2]][[1]]$p_curve,
    spec_curves2[[2]][[1]]$eff_curve,
    spec_curves2[[2]][[1]]$sample_sizes,
    spec_curves2[[2]][[1]]$spec_grid,
    nrow  = 5,
    ncol  = 1, 
    align = "v", 
    axis  = "lr",
    rel_heights = c(.25,.15,.2,.1,.3)
  ) +
  draw_plot_label(c("(more accurate)","(less accurate)"), x = 0.15, y = c(.95, .78), size = 8, vjust = 1, hjust = 1, fontface = "italic")

# Violence ----------------------------------------------------------------
vio_shifting <- 
  plot_grid(
    spec_curves2[[1]][[2]]$interactions,
    spec_curves2[[1]][[2]]$p_curve,
    spec_curves2[[1]][[2]]$eff_curve,
    spec_curves2[[1]][[2]]$sample_sizes,
    spec_curves2[[1]][[2]]$spec_grid,
    nrow  = 5,
    ncol  = 1, 
    align = "v", 
    axis  = "lr",
    rel_heights = c(.25,.15,.2,.1,.3)
  ) +
  draw_plot_label(c("(faster)","(slower)"), x = 0.15, y = c(.95, .78), size = 8, vjust = 1, hjust = 1, fontface = "italic")

vio_updating <- 
  plot_grid(
    spec_curves2[[2]][[2]]$interactions,
    spec_curves2[[2]][[2]]$p_curve,
    spec_curves2[[2]][[2]]$eff_curve,
    spec_curves2[[2]][[2]]$sample_sizes,
    spec_curves2[[2]][[2]]$spec_grid,
    nrow  = 5,
    ncol  = 1, 
    align = "v", 
    axis  = "lr",
    rel_heights = c(.25,.15,.2,.1,.3)
  ) +
  draw_plot_label(c("(more accurate)","(less accurate)"), x = 0.15, y = c(.95, .78), size = 8, vjust = 1, hjust = 1, fontface = "italic")

# SES  --------------------------------------------------------------------
ses_shifting <- 
  plot_grid(
    spec_curves2[[1]][[3]]$interactions,
    spec_curves2[[1]][[3]]$p_curve,
    spec_curves2[[1]][[3]]$eff_curve,
    spec_curves2[[1]][[3]]$sample_sizes,
    spec_curves2[[1]][[3]]$spec_grid,
    nrow  = 5,
    ncol  = 1, 
    align = "v", 
    axis  = "lr",
    rel_heights = c(.25,.15,.2,.1,.3)
  ) +
  draw_plot_label(c("(faster)","(slower)"), x = 0.15, y = c(.95, .78), size = 8, vjust = 1, hjust = 1, fontface = "italic")

ses_updating <- 
  plot_grid(
    spec_curves2[[2]][[3]]$interactions,
    spec_curves2[[2]][[3]]$p_curve,
    spec_curves2[[2]][[3]]$eff_curve,
    spec_curves2[[2]][[3]]$sample_sizes,
    spec_curves2[[2]][[3]]$spec_grid,
    nrow  = 5,
    ncol  = 1, 
    align = "v", 
    axis  = "lr",
    rel_heights = c(.25,.15,.2,.1,.3)
  ) +
  draw_plot_label(c("(more accurate)","(less accurate)"), x = 0.15, y = c(.95, .78), size = 8, vjust = 1, hjust = 1, fontface = "italic")
