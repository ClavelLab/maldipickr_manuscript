dummy <- function() require(MassSpecWavelet) # as {renv} was not detecting R code from SPeDE

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
  if (!fs::dir_exists(here::here("data", regrid_dir_name))){
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


run_spede <- function(spede_dir, peak_files, regrid_files, spede_outdir, local_threshold = 50) {
  if (fs::dir_exists(spede_outdir)){
    fs::dir_ls(spede_outdir) |>  fs::file_delete()
  } else{
    fs::dir_create(spede_outdir)
  }
  fs::file_copy(
    peak_files, # from
    fs::path(spede_outdir, fs::path_file(peak_files)) # to
  )
  fs::file_copy(
    regrid_files, # from
    fs::path(spede_outdir, fs::path_file(regrid_files)) # to
  )
  cmd <- paste(
    "python3",
    here::here(spede_dir, "Spectrum_Processing/SPeDE.py"),
    "-n", basename(spede_outdir),
    "-l", local_threshold, spede_outdir, spede_outdir
  )
  system(cmd)
  fles <- fs::dir_ls(glob = "*.csv")
  output_spede <- fles[grepl(fs::path_file(spede_outdir), fles)]
  final_output_spede <- fs::path(spede_outdir, fs::path_file(spede_outdir), ext = "csv")
  fs::file_move(
    output_spede,
    final_output_spede
    )
  return(final_output_spede)
}