# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
library(tibble)
here::here("_targets.R")

# Set target options:
tar_option_set(
  packages = c("maldipickr", "tidyverse", "coop", "cowplot","ggokabeito"),
  # packages that your targets need to run
  format = "qs", # default storage format
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()


#
# maldipickr workflow
#
thresholds_maldipickr <- tibble(method = "maldipickr", threshold = c(79, 92))
targets_maldipickr <- tar_map(
  unlist = FALSE,
  thresholds_maldipickr,
  tar_target(
    df_interpolated,
    delineate_with_similarity(sim_interpolated, threshold = threshold * 0.01)
  ),
  tar_target(
    clusters,
    set_reference_spectra(df_interpolated, processed$metadata)
  ),
  tar_target(picked, pick_spectra(clusters)),
  tar_target(
    results,
    picked |>
      dplyr::select(name, membership, to_pick) |>
      dplyr::mutate(procedure = paste(method, threshold, sep = "_"))
  )
)

#
# SPeDE workflow
#
thresholds_spede <- tibble(method = "SPeDE", threshold = c(20, 50))
targets_spede <- tar_map(
  unlist = FALSE,
  thresholds_spede,
  tar_file(
    spede,
    run_spede(
      spede_code,
      spede_peaks,
      spede_regrids,
      here::here("data", paste(method, threshold, sep = "_")),
      local_threshold = threshold
    )
  ),
  tar_target(import, import_spede_clusters(spede)),
  tar_target(picked, pick_spectra(import)),
  tar_target(
    results,
    picked |>
      dplyr::select(name, membership, to_pick) |>
      dplyr::mutate(procedure = paste(method, threshold, sep = "_"))
  )
)

#
# Biotyper workflow
#
targets_biotyper <- tar_map(
  unlist = FALSE,
  tibble(method = "Biotyper"),
  tar_url(
    raw_biotyper_report,
    "https://zenodo.org/records/15658442/files/230328-1404-1001000371.csv?download=1"
  ),
  tar_target(
    biotyper_report,
    read_biotyper_report(raw_biotyper_report)
  ),
  tar_target(
    biotyper_report_clean,
    filter_identification(biotyper_report) |>
      clean_biotyper_names()
  ),
  tar_target(
    picked,
    delineate_with_identification(biotyper_report_clean) |>
      pick_spectra(biotyper_report_clean, criteria_column = "bruker_log")
  ),
  tar_target(
    results,
    picked |>
      dplyr::select(name, membership, to_pick) |>
      dplyr::mutate(procedure = method)
  )
)

#
# IDBac workflow
#
targets_idbac <- tar_map(
  unlist = FALSE,
  tibble(method = c("IDBacPresence", "IDBacCosine"), threshold = 65),
  tar_target(
    sim_interpolated, get_idbac_matrix(method)
  ),
  tar_target(
    df_interpolated,
    delineate_with_similarity(sim_interpolated, threshold = threshold * 0.01)
  ),
  tar_target(
    picked, 
    format_idbac_results(df_interpolated)
  ),
  tar_target(
    results,
    picked |>
      dplyr::select(name, membership, to_pick) |>
      dplyr::mutate(procedure = paste(method, threshold, sep = "_"))
  )
)

#
# Reanalysis Asare et al. 2023 data
#
targets_asare_data <- tar_map(
  unlist = FALSE,
  tibble(method = c("Asare")),
  tar_file(
    clostritof_spectra_archive,
    get_asare_data("Library_strains_142x.zip")
  ),
  tar_target(
    clostritof_spectra_dir, 
    extract_raw_data(clostritof_spectra_archive)
  ),
  tar_target(
    spectra_raw,
    import_biotyper_spectra(clostritof_spectra_dir) %>% suppressWarnings()
  ),
  tar_target(
    checks,
    check_spectra(spectra_raw, tolerance = 20)
  ),
  tar_target( # Filter-out non empty spectra and unusual spectra
    spectra_raw_noempty,
    remove_spectra(spectra_raw, checks)
  ),
  tar_target(
    spectra_names,
    get_spectra_names(spectra_raw_noempty)
  ),
  tar_target(
    clostritof_tax_all,
    get_asare_taxonomy(spectra_names)
  ),
  tar_target(
    valid_tax_spectra,
    spectra_raw_noempty[clostritof_tax_all$valid_taxonomy]
  ),
  tar_target(
    sanitized_names,
    get_spectra_names(valid_tax_spectra) %>% dplyr::mutate(sanitized_name = base::make.unique(sanitized_name))
  ),
  tar_target(
    processed,
    process_spectra(valid_tax_spectra, spectra_names = sanitized_names)
  ),
  tar_target(
    fm_interpolated,
    merge_processed_spectra(list(processed))
  ),
  tar_target(
    sim_interpolated,
    coop::tcosine(fm_interpolated)
  )
)

targets_asare <- tar_map(
  unlist = FALSE,
  tibble(method = "Asare_maldipickr", threshold = c(79, 92)),
  tar_target(
    df_interpolated,
    delineate_with_similarity(sim_interpolated_Asare, threshold = threshold * 0.01)
  ),
  tar_target(
    clusters,
    set_reference_spectra(df_interpolated, processed_Asare$metadata)
  ),
  tar_target(picked, pick_spectra(clusters)),
  tar_target(
    results,
    picked |>
      dplyr::select(name, membership, to_pick) |>
      dplyr::mutate(procedure = paste(method, threshold, sep = "_"))
  ),
  tar_target(
    linkage,
    evaluate_linkage(sim_interpolated_Asare, threshold = threshold * 0.01) |>
      dplyr::mutate(procedure = paste(method, threshold, sep = "_"))
  ),
  tar_target(
    total_clusters,
    get_total_clusters(linkage) |>
      dplyr::mutate(procedure = paste(method, threshold, sep = "_"))
  )
)

# Overall combined workflow
list(
  tar_file(
    raw_data_archive,
    get_raw_data()
  ),
  tar_file(
    raw_data,
    extract_raw_data(raw_data_archive)
  ),
  tar_target(
    spectra_raw,
    import_biotyper_spectra(raw_data)
  ),
  tar_target(
    checks,
    check_spectra(spectra_raw)
  ),
  tar_target(
    spectra_raw_noempty,
    remove_spectra(spectra_raw, checks)
  ),
  tar_target(
    processed,
    process_spectra(spectra_raw_noempty)
  ),
  tar_target(
    fm_interpolated,
    merge_processed_spectra(list(processed))
  ),
  tar_target(
    sim_interpolated,
    coop::tcosine(fm_interpolated)
  ),
  targets_maldipickr,
  tar_target(
    spede_export,
    export_for_spede(
      spectra_raw_noempty,
      here::here("raw_data", "export_for_spede")
    )
  ),
  tar_file(
    spede_archive,
    get_spede()
  ),
  tar_file(
    spede_code,
    extract_spede(spede_archive)
  ),
  tar_file(
    spede_peaks,
    spede_peak(
      spede_code,
      spede_export,
      "spede_peaks"
    )
  ),
  tar_file(
    spede_regrids,
    spede_regrid(
      spede_code,
      spede_export,
      "spede_regrid"
    )
  ),
  targets_spede,
  targets_biotyper,
  tar_target(
    idbac_export,
    export_for_idbac(
      spectra_raw_noempty,
      here::here("raw_data", "export_for_idbac")
    )
  ),
  targets_idbac,
  tar_url(
    isolate_table_file,
    "https://zenodo.org/records/15744631/files/TableS1_isolates.csv?download=1"
  ),
  tar_target(
    isolate_table,
    read_clean_isolate_table(isolate_table_file)
  ),
  tarchetypes::tar_combine(
    all_results,
    targets_maldipickr[["results"]],
    targets_spede[["results"]],
    targets_biotyper[["results"]],
    targets_idbac[["results"]],
    command = bind_rows(!!!.x)
  ),
  tar_target(
    all_results_clean,
    merge_and_clean_results(all_results, isolate_table)
  ),
  tar_target(
    clustering_metrics,
    get_clustering_metrics(all_results_clean, "strain_identifier")
  ),
  tar_file(
    metrics_results_tableS2,
    write_clustering_metrics(
      clustering_metrics,
      here::here("TableS2_clustering_metrics.csv")
    )
  ),
  tar_file(
    clustering_results_tableS3,
    write_clustering_results(
      all_results_clean,
      here::here("TableS3_clustering_results.csv")
    )
  ),
  tar_target(
    plot_dereplication,
    plot_dereplication_approaches(all_results_clean)
  ),
  tar_file(
    plot_dereplication_file,
    write_plot(plot_dereplication, here::here("Figure1.eps"))
  ),
  targets_asare_data,
  targets_asare,
  tar_combine(
    all_asare,
    targets_asare[["results"]],
    command = bind_rows(!!!.x)
  ),
  tar_target(
    all_asare_clean,
    all_asare |>
      dplyr::left_join(clostritof_tax_all_Asare,
                       by = c("name" = "sanitized_name")) |> 
      dplyr::select(-valid_taxonomy)
  ),
  tar_target(
    clustering_metrics_asare,
    bind_rows(
      get_clustering_metrics(all_asare_clean, "species") |> mutate(level = "species"),
      get_clustering_metrics(all_asare_clean, "strain") |> mutate(level = "strain")
    ) |> relocate(level,.after = n_clusters) |> 
      arrange(level,procedure)
  ),
  tar_file(
    metrics_results_tableS4,
    write_clustering_metrics(
      clustering_metrics_asare,
      here::here("TableS4_clustering_metrics_Asare.csv")
    )
  ),
  tar_file(
    clustering_results_tableS5,
    write_clustering_results_asare(
      all_asare_clean,
      here::here("TableS5_clustering_results_Asare.csv")
    )
  ),
  tar_target(
    summary_asare,
    summary_dataset_asare(clostritof_tax_all_Asare)
  ),
  tar_combine(
    total_clusters_asare,
    targets_asare[["total_clusters"]],
    command = bind_rows(!!!.x)
  ),
  tar_file(
    total_clusters_linkage_tableS6,
    write_total_clusters_asare(
      total_clusters_asare,
      here::here("TableS6_total_clusters_linkage_Asare.csv")
    )
  ),
  tar_combine(
    linkage_asare,
    targets_asare[["linkage"]],
    command = bind_rows(!!!.x)
  ),
  tar_target(
    plot_linkage,
    plot_linkage_min_similarity(linkage_asare)
  ),
  tar_file(
    plot_linkage_file,
    write_plot(plot_linkage, here::here("FigureS1.eps"), 9,6)
  )
)
