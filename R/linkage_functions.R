
get_min_similarities_of_cluster <- function(
    hierarchical_clustering,
    threshold,
    similarity_matrix){
  # Get groups
  memberships <- cutree(hierarchical_clustering, h = threshold)
  groups <- split(names(memberships), memberships)
  
  # Keep only the similarities of clusters with more than 1 member
  min_similarities <- sapply(
    groups, function(x) min(similarity_matrix[x,x])
  )
  
  # create tibble
  stack(min_similarities) |> 
    as_tibble() |> 
    dplyr::rename(
      c("min_similarity" = "values",
        "membership" = "ind")
    )
}

evaluate_linkage <- function(similarity_matrix, threshold){
  # as distance
  dist_matrix <- as.dist(1 - similarity_matrix) 
  clustering_results<-tibble::tibble(
    method = c("ward.D", "single", "complete",
               "average", "mcquitty", "ward.D2")) |> 
    mutate(
      clustering = purrr::map(method,\(x) hclust(dist_matrix, method = x)),
      data = purrr::map(
        clustering,
        \(x) get_min_similarities_of_cluster(x,1-threshold,similarity_matrix))
    )
  
  clustering_results |>
    select(-clustering) |> 
    unnest(data)
}

get_total_clusters <- function(linkage_df){
  linkage_df |>
    group_by(method) |>
    summarise(
      total = n(),
      singleton = sum(min_similarity == 1)
    )# |>
    # pivot_longer(!method) |>
    # mutate(
    #   method = forcats::as_factor(method),
    #   method = forcats::fct_reorder(method,value, .fun = max)
    # )
}