nll <- function(par_log){
  shape <- exp(par_log[1])
  rate  <- exp(par_log[2])
  -sum(dgamma(x, shape = shape, rate = rate, log = TRUE))
}
