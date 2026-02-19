plot_dereplication_approaches <- function(all_results_clean) {
  design <- "
    A#
    BC
    DE
    FG
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
      data = function(x) x[x$n %in% 1:5, ],
      aes(label = n_label),
      color = "white"
    ) +
    ggplot2::geom_text(
      data = function(x) x[!x$n %in% 1:5, ],
      aes(label = n_label),
      color = "black"
    ) +
    ggplot2::scale_y_discrete(labels = scales::label_parse()) +
    ggplot2::scale_fill_viridis_d(option = "E",
      labels = c(
        "1" = "1 (absence of clustering)",
        "8" = "8 (expected clustering)"
      )
    ) +
    cowplot::theme_cowplot() +
    ggh4x::facet_manual(vars(procedure), design = design) +
    ggplot2::labs(
      x = "Clusters per mock species",
      y = "Species",
      fill = "Replicates per cluster"
    ) +
    ggplot2::theme(
      # axis.text.y = element_text(face = "italic"),
      legend.position = "inside",
      legend.position.inside = c(0.59, 0.90),
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

write_plot <- function(plot_results, path, height = 10, width = 9) {
  ggplot2::ggsave(
    path,
    plot_results,
    height = height,
    width = width,
    device = "eps",
    dpi = 350
  )
  return(path)
}

plot_linkage_min_similarity <- function(linkage_df){
  threshold_df <- linkage_df |>
    select(procedure) |>
    distinct() |> 
    tidyr::separate_wider_delim(
      procedure, "_",
      names = c(NA,NA,"threshold"),
      cols_remove = FALSE) |>
    mutate(threshold = as.numeric(threshold) * 0.01)
  
  linkage_df |> 
    ggplot(aes(x = method, y = min_similarity, color = method))+
    geom_violin()+
    geom_point(position = position_jitter(width = 0.1), shape = 23)+
    geom_hline(data = threshold_df, aes(yintercept = threshold), linetype = "dashed")+
    geom_text(data = threshold_df, aes(y = threshold, label = threshold, x = 0.5),
              vjust = -1,hjust = 0, color = "black")+
    labs(x = "Clustering linkage", y = "Minimum similarity per cluster",
         color = "Clustering linkage")+
    theme_cowplot()+
    scale_color_okabe_ito()+
    facet_wrap(~procedure, nrow = 2)+
    theme(legend.position = "bottom")
}

plot_dendrogram <- function(sim_matrix, all_results, path){
  hc<-hclust(as.dist(1-sim_matrix), method = "complete")
  dend <- as.dendrogram(hc)
  
  spectra2species <- all_results |>
    dplyr::filter(procedure =="maldipickr (loose)") |>
    dplyr::select(name,species, strain_identifier) |>
    dplyr::distinct() |> dplyr::select(name, species) |> tibble::deframe()
  
  
  new_labs <- paste(
    spectra2species[labels(dend)], 
    labels(dend)
  )
  
  jpeg(filename = path, width = 7, height = 10, units = "in", res = 350)
  par(mar=c(3,1,1,18))
  dend |> 
    set("labels", new_labs) |> 
    set("labels_cex", 0.7) |>  
    plot(horiz = T)
  abline(v = 1- c(0.79,0.92), lty = c("dashed", "solid"),col = "grey40")
  text(x = 1- c(0.79,0.92), y = 80, labels = c("0.79", "0.92"),
       pos = 2,offset = 0.2)
  dev.off()
  return(path)
}