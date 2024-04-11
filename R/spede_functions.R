get_spede <- function(){
  fs::dir_create(here::here("data"))
  destfile <- here::here("data", "SPeDE.zip")
  curl::curl_download(
    url = "https://github.com/LM-UGent/SPeDE/archive/refs/heads/master.zip",
    destfile = destfile
  )
  destfile
}

extract_spede <- function(path_to_zip){
  zip::unzip(path_to_zip, exdir = here::here("data"))
  here::here("data", "SPeDE-master")
}

spede_peak <- function(spede_dir, spectra_dir, peak_dir_name) {
  callr::rscript(
    script = here::here(x, "data_preprocessing/peak_calling/peak_calling_cwt.R"),
    cmdargs = c(
      here::here(spectra_dir), "."
    )
  )
  file.rename(here::here("PKL4DICE"), here::here("data", peak_dir_name))
  here::here("data", peak_dir_name)
}
