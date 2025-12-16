
# Source packages and functions -------------------------------------------

source("R/packages.R")
source("R/gLV_moments.R")
source("R/best_moments.R")
source("R/nll_gamma.R")

# Load data ---------------------------------------------------------------

# load("data/processed/ecnasap.RData") 
load("data/processed/WVirginia.RData") 

# The temporal dataset should be called data. It should have species in the
# columns and years in the rows. Each cell, thus, should be abundance or
# biomass.

# Estimate moments for n:m species sequentially ---------------------------

n <- 3
m <- ncol(data)

off <- .1

moments <- gLV_moments(data = data, ranks = n:m, offset = off)

# We have a look at the results. We are going to use mu for identifying
# structural changes, thus separating a core and satellite (inmigration-driven)
# community. Mu is the best estimated parameter in the procedure.

ggplot(moments %>% add_column(Rank = n:m) %>% 
         pivot_longer(cols = -Rank, names_to = "var", values_to = "value"),
       aes(x = Rank, y = value)) + geom_line() +
  facet_wrap(~ var, scales = "free")


# Identify breakpoint -----------------------------------------------------

x <- moments$mu

fs <- Fstats(x ~ seq_along(x), .1, .9)
break_at <- breakpoints(fs)$breakpoints + n - 1
# As we start the series with n species, the breakpoint is at the indicated
# observed number + n-1.

plot(fs)


# Identify the phase (MA or UFP) ------------------------------------------

# Here we try to fit a gamma distribution to the abundances, using three similar
# methods. When the shape of the distribution is above one, we have a mode and
# therefore a unique fixed point. Otherwise, we will encounter a community with
# MA.

x <- unname(unlist(data[,order(colSums(data), decreasing = T)[1:break_at]]))

fit <- fitdistr(x, densfun = "gamma", start = list(shape = 1, rate = 1),       # buen punto de partida
                lower = c(1e-8, 1e-8),                   # evita parámetros ≤0
                method = "L-BFGS-B")
fit 

# If the function gives an error, try the next bit. If it doesn't continue to
# the next section.


c0 <- median(x)
x <- x/c0
fitdist(x, "gamma", method = "mle",
        start  = list(shape = (mean(x)^2)/var(x), rate = mean(x)/var(x)),
        optim.method = "L-BFGS-B",
        lower = c(1e-12, 1e-12), upper = c(1e6, 1e6))

# If it still fails, use the following calls. Otherwise, proceed to the next
# section.

m  <- mean(x)
v  <- var(x)

shape0 <- max(m^2 / v, 1e-3)
rate0  <- max(m / v, 1e-3)

opt <- nlminb(start = log(c(shape0, rate0)), objective = nll)

shape_hat <- exp(opt$par[1])
shape_hat


# Getting the best moments through a moving windows approach. -------------

ll <- 50 #least window length, select a number
fl <- nrow(data) - 1 #maximum window length
ls <- 1 #Step to search for window lengths (1 to look for all windows in the range)

all <- best_moments(data, offset = .1, Nspec = break_at, 
                                least_length = ll,full_length = fl,l_step=ls)
print(all)
