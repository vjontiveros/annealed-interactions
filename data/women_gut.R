source("R/packages.R")

# Data is freely available and comes from Vandeputte et al. (2021), with doi
# https://doi.org/10.1038/s41467-021-27098-7 . We select the longest time-series
# with different enterotypes (akin to enteric communities), which pertains to
# individual 820.

gut <- read_excel("data/raw/41467_2021_27098_MOESM3_ESM.xlsx", 
                  sheet = "S1-3")
d <- read_excel("data/raw/41467_2021_27098_MOESM3_ESM.xlsx", 
                   sheet = "S1-4", na = "NA")

types_ind <- gut %>% group_by(ID_Number, Enterotype_nr) %>% 
  summarise(n = n()) %>% filter(Enterotype_nr != "NA")

# Sample index
ind <- 820
gut %>% filter(ID_Number == ind) %>% filter(Enterotype_nr != "NA") %>% 
  dplyr::select(1) %>% unlist() %>% unname() %>% 
  assign(x = paste0("i", ind), value = ., envir = .GlobalEnv)

data <- d[i820, ]

rowSums(data) %>% is.na()  

data <- data[, colSums(data) > 0]

data <- data[, -1]

save(data, file = "data/processed/women_gut.RData")

rm(d)
rm(gut)
rm(types_ind)
