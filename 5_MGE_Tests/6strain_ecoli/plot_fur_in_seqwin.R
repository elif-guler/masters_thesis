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

  input_file <- file.path(
    clade,
    "fur_in_seqwin.csv"
  )

  if (!file.exists(input_file)) {
    next
  }

  dat <- read.csv(
    input_file,
    stringsAsFactors = FALSE
  )

  if (nrow(dat) == 0) {
    next
  }

  dat <- dat %>%
    filter(found == 1)

  if (nrow(dat) == 0) {
    next
  }

  dat$clade <- clade_labels[clade]

  all_data[[clade]] <- dat
}

all_data <- bind_rows(all_data)

all_data$clade <- factor(
  all_data$clade,
  levels = unname(clade_labels)
)

p <- ggplot(
  all_data,
  aes(
    x = coverage,
    y = identity
  )
) +
  geom_point(
    size = 1.2,
    alpha = 0.65
  ) +
  facet_wrap(
    ~ clade,
    nrow = 1
  ) +
  scale_x_continuous(
    limits = c(0, 1),
    breaks = c(0, 0.25, 0.5, 0.75, 1)
  ) +
  scale_y_continuous(
    limits = c(0.8, 1.01),
    breaks = c(0.8, 0.9, 1.0)
  ) +
  labs(
    x = "Coverage",
    y = "Identity"
  ) +
  theme_thesis()

save_thesis_plot(
  p,
  "fur_markers_in_seqwin.pdf",
  width = 16,
  height = 4.5
)
