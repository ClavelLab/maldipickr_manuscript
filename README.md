# workflow for maldipickr manuscript

This repository contains the code for the comparison of dereplication approaches as part of the manuscript describing the [R package maldipickr](https://clavellab.github.io/maldipickr/) ([CRAN](https://doi.org/10.32614/CRAN.package.maldipickr)) using data at [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15744631.svg)](https://doi.org/10.5281/zenodo.15744631).


## Setup the environment for the workflow

These analyses were conducted in R 4.3.1 and Python 3.9.13 orchestrated from Rstudio. We recommend setting up R and specific versions using [`rig`](https://github.com/r-lib/rig#id-features), and getting Rstudio from [Posit](https://posit.co/download/rstudio-desktop/). We also use [`renv`](https://rstudio.github.io/renv) for reproducible environment, which can be installed in R with `install.packages("renv")` and [`uv`](https://docs.astral.sh/uv/) as a very fast Python package manager (as one of the tool in the benchmark uses Python).

0. Make sure you have installed [`uv`](https://docs.astral.sh/uv/)
1. Open Rstudio and create a new project via "File > New Project..."
2. Select "Version Control" and then "Git"
	1. Type `https://github.com/ClavelLab/maldipickr_manuscript` in Repository URL.
	2. Make sure the project is going to be created in the correct subdirectory on your computer, or else edit accordingly
	3. Click on "Create project"

If you comfortable with the command line and git, clone the repository either with SSH or HTTPS in a suitable location.

3. Rstudio warns you that `One or more packages recorded in the lockfile are not installed` because a couple of R packages and dependencies are needed.
	1. Install the dependencies by typing `renv::restore()` in the Console and agree to the installation of the packages.
	2. Check that all dependencies are set by typing `renv::status()` in the Console where you should have `No issues found`


## Run the workflow

Our analysis workflow is orchestrated by [`targets`](https://docs.ropensci.org/targets/) and can be run with the following command in the R console:

```r
targets::tar_make()
```


## Overview of the workflow

This is the dependency graph of the different objects (i.e., targets) generated in R during the workflow.

```mermaid
graph TD
x09f7694bb41893f8(["spede_code"]):::uptodate --> x7bc2998b7f8060b7(["spede_SPeDE_50<br>SPeDE 50"]):::uptodate
xd5f24f93e9b6cd94(["spede_peaks"]):::uptodate --> x7bc2998b7f8060b7(["spede_SPeDE_50<br>SPeDE 50"]):::uptodate
x4ab60fcd8b424f69(["spede_regrids"]):::uptodate --> x7bc2998b7f8060b7(["spede_SPeDE_50<br>SPeDE 50"]):::uptodate
xf9a08efad4262897(["plot_dereplication"]):::uptodate --> x1b66e2a14a4c2014(["plot_dereplication_file"]):::uptodate
x2cb78647d2229b81(["raw_biotyper_report_Biotyper<br>Biotyper"]):::uptodate --> x680a30458e74d9f2(["biotyper_report_Biotyper<br>Biotyper"]):::uptodate
x7959b9683ac10b2a(["processed"]):::uptodate --> x92b7df9a3a4d38d2(["fm_interpolated"]):::uptodate
x09f7694bb41893f8(["spede_code"]):::uptodate --> xae7b7dec01a37aa8(["spede_SPeDE_20<br>SPeDE 20"]):::uptodate
xd5f24f93e9b6cd94(["spede_peaks"]):::uptodate --> xae7b7dec01a37aa8(["spede_SPeDE_20<br>SPeDE 20"]):::uptodate
x4ab60fcd8b424f69(["spede_regrids"]):::uptodate --> xae7b7dec01a37aa8(["spede_SPeDE_20<br>SPeDE 20"]):::uptodate
x13ba1745f23420fa(["clustering_metrics"]):::uptodate --> x1cce4c61ac164fbe(["metrics_results_tableS2"]):::uptodate
x1d78c1c05eb8916a(["biotyper_report_clean_Biotyper<br>Biotyper"]):::uptodate --> xf2c733ac318b10e4(["picked_Biotyper<br>Biotyper"]):::uptodate
x56a09f0edff10d0b(["sim_interpolated"]):::uptodate --> x6700a2551983a10c(["df_interpolated_maldipickr_79<br>maldipickr 79"]):::uptodate
xf170f0c05dad2497(["clusters_maldipickr_79<br>maldipickr 79"]):::uptodate --> xddae61cd0a8f32e2(["picked_maldipickr_79<br>maldipickr 79"]):::uptodate
x84822056ace4a9ce(["all_results_clean"]):::uptodate --> x13ba1745f23420fa(["clustering_metrics"]):::uptodate
x7bc2998b7f8060b7(["spede_SPeDE_50<br>SPeDE 50"]):::uptodate --> x3b4a990b8c4b1912(["import_SPeDE_50<br>SPeDE 50"]):::uptodate
xa63f30966279f049(["all_results"]):::uptodate --> x84822056ace4a9ce(["all_results_clean"]):::uptodate
x6ab4545b996732f6(["isolate_table"]):::uptodate --> x84822056ace4a9ce(["all_results_clean"]):::uptodate
x92b7df9a3a4d38d2(["fm_interpolated"]):::uptodate --> x56a09f0edff10d0b(["sim_interpolated"]):::uptodate
x7d7b20e1a4c4ab31(["spectra_raw_noempty"]):::uptodate --> x5952e22b88c5a1e3(["spede_export"]):::uptodate
x680a30458e74d9f2(["biotyper_report_Biotyper<br>Biotyper"]):::uptodate --> x1d78c1c05eb8916a(["biotyper_report_clean_Biotyper<br>Biotyper"]):::uptodate
x09f7694bb41893f8(["spede_code"]):::uptodate --> x4ab60fcd8b424f69(["spede_regrids"]):::uptodate
x5952e22b88c5a1e3(["spede_export"]):::uptodate --> x4ab60fcd8b424f69(["spede_regrids"]):::uptodate
x7d7b20e1a4c4ab31(["spectra_raw_noempty"]):::uptodate --> x7959b9683ac10b2a(["processed"]):::uptodate
xf2c733ac318b10e4(["picked_Biotyper<br>Biotyper"]):::uptodate --> xe6379debfdbe70f5(["results_Biotyper<br>Biotyper"]):::uptodate
xd39b83c3fc857720(["spectra_raw"]):::uptodate --> x54be4f566da53823(["checks"]):::uptodate
x09f7694bb41893f8(["spede_code"]):::uptodate --> xd5f24f93e9b6cd94(["spede_peaks"]):::uptodate
x5952e22b88c5a1e3(["spede_export"]):::uptodate --> xd5f24f93e9b6cd94(["spede_peaks"]):::uptodate
xddae61cd0a8f32e2(["picked_maldipickr_79<br>maldipickr 79"]):::uptodate --> x2fd3b756b6877101(["results_maldipickr_79<br>maldipickr 79"]):::uptodate
x9a22b5e4d6937d40(["picked_maldipickr_92<br>maldipickr 92"]):::uptodate --> x22c57e7856533937(["results_maldipickr_92<br>maldipickr 92"]):::uptodate
xacab802d0132ae58(["picked_SPeDE_50<br>SPeDE 50"]):::uptodate --> x3ee9d3cb8fb6b540(["results_SPeDE_50<br>SPeDE 50"]):::uptodate
x934e30aad527086b(["isolate_table_file"]):::uptodate --> x6ab4545b996732f6(["isolate_table"]):::uptodate
x54be4f566da53823(["checks"]):::uptodate --> x7d7b20e1a4c4ab31(["spectra_raw_noempty"]):::uptodate
xd39b83c3fc857720(["spectra_raw"]):::uptodate --> x7d7b20e1a4c4ab31(["spectra_raw_noempty"]):::uptodate
xfc3540f0c3e8645a(["spede_archive"]):::uptodate --> x09f7694bb41893f8(["spede_code"]):::uptodate
xc0345d3922b7bdde(["picked_SPeDE_20<br>SPeDE 20"]):::uptodate --> xf1e15e217f13b69f(["results_SPeDE_20<br>SPeDE 20"]):::uptodate
x83095fc2dc6147af(["import_SPeDE_20<br>SPeDE 20"]):::uptodate --> xc0345d3922b7bdde(["picked_SPeDE_20<br>SPeDE 20"]):::uptodate
x3b4a990b8c4b1912(["import_SPeDE_50<br>SPeDE 50"]):::uptodate --> xacab802d0132ae58(["picked_SPeDE_50<br>SPeDE 50"]):::uptodate
x6700a2551983a10c(["df_interpolated_maldipickr_79<br>maldipickr 79"]):::uptodate --> xf170f0c05dad2497(["clusters_maldipickr_79<br>maldipickr 79"]):::uptodate
x7959b9683ac10b2a(["processed"]):::uptodate --> xf170f0c05dad2497(["clusters_maldipickr_79<br>maldipickr 79"]):::uptodate
x76d85119dbdc6832(["df_interpolated_maldipickr_92<br>maldipickr 92"]):::uptodate --> x78e1a6127723e5ec(["clusters_maldipickr_92<br>maldipickr 92"]):::uptodate
x7959b9683ac10b2a(["processed"]):::uptodate --> x78e1a6127723e5ec(["clusters_maldipickr_92<br>maldipickr 92"]):::uptodate
x136e4e85e6851637(["raw_data"]):::uptodate --> xd39b83c3fc857720(["spectra_raw"]):::uptodate
xae7b7dec01a37aa8(["spede_SPeDE_20<br>SPeDE 20"]):::uptodate --> x83095fc2dc6147af(["import_SPeDE_20<br>SPeDE 20"]):::uptodate
x922a991fdf2e9cd1(["raw_data_archive"]):::uptodate --> x136e4e85e6851637(["raw_data"]):::uptodate
x56a09f0edff10d0b(["sim_interpolated"]):::uptodate --> x76d85119dbdc6832(["df_interpolated_maldipickr_92<br>maldipickr 92"]):::uptodate
x84822056ace4a9ce(["all_results_clean"]):::uptodate --> x4150f5fc1f91eae4(["clustering_results_tableS3"]):::uptodate
xe6379debfdbe70f5(["results_Biotyper<br>Biotyper"]):::uptodate --> xa63f30966279f049(["all_results"]):::uptodate
x2fd3b756b6877101(["results_maldipickr_79<br>maldipickr 79"]):::uptodate --> xa63f30966279f049(["all_results"]):::uptodate
x22c57e7856533937(["results_maldipickr_92<br>maldipickr 92"]):::uptodate --> xa63f30966279f049(["all_results"]):::uptodate
xf1e15e217f13b69f(["results_SPeDE_20<br>SPeDE 20"]):::uptodate --> xa63f30966279f049(["all_results"]):::uptodate
x3ee9d3cb8fb6b540(["results_SPeDE_50<br>SPeDE 50"]):::uptodate --> xa63f30966279f049(["all_results"]):::uptodate
x84822056ace4a9ce(["all_results_clean"]):::uptodate --> xf9a08efad4262897(["plot_dereplication"]):::uptodate
x78e1a6127723e5ec(["clusters_maldipickr_92<br>maldipickr 92"]):::uptodate --> x9a22b5e4d6937d40(["picked_maldipickr_92<br>maldipickr 92"]):::uptodate
classDef uptodate stroke:#000000,color:#555358,fill:#f0f0c9;
classDef none stroke:#000000,color:#000000,fill:#94a4ac;
```
