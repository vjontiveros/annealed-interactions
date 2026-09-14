# Source packages and functions -------------------------------------------
source("R/packages.R")
source("R/gLV_moments.R")

# Define input and output directories -------------------------------------
folder <- "data/processed/"
output_folder <- "output/"

# Get a list of all .RData files in the folder ----------------------------
file_list <- list.files(path = folder, pattern = "\\.RData$")

# Loop over each file -----------------------------------------------------
for (file in file_list) {
  
  # Extract file name without extension to use in the output file
  file_name <- sub("\\.RData$", "", file)
  
  # Load the data file with the abundances time series 
  load(file.path(folder, file))
  data[is.na(data)] <- 0
  # Order the data from highest to lowest mean abundance 
  df <- data[, order(colSums(data), decreasing = TRUE)]
  
  # Define some parameters 
  min_S <- 3 #minimum number of species in the core
  max_S <- ncol(data) #total number of species in the community
  least <- min(data[data > 0]) #minum non-zero abundance
  off <- least / 10 # threshold for setting the zero-abundances
  boot_B <- 1000 #number of bootstrap resamplings
  
  # Get a dataframe for the parameters of the model from min_S to max_S species
  set.seed(123)
  
  # Note: The original script passed 'data' rather than the ordered 'df'. 
  # Change `data = data` to `data = df` below if that was intended.
  moments <- gLV_moments(data = data, ranks = min_S:max_S, off = off, boot_B = boot_B)
  
  # Save the data
  output_path <- file.path(output_folder, paste0("moments_", file_name, ".csv"))
  write.csv(moments, output_path, row.names = FALSE)
  
  # Print progress to console
  cat("Successfully processed and saved:", file_name, "\n")
}
