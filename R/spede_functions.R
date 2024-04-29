require(MassSpecWavelet) # as {renv} was not detecting R code from SPeDE

get_spede <- function(){
  fs::dir_create(here::here("ext-code"))
  destfile <- here::here("ext-code", "SPeDE.zip")
  curl::curl_download(
    url = "https://github.com/LM-UGent/SPeDE/archive/refs/heads/master.zip",
    destfile = destfile
  )
  destfile
}

extract_spede <- function(path_to_zip){
  zip::unzip(path_to_zip, exdir = here::here("ext-code"))
  here::here("ext-code", "SPeDE-master")
}

spede_peak <- function(spede_dir, spectra_dir, peak_dir_name) {
  check_data_directory()
  if (fs::dir_exists(here::here("data", peak_dir_name))){
    fs::dir_delete(here::here("data", peak_dir_name))
  }
  if (fs::dir_exists("PKL4DICE")){
    fs::dir_delete("PKL4DICE")
  }
  callr::rscript(
    script = here::here(spede_dir, "data_preprocessing/peak_calling/peak_calling_cwt.R"),
    cmdargs = c(
      here::here(spectra_dir), "."
    )
  )
  fs::file_move(here::here("PKL4DICE"), here::here("data", peak_dir_name))
  fs::dir_ls(
    path = here::here("data", peak_dir_name),
    glob = "*PKL_*.tab"
  )
}


spede_regrid <- function(spede_dir, spectra_dir, regrid_dir_name) {
  check_data_directory()
  if (fs::dir_exists(here::here("data", regrid_dir_name))){
    fs::dir_delete(here::here("data", regrid_dir_name))
  } else {
    fs::dir_create(here::here("data", regrid_dir_name))
  }
  cmd <- paste(
    "python3", here::here(spede_dir,"data_preprocessing/regridding/ReGrid.py"),
    spectra_dir, here::here("data", regrid_dir_name)
  )
  system(cmd)
  fs::dir_ls(
    path = here::here("data", regrid_dir_name),
    glob = "*ReGrid_*.tab"
  )
}


run_spede <- function(spede_dir, peak_dir, regrid_dir, spede_outdir, local_threshold = 50) {
  if (!dir.exists(spede_outdir)) dir.create(spede_outdir)
  pk <- list.files(peak_dir, full.names = T)
  rg <- list.files(regrid_dir, full.names = T)
  file.copy(
    pk, # from
    file.path(spede_outdir, basename(pk)) # to
  )
  file.copy(
    rg, # from
    file.path(spede_outdir, basename(rg)) # to
  )
  cmd <- paste(
    "python3",
    here::here(spede_dir, "Spectrum_Processing/SPeDE.py"),
    "-n", basename(spede_outdir),
    "-l", local_threshold, spede_outdir, spede_outdir
  )
  print(cmd)
  system(cmd)
  # dte <- gsub("-", "_", Sys.Date())
  fles <- list.files(pattern = ".csv")
  output_spede <- fles[grepl(spede_outdir, fles)]
  file.rename(
    output_spede,
    file.path(spede_outdir, output_spede)
  )
  return(file.path(spede_outdir, output_spede))
}