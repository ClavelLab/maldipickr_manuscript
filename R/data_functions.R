check_data_directory <- function() {
  if (!dir.exists(here::here("data"))) {
    dir.create(
      here::here("data")
    )
  }
}

get_raw_data <- function() {
  fs::dir_create(here::here("raw_data"))
  destfile <- here::here("raw_data", "230328-1404-1001000371.zip")
  curl::curl_download(
    url = "https://zenodo.org/records/15658442/files/230328-1404-1001000371.zip?download=1",
    destfile = destfile
  )
  destfile
}

extract_raw_data <- function(path_to_raw_data) {
  zip::unzip(path_to_raw_data, exdir = here::here("raw_data"))
  here::here(
    "raw_data",
    fs::path_file(path_to_raw_data) |> fs::path_ext_remove()
  )
}

export_for_spede <- function(maldi_object, output_dir) {
  fs::dir_create(output_dir)
  MALDIquantForeign::exportTab(maldi_object, path = output_dir)
  return(output_dir)
}

export_for_idbac <- function(maldi_object, output_dir) {
  fs::dir_create(output_dir)
  MALDIquantForeign::exportMzMl(maldi_object, path = output_dir)
  return(output_dir)
}

# The IDBac workflow was run via GNPS2
# https://gnps2.org/workflowinput?workflowname=idbac_analysis_workflow
# and the Query-Query matrix downloaded
get_idbac_matrix <- function(method){
  idbac_two_column_matrix <- c(
    IDBacPresence = "data/idbac_presence_distance.tsv",
    IDBacCosine = "data/idbac_cosine_distance.tsv"
  )[method]
  
  idbac <- readr::read_tsv(idbac_two_column_matrix, show_col_types = FALSE)
  idbac_m <- idbac |> 
    dplyr::mutate(
      dplyr::across(dplyr::starts_with("query"),
                    ~ stringr::str_remove(.x, ".mzML") |> stringr::str_replace_all("-","_"))
    ) |> 
    tidyr::pivot_wider(
      id_cols = query_filename_left,
      names_from = query_filename_right,
      values_from = distance
    )  |> 
    tibble::column_to_rownames("query_filename_left") |>
    as.matrix()
  return(1 - idbac_m)
}

format_idbac_results <- function(cluster_df){
  reference_df <- cluster_df |> dplyr::group_by(membership) |> 
    dplyr::arrange(dplyr::desc(name)) |> 
    dplyr::slice_head( n = 1) |> 
    dplyr::mutate(is_reference = TRUE)
  
  idbac_results <- cluster_df |> 
    dplyr::left_join(
      reference_df, 
      by = dplyr::join_by(name, membership, cluster_size)
    ) |> 
    tidyr::replace_na(replace = list("is_reference" = FALSE)) |> 
    maldipickr::pick_spectra()
}

read_clean_isolate_table <- function(isolate_table_file) {
  readr::read_csv(
    isolate_table_file,
    col_types = cols(
      species = col_character(),
      strain_identifier = col_character(),
      phylum = col_character(),
      family = col_character(),
      cultivation_media = col_character(),
      straininfo_doi = col_character(),
      spectra_identifier = col_character()
    )
  ) |>
    dplyr::mutate(
      species_label = if_else(
        species == "Lachnospira rogosae sp. nov.",
        glue::glue("italic(\"Lachnospira rogosae\")~sp.~nov."),
        glue::glue("italic(\"{species}\")")
      ) #,
    ) |>
    dplyr::select(strain_identifier, species, species_label, spectra_identifier)
}

merge_and_clean_results <- function(all_results, isolate_table) {
  spectra_name_pattern <- isolate_table$spectra_identifier |>
    paste(collapse = "|")
  all_results |>
    dplyr::mutate(
      spectra_identifier = stringr::str_extract(name, spectra_name_pattern)
    ) |>
    dplyr::left_join(isolate_table, by = "spectra_identifier") |>
    dplyr::mutate(
      species_label = as.factor(species_label) |> forcats::fct_rev(),
      procedure = factor(
        procedure,
        levels = c(
          "maldipickr_79",
          "maldipickr_92",
          "SPeDE_20",
          "SPeDE_50",
          "IDBacCosine_65",
          "IDBacPresence_65",
          "Biotyper"
        ),
        ordered = T
      ) |>
        fct_recode(
          "maldipickr (loose)" = "maldipickr_79",
          "maldipickr (strict)" = "maldipickr_92",
          "SPeDE (loose)" = "SPeDE_20",
          "SPeDE (strict)" = "SPeDE_50",
          "IDBac (cosine)" = "IDBacCosine_65",
          "IDBac (default)" = "IDBacPresence_65" 
        ) |>
        forcats::fct_rev()
    )
}

# Snippet to fetch specific files from the zenodo archive of Asare et al. 2023
get_asare_data <- function(filename){
  fs::dir_create(here::here("data"))
  destfile <- here::here("data",filename)
  curl::curl_download(
    url = paste0(
      "https://zenodo.org/records/7773644/files/",
      filename,
      "?download=1"),
    destfile = destfile
  )
  destfile
}

get_asare_taxonomy <- function(spectra_names){
  # Extraction of taxonomy from path of raw data
  # because of issues with all strains from Bioaster
  # These strains with FAM prefix in strain name) have duplicated metadata
  # for the different spectra. Probably the strain was measured twice, 
  # but the fullName is the same and the name as well.
  spectra_names %>%
    select(sanitized_name, file) %>% 
    separate_wider_regex(
      file,
      patterns = c(
        ".*Library_strains_142x/",
        genus="\\w+"," ",
        species="\\w+"," ",
        strain="[^\\s]+",
        " ClostriTOF.*"
      )
    ) %>% 
    mutate(
      sanitized_name = make.unique(sanitized_name),
      species = paste(genus, species),
      strain = paste(species, strain),
      valid_taxonomy = !stringr::str_detect(species, "_") & !stringr::str_detect(species, " sp")
    ) %>% 
    relocate(sanitized_name, strain)
}

summary_dataset_asare <- function(tax_asare){
  n_asare <- tax_asare |> 
    dplyr::filter(valid_taxonomy) |>
    dplyr::group_by(species) |>
    dplyr::summarise(n_spectra = dplyr::n(),
                     n_strain = dplyr::n_distinct(strain))
  
  glue::glue(
    "We used {total_spectra} spectra from {total_strains} strains and {total_species} species, where {species_with_strains} species had more than one strain",
    total_spectra = sum(n_asare$n_spectra),
    total_species = nrow(n_asare),
    total_strains = sum(n_asare$n_strain),
    species_with_strains = filter(n_asare, n_strain > 1) |> nrow()
    )
}