# Effects Data -----------------------------------------------------------
primary_plots_data <- 
  primary_effects_data %>% 
  filter(mod_term_group %in% c("Covariate","Task-Type","Main Effect", "Interaction")) %>% 
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
    mod_term_label = fct_reorder(mod_term_unique, mod_term_num)
  )

# Making Specification Curves -----------------------------------------------------------
spec_curves1 <- 
  map(c("Attention-Shifting","Working Memory Updating"), function(x){
    
    # Setup
    dv_which <- x
    
    map(c("Unpredictability","Violence","SES"), function(y){
      
      effs <- 
        primary_plots_data %>% 
        filter(dv == x, iv == y) %>% 
        mutate(
          hypoth = factor(hypoth, c("Exploratory", "Confirmatory")),
          mod_sig = ifelse(mod_sig != "non", "pos-sig", mod_sig)
        )
      
      medians <- 
        primary_plots_data %>% 
        filter(dv == x, iv == y) %>% 
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
          nudge_y = .075,
          size = 2.5,
          show.legend = F,
          inherit.aes = F
        ) +
        scale_x_continuous("Specification Rank", limits = my_limits) + 
        scale_y_continuous(expression(beta)) +
        scale_color_manual(values = pval_colors) +
        scale_fill_manual(values = pval_colors) +
        facet_wrap(~mod_term_label, nrow = 1) +
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
        facet_wrap(~mod_term_label, nrow = 1) +
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
        scale_color_manual(values = pval_colors) +
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
        ggplot(aes(x = mod_p.value)) +
        geom_histogram(color = "black", size = .2) +
        geom_vline(aes(xintercept = .05), linetype = "dashed", alpha = .5) +
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
        ggtitle("P-Curve") +
        facet_wrap(~mod_term_label, labeller = label_parsed, nrow = 1, scales = "free") +
        coord_cartesian(xlim = c(0,1)) +
        theme(
          axis.line.x     = element_line(),
          axis.text.x     = element_text(size = rel(.75)),
          axis.ticks.x    = element_line(),
          axis.title.x    = element_text(),
          axis.title.y    = element_text(angle = 0, vjust = .5,margin = margin(0,0.25,0,0, "lines")),
          legend.position = "none"
        )
      
      list(
        eff_curve    = eff_curve,
        sample_sizes = sample_sizes,
        spec_grid    = spec_grid,
        p_curve      = p_curve
      )
    })
  })

# Attention Shifting ------------------------------------------------------
shifting_unp <- 
  plot_grid(
    spec_curves1[[1]][[1]]$p_curve,
    spec_curves1[[1]][[1]]$eff_curve,
    spec_curves1[[1]][[1]]$sample_sizes,
    spec_curves1[[1]][[1]]$spec_grid,
    nrow  = 4,
    ncol  = 1, 
    align = "v", 
    axis  = "lr",
    rel_heights = c(.20,.35,.1,.35)
  )

shifting_vio <- 
  plot_grid(
    spec_curves1[[1]][[2]]$p_curve,
    spec_curves1[[1]][[2]]$eff_curve,
    spec_curves1[[1]][[2]]$sample_sizes,
    spec_curves1[[1]][[2]]$spec_grid,
    nrow  = 4,
    ncol  = 1, 
    align = "v", 
    axis  = "lr",
    rel_heights = c(.20,.35,.1,.35)
  )

shifting_ses <- 
  plot_grid(
    spec_curves1[[1]][[3]]$p_curve,
    spec_curves1[[1]][[3]]$eff_curve,
    spec_curves1[[1]][[3]]$sample_sizes,
    spec_curves1[[1]][[3]]$spec_grid,
    nrow  = 4,
    ncol  = 1, 
    align = "v", 
    axis  = "lr",
    rel_heights = c(.2,.35,.1,.35)
  )

# Updating ----------------------------------------------------------------
updating_unp <- 
  plot_grid(
    spec_curves1[[2]][[1]]$p_curve,
    spec_curves1[[2]][[1]]$eff_curve,
    spec_curves1[[2]][[1]]$sample_sizes,
    spec_curves1[[2]][[1]]$spec_grid,
    nrow  = 4,
    ncol  = 1, 
    align = "v", 
    axis  = "lr",
    rel_heights = c(.20,.35,.1,.35)
  )

updating_vio <- 
  plot_grid(
    spec_curves1[[2]][[2]]$p_curve,
    spec_curves1[[2]][[2]]$eff_curve,
    spec_curves1[[2]][[2]]$sample_sizes,
    spec_curves1[[2]][[2]]$spec_grid,
    nrow  = 4,
    ncol  = 1, 
    align = "v", 
    axis  = "lr",
    rel_heights = c(.20,.35,.1,.35)
  )

updating_ses <- 
  plot_grid(
    spec_curves1[[2]][[3]]$p_curve,
    spec_curves1[[2]][[3]]$eff_curve,
    spec_curves1[[2]][[3]]$sample_sizes,
    spec_curves1[[2]][[3]]$spec_grid,
    nrow  = 4,
    ncol  = 1, 
    align = "v", 
    axis  = "lr",
    rel_heights = c(.20,.35,.1,.35)
  )
