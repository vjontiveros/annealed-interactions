# Source packages and functions -------------------------------------------

source("R/packages.R")
source("R/gLV_moments.R")

# Load the data file with the abundances time series ----------------------
folder <- "data/processed/"
file_name <- "portal_rodents"
extension <- ".RData"
load(paste(folder,file_name,extension,sep=""))

# Order the data from highest to lowest mean abundance --------------------
df<-data[,order(colSums(data), decreasing = T)]

# Define some parameters --------------------------------------------------
min_S <- 3 #minimum number of species in the core
max_S <- ncol(data) #total number of species in the community
least<-min(data[data>0]) #minum non-zero abundance
off <- least/2. # threshold for setting the zero-abundances
boot_B <- 1000 #number of bootstrap resamplings

#Get a dataframe for the parameters of the model from min_S to max_S species
set.seed(123)
moments <- gLV_moments(data = data, ranks = min_S:max_S, off = off,boot_B = boot_B)
moments
#Save the data
output_folder <- "output/"
write.csv(moments,paste(output_folder,"moments_",file_name,".csv",sep=""), row.names = FALSE)

