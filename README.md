# workflow for maldipickr manuscript

This repository contains the code for the comparison of dereplication approaches as part of the manuscript describing the [R package maldipickr](https://clavellab.github.io/maldipickr/) ([CRAN](https://doi.org/10.32614/CRAN.package.maldipickr)) using data at [zenodo.org/10.5281/zenodo.15744631](https://doi.org/10.5281/zenodo.15744631).


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
xa7859285c804f0b6(["picked_Asare_maldipickr_79<br>Asare_maldipickr 79"]):::skipped --> xd92594effab45999(["results_Asare_maldipickr_79<br>Asare_maldipickr 79"]):::skipped
    x934e30aad527086b(["isolate_table_file"]):::skipped --> x6ab4545b996732f6(["isolate_table"]):::skipped
    xba0c6a84aba0bfb0(["picked_Asare_maldipickr_92<br>Asare_maldipickr 92"]):::skipped --> xfbfcc876be4f9020(["results_Asare_maldipickr_92<br>Asare_maldipickr 92"]):::skipped
    x089278c89d5d8459(["picked_IDBacPresence_65<br>IDBacPresence 65"]):::skipped --> xca6a71af29c88651(["results_IDBacPresence_65<br>IDBacPresence 65"]):::skipped
    xea88991d01eecf45(["df_interpolated_IDBacCosine_65<br>IDBacCosine 65"]):::skipped --> xc9d0a93baa6a9646(["picked_IDBacCosine_65<br>IDBacCosine 65"]):::skipped
    x7bc2998b7f8060b7(["spede_SPeDE_50<br>SPeDE 50"]):::skipped --> x3b4a990b8c4b1912(["import_SPeDE_50<br>SPeDE 50"]):::skipped
    xf533da80f7192ad2(["fm_interpolated_Asare<br>Asare"]):::skipped --> xdc990ce7d4fb607e(["sim_interpolated_Asare<br>Asare"]):::skipped
    x84822056ace4a9ce(["all_results_clean"]):::skipped --> x4150f5fc1f91eae4(["clustering_results_tableS3"]):::skipped
    x56a09f0edff10d0b(["sim_interpolated"]):::skipped --> x76d85119dbdc6832(["df_interpolated_maldipickr_92<br>maldipickr 92"]):::skipped
    x2e565c10f78d7f3b(["all_asare_clean"]):::skipped --> x9b7e02955a40555b(["clustering_results_tableS5"]):::skipped
    xacab802d0132ae58(["picked_SPeDE_50<br>SPeDE 50"]):::skipped --> x3ee9d3cb8fb6b540(["results_SPeDE_50<br>SPeDE 50"]):::skipped
    x84822056ace4a9ce(["all_results_clean"]):::skipped --> xf9a08efad4262897(["plot_dereplication"]):::skipped
    x07d2008d49ed6d21(["valid_tax_spectra_Asare<br>Asare"]):::skipped --> x17f78ae5cacaef28(["sanitized_names_Asare<br>Asare"]):::skipped
    x093006d23cb5ad91(["clusters_Asare_maldipickr_79<br>Asare_maldipickr 79"]):::skipped --> xa7859285c804f0b6(["picked_Asare_maldipickr_79<br>Asare_maldipickr 79"]):::skipped
    xdc990ce7d4fb607e(["sim_interpolated_Asare<br>Asare"]):::skipped --> x15926e7965afb02e(["linkage_Asare_maldipickr_92<br>Asare_maldipickr 92"]):::skipped
    x09f7694bb41893f8(["spede_code"]):::skipped --> x7bc2998b7f8060b7(["spede_SPeDE_50<br>SPeDE 50"]):::skipped
    xd5f24f93e9b6cd94(["spede_peaks"]):::skipped --> x7bc2998b7f8060b7(["spede_SPeDE_50<br>SPeDE 50"]):::skipped
    x4ab60fcd8b424f69(["spede_regrids"]):::skipped --> x7bc2998b7f8060b7(["spede_SPeDE_50<br>SPeDE 50"]):::skipped
    xc9d0a93baa6a9646(["picked_IDBacCosine_65<br>IDBacCosine 65"]):::skipped --> xd7de739d83968c4c(["results_IDBacCosine_65<br>IDBacCosine 65"]):::skipped
    x56a09f0edff10d0b(["sim_interpolated"]):::skipped --> x6700a2551983a10c(["df_interpolated_maldipickr_79<br>maldipickr 79"]):::skipped
    x95f02f52aa278444(["plot_linkage"]):::skipped --> xe2d7322c1c5ee196(["plot_linkage_file"]):::skipped
    x0a8c0675d5a1c896(["linkage_Asare_maldipickr_79<br>Asare_maldipickr 79"]):::skipped --> xe4c45fbb61b923a7(["linkage_asare"]):::skipped
    x15926e7965afb02e(["linkage_Asare_maldipickr_92<br>Asare_maldipickr 92"]):::skipped --> xe4c45fbb61b923a7(["linkage_asare"]):::skipped
    x44f854713e73d5d8(["all_asare"]):::skipped --> x2e565c10f78d7f3b(["all_asare_clean"]):::skipped
    xefe16837f1e56ebf(["clostritof_tax_all_Asare<br>Asare"]):::skipped --> x2e565c10f78d7f3b(["all_asare_clean"]):::skipped
    xd92594effab45999(["results_Asare_maldipickr_79<br>Asare_maldipickr 79"]):::skipped --> x44f854713e73d5d8(["all_asare"]):::skipped
    xfbfcc876be4f9020(["results_Asare_maldipickr_92<br>Asare_maldipickr 92"]):::skipped --> x44f854713e73d5d8(["all_asare"]):::skipped
    xe6379debfdbe70f5(["results_Biotyper<br>Biotyper"]):::skipped --> xa63f30966279f049(["all_results"]):::skipped
    xd7de739d83968c4c(["results_IDBacCosine_65<br>IDBacCosine 65"]):::skipped --> xa63f30966279f049(["all_results"]):::skipped
    xca6a71af29c88651(["results_IDBacPresence_65<br>IDBacPresence 65"]):::skipped --> xa63f30966279f049(["all_results"]):::skipped
    x2fd3b756b6877101(["results_maldipickr_79<br>maldipickr 79"]):::skipped --> xa63f30966279f049(["all_results"]):::skipped
    x22c57e7856533937(["results_maldipickr_92<br>maldipickr 92"]):::skipped --> xa63f30966279f049(["all_results"]):::skipped
    xf1e15e217f13b69f(["results_SPeDE_20<br>SPeDE 20"]):::skipped --> xa63f30966279f049(["all_results"]):::skipped
    x3ee9d3cb8fb6b540(["results_SPeDE_50<br>SPeDE 50"]):::skipped --> xa63f30966279f049(["all_results"]):::skipped
    xadd19c6a8ac1f3a9(["checks_Asare<br>Asare"]):::skipped --> xba2df1d06966d054(["spectra_raw_noempty_Asare<br>Asare"]):::skipped
    xd48716d6039cca93(["spectra_raw_Asare<br>Asare"]):::skipped --> xba2df1d06966d054(["spectra_raw_noempty_Asare<br>Asare"]):::skipped
    xf9a08efad4262897(["plot_dereplication"]):::skipped --> x1b66e2a14a4c2014(["plot_dereplication_file"]):::skipped
    xefe16837f1e56ebf(["clostritof_tax_all_Asare<br>Asare"]):::skipped --> x07d2008d49ed6d21(["valid_tax_spectra_Asare<br>Asare"]):::skipped
    xba2df1d06966d054(["spectra_raw_noempty_Asare<br>Asare"]):::skipped --> x07d2008d49ed6d21(["valid_tax_spectra_Asare<br>Asare"]):::skipped
    x136e4e85e6851637(["raw_data"]):::skipped --> xd39b83c3fc857720(["spectra_raw"]):::skipped
    x6700a2551983a10c(["df_interpolated_maldipickr_79<br>maldipickr 79"]):::skipped --> xf170f0c05dad2497(["clusters_maldipickr_79<br>maldipickr 79"]):::skipped
    x7959b9683ac10b2a(["processed"]):::skipped --> xf170f0c05dad2497(["clusters_maldipickr_79<br>maldipickr 79"]):::skipped
    x17f78ae5cacaef28(["sanitized_names_Asare<br>Asare"]):::skipped --> x6d8d2208984047db(["processed_Asare<br>Asare"]):::skipped
    x07d2008d49ed6d21(["valid_tax_spectra_Asare<br>Asare"]):::skipped --> x6d8d2208984047db(["processed_Asare<br>Asare"]):::skipped
    x54be4f566da53823(["checks"]):::skipped --> x7d7b20e1a4c4ab31(["spectra_raw_noempty"]):::skipped
    xd39b83c3fc857720(["spectra_raw"]):::skipped --> x7d7b20e1a4c4ab31(["spectra_raw_noempty"]):::skipped
    x76d85119dbdc6832(["df_interpolated_maldipickr_92<br>maldipickr 92"]):::skipped --> x78e1a6127723e5ec(["clusters_maldipickr_92<br>maldipickr 92"]):::skipped
    x7959b9683ac10b2a(["processed"]):::skipped --> x78e1a6127723e5ec(["clusters_maldipickr_92<br>maldipickr 92"]):::skipped
    xdc990ce7d4fb607e(["sim_interpolated_Asare<br>Asare"]):::skipped --> xbfce558a542d1301(["df_interpolated_Asare_maldipickr_92<br>Asare_maldipickr 92"]):::skipped
    xab3fb8c11b614ae7(["total_clusters_asare"]):::skipped --> x99d6edc4aec08e2e(["total_clusters_linkage_tableS6"]):::skipped
    x680a30458e74d9f2(["biotyper_report_Biotyper<br>Biotyper"]):::skipped --> x1d78c1c05eb8916a(["biotyper_report_clean_Biotyper<br>Biotyper"]):::skipped
    x6d8d2208984047db(["processed_Asare<br>Asare"]):::skipped --> xf533da80f7192ad2(["fm_interpolated_Asare<br>Asare"]):::skipped
    x3b4a990b8c4b1912(["import_SPeDE_50<br>SPeDE 50"]):::skipped --> xacab802d0132ae58(["picked_SPeDE_50<br>SPeDE 50"]):::skipped
    x7d7b20e1a4c4ab31(["spectra_raw_noempty"]):::skipped --> x7959b9683ac10b2a(["processed"]):::skipped
    x1d78c1c05eb8916a(["biotyper_report_clean_Biotyper<br>Biotyper"]):::skipped --> xf2c733ac318b10e4(["picked_Biotyper<br>Biotyper"]):::skipped
    x83095fc2dc6147af(["import_SPeDE_20<br>SPeDE 20"]):::skipped --> xc0345d3922b7bdde(["picked_SPeDE_20<br>SPeDE 20"]):::skipped
    x09f7694bb41893f8(["spede_code"]):::skipped --> xd5f24f93e9b6cd94(["spede_peaks"]):::skipped
    x5952e22b88c5a1e3(["spede_export"]):::skipped --> xd5f24f93e9b6cd94(["spede_peaks"]):::skipped
    x15926e7965afb02e(["linkage_Asare_maldipickr_92<br>Asare_maldipickr 92"]):::skipped --> x401166e7bfe5f91f(["total_clusters_Asare_maldipickr_92<br>Asare_maldipickr 92"]):::skipped
    xddae61cd0a8f32e2(["picked_maldipickr_79<br>maldipickr 79"]):::skipped --> x2fd3b756b6877101(["results_maldipickr_79<br>maldipickr 79"]):::skipped
    xc4c4c0ad5de0bc24(["spectra_names_Asare<br>Asare"]):::skipped --> xefe16837f1e56ebf(["clostritof_tax_all_Asare<br>Asare"]):::skipped
    x9a22b5e4d6937d40(["picked_maldipickr_92<br>maldipickr 92"]):::skipped --> x22c57e7856533937(["results_maldipickr_92<br>maldipickr 92"]):::skipped
    xcc1cf13aed73d237(["sim_interpolated_IDBacPresence_65<br>IDBacPresence 65"]):::skipped --> xc8541770246f0ce5(["df_interpolated_IDBacPresence_65<br>IDBacPresence 65"]):::skipped
    x922a991fdf2e9cd1(["raw_data_archive"]):::skipped --> x136e4e85e6851637(["raw_data"]):::skipped
    xc196bce8bba3aebd(["df_interpolated_Asare_maldipickr_79<br>Asare_maldipickr 79"]):::skipped --> x093006d23cb5ad91(["clusters_Asare_maldipickr_79<br>Asare_maldipickr 79"]):::skipped
    x6d8d2208984047db(["processed_Asare<br>Asare"]):::skipped --> x093006d23cb5ad91(["clusters_Asare_maldipickr_79<br>Asare_maldipickr 79"]):::skipped
    x92b7df9a3a4d38d2(["fm_interpolated"]):::skipped --> x56a09f0edff10d0b(["sim_interpolated"]):::skipped
    xf2c733ac318b10e4(["picked_Biotyper<br>Biotyper"]):::skipped --> xe6379debfdbe70f5(["results_Biotyper<br>Biotyper"]):::skipped
    xbfce558a542d1301(["df_interpolated_Asare_maldipickr_92<br>Asare_maldipickr 92"]):::skipped --> x31f5bb23ae1d2c7c(["clusters_Asare_maldipickr_92<br>Asare_maldipickr 92"]):::skipped
    x6d8d2208984047db(["processed_Asare<br>Asare"]):::skipped --> x31f5bb23ae1d2c7c(["clusters_Asare_maldipickr_92<br>Asare_maldipickr 92"]):::skipped
    x9c485eed638c51f4(["clostritof_spectra_archive_Asare<br>Asare"]):::skipped --> x8149628e040429c2(["clostritof_spectra_dir_Asare<br>Asare"]):::skipped
    xa63f30966279f049(["all_results"]):::skipped --> x84822056ace4a9ce(["all_results_clean"]):::skipped
    x6ab4545b996732f6(["isolate_table"]):::skipped --> x84822056ace4a9ce(["all_results_clean"]):::skipped
    x8149628e040429c2(["clostritof_spectra_dir_Asare<br>Asare"]):::skipped --> xd48716d6039cca93(["spectra_raw_Asare<br>Asare"]):::skipped
    x78e1a6127723e5ec(["clusters_maldipickr_92<br>maldipickr 92"]):::skipped --> x9a22b5e4d6937d40(["picked_maldipickr_92<br>maldipickr 92"]):::skipped
    xc0345d3922b7bdde(["picked_SPeDE_20<br>SPeDE 20"]):::skipped --> xf1e15e217f13b69f(["results_SPeDE_20<br>SPeDE 20"]):::skipped
    x13ba1745f23420fa(["clustering_metrics"]):::skipped --> x1cce4c61ac164fbe(["metrics_results_tableS2"]):::skipped
    x0e805d0c3094e416(["clustering_metrics_asare"]):::skipped --> x1e5779ec72ca6607(["metrics_results_tableS4"]):::skipped
    xe4c45fbb61b923a7(["linkage_asare"]):::skipped --> x95f02f52aa278444(["plot_linkage"]):::skipped
    x09f7694bb41893f8(["spede_code"]):::skipped --> xae7b7dec01a37aa8(["spede_SPeDE_20<br>SPeDE 20"]):::skipped
    xd5f24f93e9b6cd94(["spede_peaks"]):::skipped --> xae7b7dec01a37aa8(["spede_SPeDE_20<br>SPeDE 20"]):::skipped
    x4ab60fcd8b424f69(["spede_regrids"]):::skipped --> xae7b7dec01a37aa8(["spede_SPeDE_20<br>SPeDE 20"]):::skipped
    xa88d43d24e85b351(["sim_interpolated_IDBacCosine_65<br>IDBacCosine 65"]):::skipped --> xea88991d01eecf45(["df_interpolated_IDBacCosine_65<br>IDBacCosine 65"]):::skipped
    x2cb78647d2229b81(["raw_biotyper_report_Biotyper<br>Biotyper"]):::skipped --> x680a30458e74d9f2(["biotyper_report_Biotyper<br>Biotyper"]):::skipped
    x7d7b20e1a4c4ab31(["spectra_raw_noempty"]):::skipped --> xcb376143ddff9e4a(["idbac_export"]):::skipped
    xf170f0c05dad2497(["clusters_maldipickr_79<br>maldipickr 79"]):::skipped --> xddae61cd0a8f32e2(["picked_maldipickr_79<br>maldipickr 79"]):::skipped
    xdc990ce7d4fb607e(["sim_interpolated_Asare<br>Asare"]):::skipped --> xc196bce8bba3aebd(["df_interpolated_Asare_maldipickr_79<br>Asare_maldipickr 79"]):::skipped
    x84822056ace4a9ce(["all_results_clean"]):::skipped --> x13ba1745f23420fa(["clustering_metrics"]):::skipped
    xc8541770246f0ce5(["df_interpolated_IDBacPresence_65<br>IDBacPresence 65"]):::skipped --> x089278c89d5d8459(["picked_IDBacPresence_65<br>IDBacPresence 65"]):::skipped
    x31f5bb23ae1d2c7c(["clusters_Asare_maldipickr_92<br>Asare_maldipickr 92"]):::skipped --> xba0c6a84aba0bfb0(["picked_Asare_maldipickr_92<br>Asare_maldipickr 92"]):::skipped
    x7d7b20e1a4c4ab31(["spectra_raw_noempty"]):::skipped --> x5952e22b88c5a1e3(["spede_export"]):::skipped
    x7959b9683ac10b2a(["processed"]):::skipped --> x92b7df9a3a4d38d2(["fm_interpolated"]):::skipped
    xfc3540f0c3e8645a(["spede_archive"]):::skipped --> x09f7694bb41893f8(["spede_code"]):::skipped
    xae7b7dec01a37aa8(["spede_SPeDE_20<br>SPeDE 20"]):::skipped --> x83095fc2dc6147af(["import_SPeDE_20<br>SPeDE 20"]):::skipped
    x09f7694bb41893f8(["spede_code"]):::skipped --> x4ab60fcd8b424f69(["spede_regrids"]):::skipped
    x5952e22b88c5a1e3(["spede_export"]):::skipped --> x4ab60fcd8b424f69(["spede_regrids"]):::skipped
    x0a8c0675d5a1c896(["linkage_Asare_maldipickr_79<br>Asare_maldipickr 79"]):::skipped --> x42d87c08c8838160(["total_clusters_Asare_maldipickr_79<br>Asare_maldipickr 79"]):::skipped
    xefe16837f1e56ebf(["clostritof_tax_all_Asare<br>Asare"]):::skipped --> xa767f3a1669d1628(["summary_asare"]):::skipped
    xdc990ce7d4fb607e(["sim_interpolated_Asare<br>Asare"]):::skipped --> x0a8c0675d5a1c896(["linkage_Asare_maldipickr_79<br>Asare_maldipickr 79"]):::skipped
    xd48716d6039cca93(["spectra_raw_Asare<br>Asare"]):::skipped --> xadd19c6a8ac1f3a9(["checks_Asare<br>Asare"]):::skipped
    xd39b83c3fc857720(["spectra_raw"]):::skipped --> x54be4f566da53823(["checks"]):::skipped
    x42d87c08c8838160(["total_clusters_Asare_maldipickr_79<br>Asare_maldipickr 79"]):::skipped --> xab3fb8c11b614ae7(["total_clusters_asare"]):::skipped
    x401166e7bfe5f91f(["total_clusters_Asare_maldipickr_92<br>Asare_maldipickr 92"]):::skipped --> xab3fb8c11b614ae7(["total_clusters_asare"]):::skipped
    x2e565c10f78d7f3b(["all_asare_clean"]):::skipped --> x0e805d0c3094e416(["clustering_metrics_asare"]):::skipped
    xba2df1d06966d054(["spectra_raw_noempty_Asare<br>Asare"]):::skipped --> xc4c4c0ad5de0bc24(["spectra_names_Asare<br>Asare"]):::skipped
	classDef skipped stroke:#000000,color:#555358,fill:#f0f0c9;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
```
