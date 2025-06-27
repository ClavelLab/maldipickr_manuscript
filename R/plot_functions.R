plot_dereplication_approaches <- function(all_results_clean) {
  design <- "
    A#
    BC
    DE
  "

  p <- all_results_clean |>
    dplyr::count(procedure, species_label, membership) |>
    # mutate(species_label = forcats::as_factor(species_label) |> forcats::fct_rev()
    # )|>
    dplyr::arrange(procedure, species_label, dplyr::desc(n)) |>
    dplyr::group_by(procedure, species_label) |>
    dplyr::mutate(new_order = 1:dplyr::n()) |>
    dplyr::ungroup() |>
    dplyr::group_by(procedure, membership) |>
    dplyr::add_count(name = "n_within_cluster") |>
    dplyr::mutate(
      n_label = dplyr::if_else(
        n_within_cluster > 1,
        paste0(n, "*"),
        as.character(n)
      )
    ) |>
    dplyr::ungroup() |>
    dplyr::select(-n_within_cluster) |>
    ggplot2::ggplot(aes(
      x = as.character(new_order),
      y = species_label,
      fill = as.character(n)
    )) +
    ggplot2::geom_tile(color = "white", linewidth = 0.7) +
    ggplot2::geom_text(
      data = function(x) x[x$n %in% c(1, 2, 5), ],
      aes(label = n_label),
      color = "white"
    ) +
    ggplot2::geom_text(
      data = function(x) x[!x$n %in% c(1, 2, 5), ],
      aes(label = n_label),
      color = "black"
    ) +
    ggplot2::scale_y_discrete(labels = scales::label_parse()) +
    ggplot2::scale_fill_manual(
      values = c(
        "#000000FF",
        "#440154FF",
        "#2A788EFF",
        "#22A884FF",
        "#7AD151FF"
      ),
      labels = c(
        "1" = "1 (absence of clustering)",
        "8" = "8 (expected clustering)"
      )
    ) +
    cowplot::theme_cowplot() +
    ggh4x::facet_manual(vars(procedure), design = design) +
    ggplot2::labs(
      x = "Clusters per mock species",
      y = "Species in the mock community",
      fill = "Replicates per cluster"
    ) +
    ggplot2::theme(
      # axis.text.y = element_text(face = "italic"),
      legend.position = "inside",
      legend.position.inside = c(0.53, 0.85),
      strip.background = ggplot2::element_rect(fill = "gray90"),
      panel.background = ggplot2::element_rect(fill = "white"),
      plot.background = ggplot2::element_rect(fill = "white"),
      panel.grid.major.x = ggplot2::element_line(
        colour = "grey90",
        linewidth = 0.8
      )
    )
  return(p)
}

write_plot <- function(plot_results, path) {
  ggplot2::ggsave(
    path,
    plot_results,
    height = 9,
    width = 9,
    device = "eps",
    dpi = 350
  )
  return(path)
}
