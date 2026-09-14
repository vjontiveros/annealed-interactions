# Annealed Interactions & Stability Regimes

Code pipeline to reproduce the numerical simulations, statistical inferences, and figures from the manuscript:  
> **"Consistent determination of stability regimes in natural ecological communities from abundance time series"**

---

## Overview

This repository contains the numerical pipeline for simulating generalized Lotka–Volterra (gLV) dynamics under annealed interactions and analyzing moment distributions of interaction coefficients from ecological abundance time series.

---

## Repository Structure

| Folder / File | Description |
| :--- | :--- |
| **`simulations/`** | Core numerical simulation engine for stochastic gLV dynamics. |
| `├── config_Nspecies_Dynamical.yaml` | Simulation parameters (species count, noise level, interaction scales). |
| `└── simulations_Nspecies_Dynamical_extra_species.py` | Main Python script simulating gLV SDE integration with annealed interactions. |
| **`analyses/`** | R and Python scripts implementing the proposed parameter inference methods and figure generation. |
| **`R/packages.R`** | Helper script to automatically install and load all required R packages. |

---

## Environment & Requirements

### 1. Python Dependencies (Simulations)
The simulation scripts require **Python 3.8+** along with the following packages:

```bash
pip install numpy scipy sdeint pyyaml
