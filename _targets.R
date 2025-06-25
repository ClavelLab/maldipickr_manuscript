# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
library(tibble)
here::here("_targets.R")

# Set target options:
tar_option_set(
  packages = c("maldipickr", "tidyverse", "coop"),
  #              "MALDIquant","readxl", "ggplot2", "cowplot",
  #              "aricode", "ggokabeito"),
  # packages that your targets need to run
  format = "qs", # default storage format
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

#
# SPeDE workflow
#
thresholds_spede <- tibble(method = "SPeDE", threshold = c(20, 50))
targets_spede <- tar_map(
  unlist = FALSE,
  thresholds_spede,
  tar_file(
    spede,
    run_spede(spede_code, spede_peaks, spede_regrids,
              here::here("data", paste(method, threshold, sep = "_")),
              local_threshold = threshold)
  ),
  tar_target(import, import_spede_clusters(spede)),
  tar_target(picked, pick_spectra(import)),
  tar_target(
    summary_picked,
    picked %>% filter(to_pick) %>%
      transmute(
        name = name,
        cluster_size = cluster_size,
        procedure = paste(method, threshold, sep = "_"),
        isolate = str_remove(name, "_[1-8]_[A-Z][0-9]{1,2}")
      )
  )
)


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
  targets_spede
)