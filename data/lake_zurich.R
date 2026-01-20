source("R/packages.R")

# Raw data on biomass by taxa was provided by Francesco Pomati. 

d <- read.delim("data/raw/phyto_ZH_aggregated_20m_rounded_s.txt")

firstday <- "1976-01-14"

# We pool data to the genus level when available, as some species
# identifications might be unreliable through time.

taxonomy <- d %>% dplyr::select(empire,kingdom, phylum, class, order, family, genus) %>% 
  distinct() %>% mutate( idspecies = 1:n()  ) 
biomass <-  d %>% left_join(taxonomy) %>% dplyr::select(-c(species, size, unit, analysis, biomass_w)) 
biomass <- biomass %>% group_by(idspecies, date) %>% summarise(bm = sum(biomass)) %>% 
  dplyr::select(date, idspecies, bm) 
biomass$date <-  round(difftime(biomass$date,firstday, units = "days"))

data <- biomass %>% 
  pivot_wider(names_from = idspecies, values_from = bm, values_fill = 0) %>% 
  dplyr::select(-1)

save(data, file = "data/processed/LZ.RData")

rm(d)
rm(firstday)
rm(taxonomy)
rm(biomass)
