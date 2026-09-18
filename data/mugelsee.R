source("R/packages.R")

# Download datasets -------------------------------------------------------

# Dataset 625
url <- sprintf("https://biotime.st-andrews.ac.uk/dl_request.php?dl=rawdata&study=625")

r <- GET(url)

headers(r)[["content-type"]]
content(r)
dataset625 <- content(r)

# Dataset 626
url <- sprintf("https://biotime.st-andrews.ac.uk/dl_request.php?dl=rawdata&study=626")

r <- GET(url)

headers(r)[["content-type"]]
content(r)
dataset626 <- content(r)


# Getting references too --------------------------------------------------


ref_url <- "https://biotime.st-andrews.ac.uk/dl_request.php?dl=ref_csv"

# Read directly from URL
refs <- read_csv(ref_url, show_col_types = FALSE)

# Filter study 625, 626
refs_mugelsee <- refs %>% filter(STUDY_ID %in% c(625, 626))

View(refs_mugelsee)


# Mugelsee zooplankton ----------------------------------------------------

dataset626 %>% arrange(YEAR, MONTH) %>% View()

# first sample 1976_1

dataset626 %>% mutate(rel_mon = (YEAR - 1992) * 12 + MONTH) %>% 
  dplyr::select(ABUNDANCE, valid_name, rel_mon) %>% arrange(rel_mon) %>% View()

dataset626 %>% mutate(rel_mon = (YEAR - 1992) * 12 + MONTH) %>% 
  dplyr::select(ABUNDANCE, valid_name, rel_mon) %>% arrange(rel_mon) %>% 
  dplyr::select(rel_mon) %>% unique() %>% as.vector() %>% unname() %>% unlist() %>% diff()

data <-
  dataset626 %>% mutate(rel_mon = (YEAR - 1992) * 12 + MONTH) %>% 
  dplyr::select(ABUNDANCE, valid_name, rel_mon) %>% 
  group_by(valid_name, rel_mon) %>%
  summarise(ABUNDANCE = sum(ABUNDANCE, na.rm = TRUE), .groups = "drop") %>%
  arrange(rel_mon) %>% 
  pivot_wider(names_from = valid_name, values_from = ABUNDANCE, 
              values_fill = 0) %>% dplyr::select(-1)

save(data, file = "data/processed/Muggelsee_zoo.RData")


# NAs in phyto for Mugelsee -----------------------------------------------

dataset625 %>% mutate(rel_mon = (YEAR - 1992) * 12 + MONTH) %>% 
  dplyr::select(ABUNDANCE, BIOMAS, valid_name, rel_mon) %>% arrange(rel_mon) %>% 
  filter(is.na(BIOMAS)) %>% View()


sp_index <- 
  dataset625 %>% mutate(rel_mon = (YEAR - 1992) * 12 + MONTH) %>% 
  dplyr::select(ABUNDANCE, BIOMAS, valid_name, rel_mon) %>% arrange(rel_mon) %>% 
  filter(is.na(BIOMAS)) %>% dplyr::select(valid_name) %>% unique() %>% 
  as.vector() %>% unlist()

# Seeing if a lm in log-scale works better.
pvals <- data.frame()

for(i in 1:32){
  sp1 <- dataset625 %>% filter(valid_name == sp_index[i]) 
  lm1 <- lm(log(BIOMAS) ~ log(ABUNDANCE), sp1) 
  lm2 <- lm(BIOMAS ~ ABUNDANCE, sp1) 
  
  pvals <- rbind(pvals, data.frame(log = tryCatch(
    summary(lm1)$coefficients[2, 4],
    error = function(e) NA_real_
  ),
  natural = tryCatch(
    summary(lm2)$coefficients[2, 4],
    error = function(e) NA_real_
  )))
}

pvals %>% mutate(index = 1:32, log.better = log < natural) %>% filter(log.better == T)

# Log space works better in the following species
sp.log <- sp_index[pvals %>% mutate(index = 1:32, log.better = log < natural) %>% 
                     filter(log.better == T) %>% dplyr::select(index) %>% 
                     unlist() %>% 
                     unname()]

# In these species we do not have enough combinations BIOMAS-ABUNDANCE for a lm,
# we'll treat them using proportions.
sp.na <- sp_index[pvals %>% mutate(index = 1:32, log.better = log < natural) %>% 
                    filter(is.na(log.better)) %>% dplyr::select(index) %>% 
                    unlist() %>% 
                    unname()]

# In these ones, we don't log-transform, unless we get negative values in the prediction.
sp.nat <- sp_index[pvals %>% mutate(index = 1:32, log.better = log < natural) %>% 
                     filter(log.better == F) %>% dplyr::select(index) %>% 
                     unlist() %>% 
                     unname()]


