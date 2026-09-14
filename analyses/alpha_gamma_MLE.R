library(fitdistrplus)
library(dplyr)
library(tools)

# Define directories
data_dir   <- "data/processed"
output_dir <- "output/inference"
res_dir    <- "output/results_alpha"

if (!dir.exists(res_dir)) dir.create(res_dir, recursive = TRUE)

file_list <- list.files(data_dir, pattern = "\\.RData$", full.names = TRUE)

process_and_save <- function(file_path) {
  base_name <- file_path_sans_ext(basename(file_path))
  message(paste("\n--- Processing:", base_name, "---"))
  
  # 1. Locate and read the corresponding moments CSV file from output/
  moments_path <- file.path(output_dir, paste0("moments_", base_name, ".csv"))
  
  if (!file.exists(moments_path)) {
    warning(sprintf("Skipping %s: Corresponding moments file not found at '%s'", base_name, moments_path))
    return(NULL)
  }
  
  moments <- read.csv(moments_path)
  
  if (!("r" %in% names(moments))) {
    warning(sprintf("Skipping %s: Column 'r' missing in '%s'", base_name, moments_path))
    return(NULL)
  }
  
  # 2. Load the dataset from .RData
  file_env <- new.env()
  load(file_path, envir = file_env)
  
  if (!("data" %in% ls(envir = file_env))) {
    warning(sprintf("Skipping %s: Object 'data' not found inside .RData", base_name))
    return(NULL)
  }
  
  data <- file_env$data
  n <- 3
  m <- ncol(data)
  
  if (is.null(m) || m < n) {
    warning(sprintf("Skipping %s: Insufficient columns (m = %s)", base_name, m))
    return(NULL)
  }
  
  ordered_cols <- order(colSums(data, na.rm = TRUE), decreasing = TRUE)
  file_results <- vector("list", m - n + 1)
  
  # 3. Fit models
  for (i in n:m) {
    df <- data[, ordered_cols[1:i], drop = FALSE]
    
    r_val <- moments$r[i - 2]
    if (is.null(r_val) || is.na(r_val) || r_val == 0) {
      message(sprintf("  Col %d: Invalid moments$r value (%s) at index %d", i, r_val, i - 2))
      next
    }
    
    x <- as.numeric(as.matrix(df)) / r_val
    
    pos_vals <- x[x > 0 & !is.na(x)]
    replacement <- if (length(pos_vals) > 0) 0.1 * min(pos_vals) else 1e-5
    x[is.na(x) | x <= 0] <- replacement
    
    x_mean <- mean(x)
    x_var  <- var(x)
    
    if (is.na(x_var) || x_var <= 0 || is.na(x_mean) || x_mean <= 0) {
      shape_est <- NA_real_
      shape_sd  <- NA_real_
    } else {
      fit2 <- tryCatch({
        fit1 <- fitdist(
          x, "gamma", method = "mle",
          start = list(shape = (x_mean^2) / x_var, rate = x_mean / x_var)
        )
        
        x_scaled <- x * fit1$estimate["rate"]
        s_mean <- mean(x_scaled)
        s_var  <- var(x_scaled)
        
        fitdist(
          x_scaled, "gamma", method = "mle",
          start = list(shape = (s_mean^2) / s_var, rate = s_mean / s_var)
        )
      }, error = function(e) {
        message(sprintf("  Col %d MLE Error: %s", i, e$message))
        return(NULL)
      })
      
      shape_est <- if (!is.null(fit2)) fit2$estimate["shape"] else NA_real_
      shape_sd  <- if (!is.null(fit2) && !is.null(fit2$sd) && "shape" %in% names(fit2$sd)) {
        fit2$sd["shape"]
      } else {
        NA_real_
      }
    }
    
    file_results[[i - n + 1]] <- data.frame(
      dataset = base_name,
      col_index = i,
      shape_est = unname(shape_est),
      shape_sd  = unname(shape_sd),
      stringsAsFactors = FALSE
    )
  }
  
  # 4. Save results per dataset
  res_df <- bind_rows(file_results)
  
  if (nrow(res_df) > 0) {
    save_path <- file.path(res_dir, paste0(base_name, "_gamma_results.csv"))
    write.csv(res_df, save_path, row.names = FALSE)
    message(sprintf("Successfully saved results to: %s", save_path))
  }
}

invisible(lapply(file_list, process_and_save))
