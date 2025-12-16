source("R/packages.R")

# Data was downloaded from
# https://github.com/weecology/PortalData/tree/main/Rodents the 2025/12/16. It
# contains captures of rodents (and other species) each lunar cycle from 1977 up
# to the present. 

d <- read.csv("data/raw/Portal_rodent.csv")

species_list <- read.csv("data/raw/Portal_rodent_species.csv")
specs <- species_list %>% filter(rodent == 1) %>% dplyr::select(speciescode) %>% unlist()

data <- d %>% 
  filter(year < 2020) %>% filter(period > 0) %>% 
  filter(!is.na(species)) %>% filter(species %in% specs) %>% 
  group_by(period, species) %>% 
  summarise(n = n()) %>% 
  pivot_wider(names_from = species, values_from = n, values_fill = 0) %>% 
  ungroup() %>% 
  dplyr::select(-1)


View(data) #All good

save(data, file = "data/processed/portal_rodents.RData")

rm(d)
rm(species_list)
rm(specs)
