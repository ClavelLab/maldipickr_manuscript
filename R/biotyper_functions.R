
filter_identification <- function(biotyper_report, identification_threshold = 2){
  biotyper_report |>
    dplyr::mutate(
      bruker_species = dplyr::if_else(bruker_log >= identification_threshold, bruker_species,
                                      "not reliable identification")
    )
}

clean_biotyper_names <- function(biotyper_report){
  biotyper_report |> 
    dplyr::mutate(
      name = stringr::str_remove(name, " ") |> stringr::str_replace_all("DSM1", "DSM_1") |> 
        stringr::str_replace_all("-", "_")
    )
}