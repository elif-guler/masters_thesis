library(ggplot2)

theme_thesis <- function() {

  theme_bw(base_size = 14) +

    theme(

      # -------------------------
      # Grid
      # -------------------------

      panel.grid.major = element_line(
        colour = "grey85",
        linewidth = 0.4
      ),

      panel.grid.minor = element_blank(),

      panel.border = element_rect(
        colour = "black",
        fill = NA,
        linewidth = 0.7
      ),

      # -------------------------
      # Facet labels
      # -------------------------

      strip.background = element_rect(
        fill = "grey95",
        colour = "black",
        linewidth = 0.6
      ),

      strip.text = element_text(
        size = 14,
        face = "bold"
      ),

      # -------------------------
      # Axis titles
      # -------------------------

      axis.title = element_text(
        size = 15,
        face = "bold"
      ),

      # -------------------------
      # Axis numbers
      # -------------------------

      axis.text = element_text(
        size = 13,
        colour = "black"
      ),

      # -------------------------
      # Axis ticks
      # -------------------------

      axis.ticks = element_line(
        colour = "black",
        linewidth = 0.6
      ),

      axis.ticks.length = unit(
        4,
        "pt"
      ),

      # -------------------------
      # Plot title
      # -------------------------

      plot.title = element_text(
        size = 17,
        face = "bold",
        hjust = 0.5
      ),

      # -------------------------
      # Legend
      # -------------------------

      legend.position = "top",

      legend.title = element_text(
        size = 14
      ),

      legend.text = element_text(
        size = 13
      ),

      # -------------------------
      # Spacing between facets
      # -------------------------

      panel.spacing = unit(
        0.8,
        "lines"
      ),

      # -------------------------
      # Margins
      # -------------------------

      plot.margin = margin(
        12,
        12,
        12,
        12
      )
    )
}


save_thesis_plot <- function(
    plot,
    filename,
    width,
    height
) {

  ggsave(
    filename = filename,
    plot = plot,
    width = width,
    height = height,
    units = "in",
    device = cairo_pdf,
    bg = "white"
  )
}
