check_data_directory<-function(){
  if(!dir.exists(here::here("data"))){
    dir.create(
      here::here("data")
    )
  }
}

get_raw_data <- function(){
  fs::dir_create(here::here("raw_data"))
  destfile <- here::here("raw_data", "230328-1404-1001000371.zip")
  curl::curl_download(
    url = "https://zenodo.org/records/15658442/files/230328-1404-1001000371.zip?download=1",
    destfile = destfile
  )
  destfile
}

extract_raw_data <- function(path_to_raw_data){
  zip::unzip(path_to_raw_data, exdir = here::here("raw_data"))
  here::here("raw_data", fs::path_file(path_to_raw_data) |> fs::path_ext_remove() )
}

export_for_spede <- function(maldi_object, output_dir) {
  fs::dir_create(output_dir)
  MALDIquantForeign::exportTab(maldi_object, path = output_dir)
  return(output_dir)
}

read_clean_isolate_table <- function(isolate_table_file){
  readr::read_csv(isolate_table_file,
                  col_types = cols(
                    species = col_character(),
                    strain_identifier = col_character(),
                    phylum = col_character(),
                    family = col_character(),
                    included_in_analysis = col_character(),
                    cultivation_media = col_character(),
                    straininfo_doi = col_character()
                  )) |>
    dplyr::mutate(
      species_label = if_else( species == "Lachnospira rogosae sp. nov.",
                               glue::glue("italic(\"Lachnospira rogosae\")~sp.~nov."),
                               glue::glue("italic(\"{species}\")"))#,
    ) |>
    dplyr::select(strain_identifier, species, species_label)
}