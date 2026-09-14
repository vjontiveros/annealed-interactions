# 1. Define file names and the core values vector
file_names <- c("bci", "LZ_zoo", "Muggelsee_zoo", "Muggelsee_phyto", 
                "ecnasap", "portal_rodents", "women_gut", "WVirginia")

cores <- c(
  as.integer((35+102)/2),
  as.integer((19+63)/2),
  as.integer((31+101)/2),
  as.integer((57+152)/2),
  as.integer((54+82)/2),
  as.integer((12+29)/2),
  as.integer((8+21)/2),
  as.integer((56+101)/2)
)

# Create the output directory if it doesn't exist yet
dir.create("output", showWarnings = FALSE, recursive = TRUE)

# 2. Loop through each dataset
for (i in seq_along(file_names)) {
  
  # Build file path and load data
  file_path <- paste0("data/processed/", file_names[i], ".RData")
  load(file_path) # Assumes the object inside is named 'data'
  
  # Sort and subset columns based on the specific core mid-point
  df <- data[, order(colSums(data, na.rm = TRUE), decreasing = TRUE)]
  core_size <- min(cores[i], ncol(df)) # Prevent out-of-bounds if core > total columns
  df <- df[, 1:core_size, drop = FALSE]
  
  # Safely convert columns to a numeric matrix (handles data frames & matrices)
  df_numeric <- sapply(df, function(x) as.numeric(as.character(x)))
  if (!is.matrix(df_numeric)) {
    df_numeric <- matrix(df_numeric, nrow = nrow(df), ncol = ncol(df))
    colnames(df_numeric) <- colnames(df)
  }
  
  # Compute the coefficient of variation column-by-column
  cv_species <- apply(df_numeric, 2, function(x) {
    x <- na.omit(x)
    if (length(x) < 2 || mean(x) == 0) return(NA)
    sd(x) / mean(x)
  })
  
  # Save to CSV
  out_path <- paste0("results/new/cv_", file_names[i], ".csv")
  write.csv(cv_species, out_path, row.names = TRUE)
  
  cat("Successfully processed:", file_names[i], "-> Saved to", out_path, "\n")
}
