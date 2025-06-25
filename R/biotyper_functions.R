
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
      name = stringr::str_remove(name, " ") %>% stringr::str_replace_all("DSM1", "DSM_1"),
      name = purrr::reduce2(
        c(
          "BL-178-WT-3A$", "CLA-AA-H117$", "CLA-AA-H149$",
          "CLA-AA-H222$", "CLA-AA-H284$", "CLA-JM-H23$",
          "CLA-JM-H27$", "DSM_105335$", "H4-GB1-C9$",
          "McC-252-APC-1B1$"
        ),
        c(
          "BL-178-WT-3A_1", "CLA-AA-H117_1", "CLA-AA-H149_1",
          "CLA-AA-H222_1", "CLA-AA-H284_1", "CLA-JM-H23_1",
          "CLA-JM-H27_1", "DSM_105335_1", "H4-GB1-C9_1",
          "McC-252-APC-1B1_1"
        ),
        .init = name,
        stringr::str_replace_all
      )
    )
}