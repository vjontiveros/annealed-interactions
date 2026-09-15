# Annealed-interactions

This repository contains the numerical pipeline to reproduce the results from the preprint:  
> **"Consistent determination of stability regimes in natural ecological communities from abundance time series"**

This package analyses the moments of the distribution of interaction coefficients of a model showing generalized Lotka–Volterra (gLV) dynamics.

---

## Repository Structure

| Folder / File | Description |
| :--- | :--- |
| **`R/`** | Scripts in R for package loading, and subroutines involved in the inference of the parameters of the annealed dynamics. |
| **`analyses/`** | R and Python scripts implementing the parameter estimation of the annealed dynamics, the core determination, maximum likelihood parameter estimation for the Gamma PDF, and coefficient of variation estimate. |
| **`data/`** | Empirical data used for this work and scripts for getting processed files. |
| `└── processed/` | Processed abundance time-series datasets stored in `.RData` format. |
| `└── raw/` | Original abundance time-series datasets selected for this study. |
| **`simulations/`** | Core numerical simulation engine for stochastic gLV dynamics. |
| `└── output_simulations/` | Simulated time series analyzed in the manuscript. |
| `├── config_Nspecies_Dynamical.yaml` | Simulation config file (species count, noise level, interaction scales). |
| `└── simulations_Nspecies_Dynamical_extra_species.py` | Python script for gLV SDE integration with annealed interactions. |
| **`output/`** | Directory storing intermediate calculated files. |
| `├── inference/` | Estimates for the parameters of the annealed dynamics. |
| `├── coefficient_variation/` | Coefficient of variation of different datasets. |
| `├── results_alpha/` | Estimates of the parameter of the Gamma distribution. |


---

## Required Packages & Setup

### 1. R Dependencies
The analysis and inference workflows rely on the following key R libraries:

* **`tidyverse`**: Core data-science collection used throughout the workflows (piping, wrangling, plotting, and tidy data conventions via packages such as `ggplot2`, `tidyr`, `readr`, and `purrr`).
* **`nnls`**: Non-negative least squares. Fits linear models with coefficients constrained to be ≥ 0, which is useful for mixture weights, compositional unmixing, and other non-negative parameter estimates.
* **`matrixStats`**: Fast row- and column-wise statistics on numeric matrices (`rowMeans`, `colSds`, `rowMedians`, and related summaries) without converting data to data frames.
* **`rgbif`**: R client for [GBIF](https://www.gbif.org/) (Global Biodiversity Information Facility). Queries and downloads species occurrence records and related biodiversity metadata.
* **`dplyr`**: Data manipulation and transformation (filter, select, mutate, join, summarize, and grouped operations).
* **`tools`**: Base R utilities for file and package tasks, including extension handling (`file_ext`, `file_path_sans_ext`) and checksum helpers used when managing input files.
* **`MASS`**: Functions from *Modern Applied Statistics with S*, including additional distribution fitting (`fitdistr`), negative-binomial GLMs (`glm.nb`), and multivariate / robust statistical methods.
* **`fitdistrplus`**: Maximum Likelihood Estimation for parametric distributions (Gamma fitting).
* **`readxl`**: Imports Excel workbooks (`.xls` / `.xlsx`) into R without requiring Microsoft Excel or Java.

To install and load all necessary R packages used across this repository, simply run:

```R
source("R/packages.R")
