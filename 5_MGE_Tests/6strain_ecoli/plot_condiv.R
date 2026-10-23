library(ggplot2)
library(dplyr)

source("plot_theme.R")

clades <- c("a", "b1", "b2", "d", "e", "f")

clade_labels <- c(
  a  = "Clade A",
  b1 = "Clade B1",
  b2 = "Clade B2",
  d  = "Clade D",
  e  = "Clade E",
  f  = "Clade F"
)

all_data <- list()

for (clade in clades) {

  # -------------------------
  # SeqWin
  # -------------------------

  seqwin_file <- file.path(
    clade,
    "cons_div_seqwin_e5.csv"
  )

  if (file.exists(seqwin_file)) {

    seqwin <- read.csv(
      seqwin_file,
      stringsAsFactors = FALSE
    )

    if (nrow(seqwin) > 0) {

      seqwin$tool <- "SeqWin"
      seqwin$clade <- clade_labels[clade]

      all_data[[paste0(clade, "_seqwin")]] <- seqwin
    }
  }

  # -------------------------
  # Fur
  # -------------------------

  fur_file <- file.path(
    clade,
    "cons_div_fur_e5.csv"
  )

  if (file.exists(fur_file)) {

    fur <- read.csv(
      fur_file,
      stringsAsFactors = FALSE
    )

    if (nrow(fur) > 0) {

      fur$tool <- "Fur"
      fur$clade <- clade_labels[clade]

      all_data[[paste0(clade, "_fur")]] <- fur
    }
  }
}

all_data <- bind_rows(all_data)

all_data$tool <- factor(
  all_data$tool,
  levels = c("SeqWin", "Fur")
)

all_data$clade <- factor(
  all_data$clade,
  levels = unname(clade_labels)
)

p <- ggplot(
  all_data,
  aes(
    x = fraction_nontarget_hit,
    y = divergence
  )
) +

  geom_point(
    size = 1.4,
    alpha = 0.50
  ) +

  facet_grid(
    tool ~ clade
  ) +

  scale_x_continuous(
    limits = c(0, 1),
    breaks = c(0, 0.25, 0.5, 0.75, 1)
  ) +

  scale_y_continuous(
    limits = c(0, 0.30),
    breaks = c(0, 0.1, 0.2, 0.3)
  ) +

  labs(
    x = "Non-target hit fraction",
    y = "Divergence"
  ) +

  theme_thesis() +

  theme(

    # Facet labels
    strip.text = element_text(
      size = 15,
      face = "bold"
    ),

    # Axis titles
    axis.title.x = element_text(
      size = 16,
      face = "bold",
      margin = margin(
        t = 10
      )
    ),

    axis.title.y = element_text(
      size = 16,
      face = "bold",
      margin = margin(
        r = 10
      )
    ),

    # Axis numbers
    axis.text.x = element_text(
      size = 13
    ),

    axis.text.y = element_text(
      size = 13
    ),

    # Slightly more space between panels
    panel.spacing = unit(
      1,
      "lines"
    )
  )

save_thesis_plot(
  p,
  "divergence_vs_nontarget_hit.pdf",
  width = 16,
  height = 7
)