# Annealed-interactions

## Aim

This repository contains the numerical pipeline to reproduce the results and figures from the preprint:  
> **"Consistent determination of stability regimes in natural ecological communities from abundance time series"**

This package analyses the moments of the distribution of interaction coefficients of a model showing generalized Lotka–Volterra (gLV) dynamics.

---

## Repository Structure

| Folder / File | Description |
| :--- | :--- |
| **`simulations/`** | Core numerical simulation engine for stochastic gLV dynamics. |
| `├── config_Nspecies_Dynamical.yaml` | Simulation config file (species count, noise level, interaction scales). |
| `└── simulations_Nspecies_Dynamical_extra_species.py` | Python script for gLV SDE integration with annealed interactions. |
| **`analyses/`** | R and Python scripts implementing the breakpoint detection and maximum likelihood parameter estimation. |
| **`output/`** | Directory storing intermediate calculated moment files (`moments_*.csv`). |
| **`data/processed/`** | Processed abundance time-series datasets stored in `.RData` format. |

---

## Required Packages & Setup

### 1. R Dependencies
The analysis and inference workflows rely on the following key R libraries:
* **`fitdistrplus`**: Maximum Likelihood Estimation for parametric distributions (Gamma fitting).
* **`dplyr`**: Data manipulation and transformation.
* **`changepoint`** / **`changepoint.np`**: Breakpoint and change-point analysis via PELT.
* **`reticulate`**: Interoperability interface for running Python packages inside R.

To install and load all necessary R packages used across this repository, simply run:

```R
source("R/packages.R")
