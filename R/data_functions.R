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
          "Biotyper"
        ),
        ordered = T
      ) |>
        fct_recode(
          "maldipickr (loose)" = "maldipickr_79",
          "maldipickr (strict)" = "maldipickr_92",
          "SPeDE (loose)" = "SPeDE_20",
          "SPeDE (strict)" = "SPeDE_50"
        ) |>
        forcats::fct_rev()
    )
}
