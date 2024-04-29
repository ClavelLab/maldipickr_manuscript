# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)

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
  tar_target(
    spede_archive,
    get_spede(), format = "file"
  ),
  tar_target(
    spede_code,
    extract_spede(spede_archive), format = "file"
  ),
  tar_target(
    spede_peaks,
    spede_peak(
      spede_code, here::here("foo"), "spede_peaks"),
    format = "file"
  ),
  tar_target(
    spede_regrids,
    spede_regrid(
      spede_code, here::here("foo"), "spede_regrid"),
    format = "file"
  ),
  tar_target(
    spede,
    run_spede(spede_code, spede_peaks, spede_regrids, here::here("data", "SPeDE_50")),
    format = "file"
  )
)