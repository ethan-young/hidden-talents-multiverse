# Packages ----------------------------------------------------------------
library(tidyverse)
library(cowplot)
library(see)
library(gt)
library(psych)
library(lme4)
library(performance)

# ggplot2 theme -----------------------------------------------------------
theme_set(
  theme_bw() +
    theme(
      axis.line.y       = element_line(),
      axis.text.y       = element_text(size = rel(.75)),
      axis.title.y      = element_text(size = rel(.80), margin = margin(1,0,0,0,"lines")),
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

pval_colors <- c("pos-sig" = "#334257", "non" = "gray70")
my_alphas <- c(.5, 1)
my_limits <- c(1,70)

# get data ----------------------------------------------------------------
load("multiverse-objects/2-primary-analyses/3-extracted-effects.Rdata")
load("multiverse-objects/2-primary-analyses/5-bootstrapped-effects.Rdata")
source("manuscript/scripts/figure-2-3.R")

# For presentations and posters -------------------------------------------
fig2_simple <- 
  ggdraw() +
  draw_plot(
    plot_grid(
      spec_curves[[1]]$interactions + theme(panel.background = element_blank(), plot.background = element_blank()),
      spec_curves[[1]]$p_curve + theme(panel.background = element_blank(), plot.background = element_blank()),
      nrow  = 2,
      ncol  = 1, 
      align = "v", 
      axis  = "lr",
      rel_heights = c(.6, .4)
    ) +
      draw_plot_label(c("faster","slower"), x = 0.065, y = c(.885, .475), size = 7, vjust = 1, hjust = 1, fontface = "italic"),
    x = 0, y = 0, width = 1, height = 1
  ) 

fig3_simple <- 
  ggdraw() +
  draw_plot(
    plot_grid(
      spec_curves[[2]]$interactions,
      spec_curves[[2]]$p_curve,
      nrow  = 2,
      ncol  = 1, 
      align = "v", 
      axis  = "lr",
      rel_heights = c(.6, .4)
    ) +
      draw_plot_label(c("more\naccurate","less\naccurate"), x = 0.04, y = c(.95, .465), size = 7, vjust = 1, hjust = .5, fontface = "italic"),
    x = 0, y = 0, width = 1, height = 1
  )

sysfonts::font_add_google("Lato")
showtext::showtext_auto()

fig_2_3 <- 
  ggdraw() +
  draw_plot(
    plot_grid(
      spec_curves[[1]]$interactions + 
        stat_summary(
          aes(x = group_adj, y = predicted, group = x), 
          geom = "line", 
          fun = "median", 
          color = "white", 
          alpha = 1,
          size = 1,
          show.legend = F
        ) +
        stat_summary(
          aes(x = group_adj, y = predicted, group = x, fill = x),
          geom = "point", 
          fun = "median", 
          color = "white", 
          shape = 21,
          stroke = 1, 
          alpha = 1,
          size = 2, 
          show.legend = T
        ) +
        geom_boxplot(
          aes(x = group_bx, y = predicted, group = interaction(x,group), fill = x),
          fatten = 1,
          color = "white",
          position = position_identity(), 
          width = .1, 
          inherit.aes = F, 
          show.legend = F
        ) +
        scale_fill_manual("Adversity", values = c("#7BA6CC", "#F0882D")) +
        scale_color_manual(values = c("#334257","#334257")) +
        scale_alpha_manual(values = c(1,1)) +
        ggtitle("Attention Shifting\n") + 
        theme(
          text              = element_text(family = "Lato", color = "white"),
          line              = element_line(color = "white"),
          axis.text         = element_text(size = rel(1.15), color = "white"),
          axis.ticks        = element_line(color = "white"), 
          legend.background = element_blank(),
          legend.key        = element_blank(),
          panel.background  = element_blank(),
          plot.background   = element_blank(),
          plot.title        = element_text(hjust = 0.5, size = rel(1.75)),
          plot.margin       = margin(1,1,1,1, unit = "lines"),
          strip.text        = element_text(color = "white") 
        ),
      spec_curves[[2]]$interactions + 
        stat_summary(
          aes(x = group_adj, y = predicted, group = x), 
          geom = "line", 
          fun = "median", 
          color = "white", 
          alpha = 1,
          size = 1,
          show.legend = F
        ) +
        stat_summary(
          aes(x = group_adj, y = predicted, group = x, fill = x),
          geom = "point", 
          fun = "median", 
          color = "white", 
          shape = 21,
          stroke = 1, 
          alpha = 1,
          size = 2, 
          show.legend = T
        ) +
        geom_boxplot(
          aes(x = group_bx, y = predicted, group = interaction(x,group), fill = x),
          fatten = 1,
          color = "white",
          position = position_identity(), 
          width = .1, 
          inherit.aes = F, 
          show.legend = F
        ) +
        scale_fill_manual("Adversity", values = c("#7BA6CC", "#F0882D")) +
        scale_color_manual(values = c("#334257","#334257")) +
        scale_alpha_manual(values = c(1,1)) +
        ggtitle("Working Memory Updating\n") + 
        theme(
          text              = element_text(family = "Lato", color = "white"),
          line              = element_line(color = "white"),
          axis.text         = element_text(size = rel(1.15), color = "white"),
          axis.ticks        = element_line(color = "white"), 
          legend.background = element_blank(),
          legend.key        = element_blank(),
          panel.background  = element_blank(),
          plot.background   = element_blank(),
          plot.title        = element_text(hjust = 0.5, size = rel(1.75)),
          plot.margin       = margin(1,1,1,1, unit = "lines"),
          strip.text        = element_text(color = "white") 
        ),
      nrow  = 2,
      ncol  = 1, 
      align = "v", 
      axis  = "lr",
      rel_heights = c(.5, .5)
    ) +
      draw_plot_label(c("more\naccurate","less\naccurate"),  x = 0.03, y = c(.33, .07), size = 7, vjust = 1, hjust = .5, color = "white") +
      draw_plot_label(c("faster","slower"), x = 0.035, y = c(.81, .565), size = 7, vjust = 1, hjust = .5, color="white"),
    x = 0, y = 0, width = 1, height = 1
  )

fig_2_3_specs <- 
  ggdraw() +
  draw_plot(
    plot_grid(
      spec_curves[[2]]$p_curve +
        theme(
          text = element_text(family = "Lato"),
          axis.text = element_text(size = rel(1)),
          axis.text.y = element_blank(),
          axis.title.y = element_blank(),
          plot.title = element_text(color = NA, size = rel(1.3)),
        ),
      spec_curves[[2]]$eff_curve +
        scale_y_continuous("Beta",limits = c(-.12,.12)) +
        theme(
          text = element_text(family = "Lato"),
          axis.text = element_text(size = rel(1)),
          axis.text.y = element_blank(),
          axis.title.y = element_blank(),
          plot.title = element_text(color = NA, size = rel(1.3)),
        ),
      spec_curves[[2]]$sample_sizes +
        theme(
          text = element_text(family = "Lato"),
          axis.text = element_text(size = rel(1)),
          axis.text.y = element_blank(),
          axis.title.y = element_blank(),
          plot.title = element_text(color = NA, size = rel(1.3)),
        ),
      spec_curves[[2]]$spec_grid +
        theme(
          text = element_text(family = "Lato"),
          axis.text = element_text(size = rel(1)),
          axis.text.y = element_text(color = NA, size = rel(1)),
          plot.title = element_text(color = NA, size = rel(1.3)),
        ),
      nrow  = 4,
      ncol  = 1,
      byrow = F,
      align = "hv", 
      axis  = "lr",
      rel_heights = c(.2,.2,.2,.4)
    ),
    x = .35, 
    y = 0, 
    width = .5, 
    height = 1
  ) +
  draw_plot(
    plot_grid(
      spec_curves[[1]]$p_curve +
        theme(
          text = element_text(family = "Lato"),
          axis.text = element_text(size = rel(1)),
          plot.title = element_text(size = rel(1.3))
        ),
      spec_curves[[1]]$eff_curve +
        scale_y_continuous("Beta",limits = c(-.12,.12)) +
        theme(
          text = element_text(family = "Lato"),
          axis.text = element_text(size = rel(1)),
          plot.title = element_text(size = rel(1.3))
        ),
      spec_curves[[1]]$sample_sizes +
        theme(
          text = element_text(family = "Lato"),
          axis.text = element_text(size = rel(1)),
          plot.title = element_text(size = rel(1.3))
        ),
      spec_curves[[1]]$spec_grid +
        theme(
          text = element_text(family = "Lato"),
          axis.text = element_text(size = rel(1)),
          plot.title = element_text(size = rel(1.3))
        ),
      nrow  = 4,
      ncol  = 1,
      byrow = F,
      align = "hv", 
      axis  = "lr",
      rel_heights = c(.2,.2,.2,.4)
    ),
    x = 0,
    y = 0,
    width = .5,
    height = 1
  )


# save files --------------------------------------------------------------
ggsave(filename = "manuscript/figures/fig2_simple.jpg", fig2_simple, width = 6.5, height = 4, dpi = 600)
ggsave(filename = "manuscript/figures/fig2_simple.pdf", fig2_simple, width = 6.5, height = 4, dpi = 600)

ggsave(filename = "manuscript/figures/fig3_simple.jpg", fig3_simple, width = 6.5, height = 4, dpi = 600)
ggsave(filename = "manuscript/figures/fig3_simple.pdf", fig3_simple, width = 6.5, height = 4, dpi = 600)

ggsave(filename = "manuscript/figures/fig2_3_simple.pdf", fig_2_3, width = 6.5, height = 5.5, dpi = 600)
ggsave(filename = "manuscript/figures/fig2_3_specs.pdf", fig_2_3_specs, width = 12, height = 6.5, dpi = 600)
