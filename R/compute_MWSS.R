compute_mwss <- function(y, x1, x2, x3, beta0, beta1, beta2, a, b) {
  
  n <- length(y)
  p <- 5  # number of parameters: beta0, beta1, beta2, a, b
  
  # Mean and variance
  mu_hat    <- beta0 + beta1 * x1 + beta2 * x2
  sigma2_hat <- a + b * x3
  
  # Standardized residuals
  residuals_std <- (y - mu_hat) / sqrt(sigma2_hat)
  
  # WRSS and MWSS
  wrss <- sum(residuals_std^2)
  mwss <- wrss / (n - p)
  
  return(
    mwss          = mwss
  )
}
