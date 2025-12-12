#Cost function
cost <- function(cant,errores){
  if(!is.null(cant) && !is.na(nrow(cant))){
    (errores/cant)^2 %>% rowSums()
  }
}

#moving window 
best_moments <-function(data, offset = 0., Nspec = 50, least_length=800, full_length = 999, l_step=1){
  c_ref<-100000
  dd<-1:10
  ee<-1:10
  for(n in seq(least_length, full_length, by = l_step)){
    print(n)
    rdata<-rollapply(data, width=n,FUN = function(x) gLV_moments(x, Nspec, offset=offset),by.column = FALSE,  # Crucial: passes a data.frame (not columns individually)
                     align = "right",
                     fill = NA)
    rdata_2 <- rdata[complete.cases(rdata),]
    
    if(any(rdata_2[,3]>0)){
      cant <- rdata_2[,1:5][rdata_2[,3]>0,]
      e_cant <- rdata_2[,6:10][rdata_2[,3]>0,]
      if (is.vector(cant)) {
        cant <- matrix(cant, nrow = 1)
        e_cant <- matrix(e_cant, nrow = 1)
      }
      cc<-cost(cant,e_cant)
      ind <- which.min(cc)
      cmin <- cc[ind]
      if(cmin<c_ref){
        c_ref<-cmin
        nmin<-n
        dd<-cant[ind,]
        ee<-e_cant[ind,]
      }
    }
  }
  c(dd,ee*qnorm(0.99))
}
