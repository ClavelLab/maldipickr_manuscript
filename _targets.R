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
    get_spede(),
    format = "file"
  ),
  tar_target(
    spede_code,
    extract_archive(spede_archive)
  )
)