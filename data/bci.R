source("R/packages.R")

# BCI data from version Jun 07, 2019 is available as a Dryad dataset located at
# https://datadryad.org/dataset/doi:10.15146/5xcp-0d46 . Specifically, we
# downloaded file bci.tree.zip and extracted its contents in folder data/raw.
# This file contains a record for every tree ever recorded in the BCI census.
# Dead trees and other situations were also recorded, so for our purposes we
# kept just trees with a status that implies that the tree was alive (A, AR, AD,
# AM). We used the biomass of the trees to obtain a temporal dataset.


load("data/raw/bci.tree1.rdata")
load("data/raw/bci.tree2.rdata")
load("data/raw/bci.tree3.rdata")
load("data/raw/bci.tree4.rdata")
load("data/raw/bci.tree5.rdata")
load("data/raw/bci.tree6.rdata")
load("data/raw/bci.tree7.rdata")
load("data/raw/bci.tree8.rdata")

bci1 <- bci.tree1 %>% 
  filter(status == "A" | status == "AD" | status == "AR" | status == "AM") %>% 
  group_by(sp) %>% summarise(n = sum(agb)) %>% arrange(n)

bci2 <- bci.tree2 %>% 
  filter(status == "A" | status == "AD" | status == "AR" | status == "AM") %>% 
  group_by(sp) %>% summarise(n = sum(agb)) %>% arrange(n)

bci3 <- bci.tree3 %>% 
  filter(status == "A" | status == "AD" | status == "AR" | status == "AM") %>% 
  group_by(sp) %>% summarise(n = sum(agb)) %>% arrange(n)

bci4 <- bci.tree4 %>% 
  filter(status == "A" | status == "AD" | status == "AR" | status == "AM") %>% 
  group_by(sp) %>% summarise(n = sum(agb)) %>% arrange(n)

bci5 <- bci.tree5 %>% 
  filter(status == "A" | status == "AD" | status == "AR" | status == "AM") %>% 
  group_by(sp) %>% summarise(n = sum(agb)) %>% arrange(n)

bci6 <- bci.tree6 %>% 
  filter(status == "A" | status == "AD" | status == "AR" | status == "AM") %>% 
  group_by(sp) %>% summarise(n = sum(agb)) %>% arrange(n)

bci7 <- bci.tree7 %>% 
  filter(status == "A" | status == "AD" | status == "AR" | status == "AM") %>% 
  group_by(sp) %>% summarise(n = sum(agb)) %>% arrange(n)

bci8 <- bci.tree8 %>% 
  filter(status == "A" | status == "AD" | status == "AR" | status == "AM") %>% 
  group_by(sp) %>% summarise(n = sum(agb)) %>% arrange(n)


d <- full_join(bci1, bci2, by = "sp")
d <- full_join(d, bci3, by = "sp")
d <- full_join(d, bci4, by = "sp")
d <- full_join(d, bci5, by = "sp")
d <- full_join(d, bci6, by = "sp")
d <- full_join(d, bci7, by = "sp")
d <- full_join(d, bci8, by = "sp")

d <- t(d[, -1])
d[is.na(d)] <- 0

data <- d

View(data) #All good

save(data, file = "data/processed/bci.RData")

rm(d)
rm(bci.tree1, bci.tree2, bci.tree3, bci.tree4, bci.tree5, bci.tree6, bci.tree7, bci.tree8)
rm(bci1, bci2, bci3, bci4, bci5, bci6, bci7, bci8)
