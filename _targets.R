# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
here::here("_targets.R")

# Set target options:
tar_option_set(
  # packages = c("maldipickr", "tidyverse", "coop",
  #              "MALDIquant","readxl", "ggplot2", "cowplot",
  #              "aricode", "ggokabeito"),
  # packages that your targets need to run
  format = "qs", # default storage format
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

# Workflow
list(
  tar_file(
    spede_archive,
    get_spede()
  ),
  tar_file(
    spede_code,
    extract_spede(spede_archive)
  ),
  tar_file(
    spede_peaks,
    spede_peak(
      spede_code, here::here("foo"), "spede_peaks")
  ),
  tar_file(
    spede_regrids,
    spede_regrid(
      spede_code, here::here("foo"), "spede_regrid")
  ),
  tar_file(
    spede,
    run_spede(spede_code, spede_peaks, spede_regrids, here::here("data", "SPeDE_50"))
  )
)