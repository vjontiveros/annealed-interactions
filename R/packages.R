
# Packages used in this repository ----------------------------------------

packages <- c("tidyverse", #used all over
              "nnls", #used in gLV_moments
              "matrixStats", #used in gLV_moments
              "zoo", #used in best_moments
              "rgbif", #used to retrieve ecnasap data
              "strucchangeRcpp", #identifies breakpoints in mu 
              "MASS", #estimates the shape of the gamma distribution
              "fitdistrplus", #estimates the shape of the gamma distribution
              "readxl" #opens excel files
              )


# Check and install if needed ---------------------------------------------

installed <- rownames(installed.packages())
to_install <- setdiff(packages, installed)
if(length(to_install) > 0) install.packages(to_install)


# Load packages -----------------------------------------------------------


lapply(packages, function(pkg) {
  library(pkg, character.only = TRUE)
})
