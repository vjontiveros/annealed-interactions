source("R/packages.R")

# Data was downloaded from
# https://www.sciencebase.gov/catalog/item/691cfb53d4be021d1d89b482 ,
# specifically, file States.zip. File W_Virgi.csv can be extracted from that
# file. It contains the observations of the NABBS for the state of West
# Virginia, which corresponds exclusively to the Bird Conservation Region of the
# Appalachian mountains.I stored the raw data in data/raw and now we read it.

d <- read.csv("data/raw/W_Virgi.csv")

data <- d %>% 
  group_by(AOU, Year) %>% summarise(n = sum(SpeciesTotal)) %>% 
  pivot_wider(names_from = AOU, values_from = n, values_fill = 0) %>% 
  ungroup() %>% dplyr::select(-1)

View(data) #Last year seems incomplete, I remove it.

save(data, file = "data/processed/WVirginia.RData")

rm(d)
