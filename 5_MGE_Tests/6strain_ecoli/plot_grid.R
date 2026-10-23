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
    "cons_div_seqwin.csv"
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
    "cons_div_fur.csv"
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
    size = 0.8,
    alpha = 0.45
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
    x = "Fraction of non-target hits",
    y = "Divergence"
  ) +
  theme_thesis()

save_thesis_plot(
  p,
  "marker_grid.pdf",
  width = 16,
  height = 6
)
