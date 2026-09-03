source("R/compute_MWSS.R")
gLV_moments_v3 <- function(data, ranks, off = 0, boot_B = 2000){
  #data <- data |> dplyr::mutate(dplyr::across(where(is.integer), as.double))
  data <- data[, order(colSums(data), decreasing = T)]+0.
  data[data==0] <- off
  out_line <- 1
  offset <-0
  out <- matrix(NA, nrow = length(ranks), ncol = 11)
  out <- as.data.frame(out)
  colnames(out) <- c("sigma_env2/r", "mu", "sigma_int2", "r", "beta1",
                     "e_sigma_env2/r", "e_mu", "e_sigma_int2", "e_r", "e_beta1", "MWSS")
  
  for (i in ranks){
    print(i)
    data2 <- data[, 1:i]
    M1 <- rowMeans(data2)
    S1 <- rowMeans(data2^2)
    N <- ncol(data2)
    n_steps <- nrow(data2) - 1
    
    yv <- unname(unlist(c(log(data2[2:(n_steps + 1),] + offset) -
                            log(data2[1:n_steps, ] + offset))))
    xv <- unname(unlist(c(data2[1:n_steps, ])))
    Mv <- rep(M1[1:n_steps], N)
    Sv <- rep(S1[1:n_steps], N)
    
    model1 <- lm(yv ~ xv + Mv)
    #err1 <- summary(model1)$coefficients[, 2]
    
    res <- lm(yv ~ xv + Mv)$residuals
    #Bootstrapp
    B <- boot_B
    
    boot_coefs_1 <- matrix(NA, nrow = B, ncol = 3)
    
    n <- length(yv)
    
    for (b in 1:B) {
      idx <- sample(seq_len(n), replace = TRUE)
      
      yvb <- yv[idx]
      xvb <- xv[idx]
      Mvb <- Mv[idx]
      fit_b <- lm(yvb ~ xvb + Mvb)
      boot_coefs_1[b, ] <- coef(fit_b)
    }
    boot_mean_1 <- colMeans(boot_coefs_1)
    #boot_mean_1 <- summary(model1)$coefficients[, 1]
    # Standard errors
    boot_se_1 <- apply(boot_coefs_1, 2, sd)
    #boot_se_1 <- summary(model1)$coefficients[, 2]
    #-----------------------------
    mres <- matrix(res, ncol = N, nrow = n_steps)
    coefs1 <- boot_mean_1
    beta1 <- coefs1[2]
    err1 <- boot_se_1
    # -----------------------------
    # Construct variables
    # -----------------------------
    sr <- rowVars(mres) / abs(beta1)
    SS <- rowMeans(data2[1:(n_steps), ]^2)
    
    X <- cbind(1, SS)
    n <- length(sr)
    
    # Original fit
    model2 <- nnls(X, sr)
    model2 <- lm(sr~SS)
    coef(model2)
    
    # -----------------------------
    # Bootstrap
    # -----------------------------
    #set.seed(123)
    B <- boot_B
    boot_coefs <- matrix(NA, nrow = B, ncol = ncol(X))
    colnames(boot_coefs) <- c("Intercept", "SS")
    
    for (b in 1:B) {
      idx <- sample(seq_len(n), replace = TRUE)
      
      Xb <- X[idx, ]
      srb <- sr[idx]
      
      fit_b <- nnls(Xb, srb)
      boot_coefs[b, ] <- coef(fit_b)
    }
    
    # -----------------------------
    # Bootstrap results
    # -----------------------------
    # Point estimates
    boot_mean <- colMeans(boot_coefs)
    
    # Standard errors
    boot_se <- apply(boot_coefs, 2, sd)
    #print(boot_se)
    # 95% percentile confidence intervals
    boot_ci <- apply(
      boot_coefs,
      2,
      quantile,
      probs = c(0.005, 0.995)
    )
    
    #print(c(boot_mean, boot_se, boot_ci))
    
    coefs1 <- boot_mean_1
    coefs2 <- boot_mean
    #model2 <- (lm(sr ~ SS))
    
    err2 <- boot_se
    
    beta1 <- boot_mean_1[2]
    
    # Resultados
    
    rminusT <- coefs1[1]/abs(beta1)
    mu <- coefs1[3]/abs(beta1)
    T_est <- coefs2[1]/(2.)
    ToverR <- T_est/(T_est + rminusT)
    if(ToverR==0){
      r<- rminusT
    } else {
    r <- rminusT+ T_est}
    sigma2 <- coefs2[2]*r
    #sigma2 <- (var(res)/abs(beta1)-2*T_est)*r/(mean(xv^2))
    rm(data2)
    #theta <- (T_est+0.5*coefs2[2]*mean(S1))
    #alpha <- (rminusT+mu*mean(M1))/(theta)
    mrss <- compute_mwss(yv, xv, Mv, Sv, coefs1[1], coefs1[2], coefs1[3], coefs2[1]*abs(beta1), coefs2[2]*abs(beta1))
    out[out_line, ] <- 
      c(ToverR, mu, sigma2, r, beta1, err2[1]/r, 
        err1[3]/abs(beta1), err2[2]*r, err1[1]/abs(beta1),err1[2], mrss)   
    
    out_line <- out_line + 1 
  }
  out
}

