gLV_moments <- function(data, ranks, offset = 0){
  data <- data[, order(colSums(data), decreasing = T)]
  
  out_line <- 1
  
  out <- matrix(NA, nrow = length(ranks), ncol = 10)
  out <- as.data.frame(out)
  colnames(out) <- c("T/r", "mu", "sigma2", "r", "beta1", 
                     "e_T/r", "e_mu", "e_sigma2", "e_r", "e_beta1")
  
  for (i in ranks){
    data2 <- data[, 1:i]
    M1 <<- rowMeans(data2)
    N <- ncol(data2)
    n_steps <- nrow(data2) - 1
    
    yv <- unname(unlist(c(log(data2[2:(n_steps + 1),] + offset) -
                            log(data2[1:n_steps, ] + offset))))
    xv <- unname(unlist(c(data2[1:n_steps, ])))
    Mv <- rep(M1[1:n_steps], N)
    
    model1 <- lm(yv ~ xv + Mv)
    err1 <- summary(model1)$coefficients[, 2]
    
    res <- lm(yv ~ xv + Mv)$residuals
    
    mres <- matrix(res, ncol = n_steps, nrow = N)
    coefs1 <- coefficients(model1)
    beta1 <- coefs1[2]
    
    sr <- rowVars(mres)/abs(beta1)
    SS <- colMeans(data2^2)
    
    X <- cbind(1, SS)
    model2 <- nnls(X, sr)
    
    coefs1 <- coefficients(model1)
    coefs2 <- coef(model2)
    
    model2 <- (lm(sr ~ SS))
    err2 <- summary(model2)$coefficients[, 2]
    
    beta1 <- coefs1[2]
    
    # Resultados
    
    rminusT <- coefs1[1]/abs(beta1)
    mu <- coefs1[3]/abs(beta1)
    T_est <- coefs2[1]/(2.)
    ToverR <- T_est/(T_est + rminusT)
    r <- 1/ToverR * T_est
    sigma2 <- coefs2[2]*r
    
    rm(data2)
    
    out[out_line, ] <- 
      c(ToverR, mu, sigma2, 1/ToverR * T_est, beta1, err2[1]/r, 
        err1[3]/abs(beta1), err2[2]*r, err1[1]/abs(beta1),err1[2])   
    
    out_line <- out_line + 1 
  }
  out
}
