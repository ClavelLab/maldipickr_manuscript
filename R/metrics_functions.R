get_clustering_metrics<-function(all_results_clean){
  all_results_clean |>  dplyr::group_by(procedure)  |>
    dplyr::summarise(
      n_clusters = sum(to_pick),
      ARI = aricode::ARI(name, membership),
      homogeneity = clevr::homogeneity(name, membership),
      completeness = clevr::completeness(name, membership)
    )  |>  dplyr::arrange(dplyr::desc(ARI))
}