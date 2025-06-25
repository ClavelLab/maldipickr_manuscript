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