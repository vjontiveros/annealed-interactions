source("R/packages.R")

# Data was downloaded from gbif with the following call:
# occ_download(
#   pred("datasetKey", "83ae75fc-f762-11e1-a439-00145eb45e9a"))

# In this repository, I stored the data in data/raw and now we read it.

d <- occ_download_get(key = "0024679-251025141854904", path = 'data/raw/') %>%
  occ_download_import()

data <- d %>% 
  group_by(year, acceptedTaxonKey) %>% summarise(n = n()) %>% 
  pivot_wider(names_from = acceptedTaxonKey, values_from = n, values_fill = 0) %>% 
  ungroup() %>% arrange(year) %>% select(-1)

View(data) #Last year seems incomplete, I remove it.

data <- data[-26, ]

save(data, file = "data/processed/ecnasap.RData")

rm(d)