# Predictions of the ones that do not need log-transform.
neg.values <- NULL
temp1 <- NULL
temp2 <- NULL
for(i in 1:length(sp.nat)){
  sp1 <- dataset625 %>% filter(valid_name == sp.nat[i]) 
  lm1 <- lm(BIOMAS ~ (ABUNDANCE), sp1) 
  pred <- predict(lm1, dataset625 %>% filter(valid_name == sp.nat[i]) %>% 
            filter(is.na(BIOMAS)) %>% dplyr::select(ABUNDANCE)) 
  if(any(pred < 0)){
    neg.values <- c(neg.values, sp.nat[i])
    next
  }
  
  temp2 <- rbind(temp2,
                 sp1 %>% filter(is.na(BIOMAS)) %>% mutate(BIOMAS = pred))
}

# Predictions with log-transformation
sp.log <- c(sp.log, neg.values)

for(i in 1:length(sp.log)){
  sp1 <- dataset625 %>% filter(valid_name == sp.log[i]) 
  lm1 <- lm(log(BIOMAS) ~ log(ABUNDANCE), sp1)
  
  newdata <- sp1 %>% 
    filter(is.na(BIOMAS)) %>% 
    dplyr::select(ABUNDANCE)
  
  pred <- exp(predict(lm1, newdata))
  temp2 <- rbind(temp2,
                 sp1 %>% filter(is.na(BIOMAS)) %>% mutate(BIOMAS = pred))
}

# Predictions doing proportions.
sp1 <- dataset625 %>% filter(valid_name == sp.na[1]) 
temp2 <- rbind(temp2,
               sp1 %>% filter(is.na(BIOMAS)) %>% 
                 mutate(BIOMAS = 
                          sp1$ABUNDANCE[3] * sp1$BIOMAS[4] / sp1$ABUNDANCE[4]))

sp1 <- dataset625 %>% filter(valid_name == sp.na[2]) 
temp2 <- rbind(temp2,
               sp1 %>% filter(is.na(BIOMAS)) %>% 
                 mutate(BIOMAS = 
                          sp1$ABUNDANCE[4] * sp1$BIOMAS[2] / sp1$ABUNDANCE[2]))

sp1 <- dataset625 %>% filter(valid_name == sp.na[3]) 
mean.sp.na3 <- sp1 %>% filter(!is.na(BIOMAS)) %>% 
  dplyr::select(ABUNDANCE, BIOMAS) %>% colMeans()
temp2 <- rbind(temp2,
               sp1 %>% filter(is.na(BIOMAS)) %>% 
                 mutate(BIOMAS = ABUNDANCE * mean.sp.na3[2] / mean.sp.na3[1]))

sp1 <- dataset625 %>% filter(valid_name == sp.na[4]) 
mean.sp.na4 <- sp1 %>% filter(!is.na(BIOMAS)) %>% filter(!is.na(ABUNDANCE)) %>% 
  dplyr::select(ABUNDANCE, BIOMAS) %>% colMeans()
temp2 <- rbind(temp2,
               sp1 %>% filter(is.na(BIOMAS)) %>% 
                 mutate(BIOMAS = ABUNDANCE * mean.sp.na4[2] / mean.sp.na4[1]))

# Changing the NAs to the predictions.
dataset625 <- dataset625 %>% filter(!is.na(BIOMAS))
dataset625 <- rbind(dataset625, temp2)


# Getting the phyto dataset -----------------------------------------------

dataset625 %>% arrange(YEAR, MONTH) %>% View()

# first sample 1976_1

dataset625 %>% mutate(rel_mon = (YEAR - 1992) * 12 + MONTH) %>% 
  dplyr::select(BIOMAS, valid_name, rel_mon) %>% arrange(rel_mon) %>% View()

dataset625 %>% mutate(rel_mon = (YEAR - 1992) * 12 + MONTH) %>% 
  dplyr::select(BIOMAS, valid_name, rel_mon) %>% arrange(rel_mon) %>% 
  dplyr::select(rel_mon) %>% unique() %>% as.vector() %>% unname() %>% 
  unlist() %>% diff()

#Check if there are duplicates month-species
dataset625 %>%
  mutate(rel_mon = (YEAR - 1992) * 12 + MONTH) %>%
  dplyr::count(rel_mon, valid_name) %>%
  filter(n > 1)

data <- 
  dataset625 %>% mutate(rel_mon = (YEAR - 1992) * 12 + MONTH) %>% 
  dplyr::select(BIOMAS, valid_name, rel_mon) %>% 
  arrange(rel_mon) %>% 
  pivot_wider(names_from = valid_name, values_from = BIOMAS, 
              values_fill = 0) %>% dplyr::select(-1)


save(data, file = "data/processed/Muggelsee_phyto.RData")

