get_spede <- function(){
  fs::dir_create(here::here("data"))
  destfile <- here::here("data", "SPeDE.zip")
  curl::curl_download(
    url = "https://github.com/LM-UGent/SPeDE/archive/refs/heads/master.zip",
    destfile = destfile
  )
  destfile
}

extract_archive <- function(path_to_zip){
  zip::unzip(path_to_zip, exdir = here::here("data"))
  basename(path_to_zip)  |>  stringr::str_remove(".zip") |> 
    here::here("data")
}