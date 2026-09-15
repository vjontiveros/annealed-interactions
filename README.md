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
| `data/processed/` | Processed abundance time-series datasets stored in `.RData` format. |
| `data/raw/` | Original abundance time-series datasets selected for this study. |
| **`simulations/`** | Core numerical simulation engine for stochastic gLV dynamics. |
| `simulations/output_simulations/` | Simulated time series analyzed in the manuscript. |
| `simulations/config_Nspecies_Dynamical.yaml` | Simulation config file (species count, noise level, interaction scales). |
| `simulations/simulations_Nspecies_Dynamical_extra_species.py` | Python script for gLV SDE integration with annealed interactions. |
| **`output/`** | Directory storing intermediate calculated files. |
| `output/inference/` | Estimates for the parameters of the annealed dynamics. |
| `output/coefficient_variation/` | Coefficient of variation of different datasets. |
| `output/results_alpha/` | Estimates of the parameter of the Gamma distribution. |

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

To install and load all necessary R packages used across this repository, run:

```r
source("R/packages.R")
```

`R/packages.R` attaches:

```r
packages <- c(
  "tidyverse",    # used all over
  "nnls",
  "matrixStats",
  "rgbif",
  "dplyr",
  "tools",        # base R; usually already available
  "MASS",
  "fitdistrplus",
  "readxl"
)
```

`tools` ships with base R, so it does not need to be installed from CRAN. `dplyr` is also loaded as part of `tidyverse`; it is listed separately because several scripts attach it on its own.

### 2. Running gLV simulations

Stochastic gLV integrations are implemented in Python. Running the simulations requires:

* **`numpy`**: Array operations and linear algebra for species abundances and interaction matrices.
* **`scipy`**: Scientific computing utilities used alongside the SDE integrator.
* **`sdeint`**: Numerical integration of stochastic differential equations ([https://github.com/mattja/sdeint](https://github.com/mattja/sdeint)).

Install them with:

```bash
pip install numpy scipy sdeint
```

From the `simulations/` directory, run:

```bash
python3 simulations_Nspecies_Dynamical_extra_species.py config_Nspecies_Dynamical.yaml
```

#### Simulation config (`config_Nspecies_Dynamical.yaml`)

This YAML file sets the inputs for each simulated community. The default values are:

| Parameter | Default | Meaning |
| :--- | :--- | :--- |
| `path` | `output_simulations/` | Output directory. |
| `dt` | `0.02` | Integration time step. |
| `Nspecies` | `50` | Number of focal species in the community. |
| `Nextra` | `20` | Number of extra species excluded of the annealed-interaction dynamics. |
| `x0` | np.full(Nspecies, 1./Nspecies) | Initial conditions for the population dynamics. |
| `r` | `1.0` | Intrinsic growth rate (shared across species). |
| `mu` | `-2.` | Mean of the interaction-matrix entries. |
| `sigma2_int` | `0.01` | Variance of the interaction-matrix entries. |
| `sigma2_env` | `0.1` | Environmental noise intensity. |
| `Nreal` | `1` | Number of independent realizations. |
| `Nprint` | `1` | Output/print cadence during a realization. |
| `Nsteps` | `1000` | Number of integration steps per realization. |
| `mu_extra` | `1.e-3` | Mean of the extra species. |
| `sigma2_extra` | `1.e-4` | Variance of the extra species. |

Change these fields to scan different community sizes, interaction scales, or noise levels without editing the Python integrator.


