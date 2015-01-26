#################################################
##              Functions                      ##
#################################################
library("markovchain")
library("hash")

##------------------------
## Precision computator
##------------------------

precision_computator <- function(dataframe_rank, dataframe_classes, k_firsts=nrow(dataframe_rank)){
  y  <- yC <- y.class <- vector("character")

  y <- as.character(dataframe_classes[,1])
  yC <- as.character(dataframe_classes[,2])
  xx <- as.character(dataframe_rank[,1])
  
    for(i in 1:length(xx)){
      if(length(yC[grep(xx[i], y)])==0){
        y.class[i] <- 0
        print(paste("gene", i, "class not found" ))
      } else{
        y.class[i] <- as.character(yC[grep(xx[i], y)])
      }
      }
  
  Data <- as.data.frame(cbind(dataframe_rank,y.class)) 
  if(k_firsts!=nrow(dataframe_rank) && Data[k_firsts,2]==Data[(k_firsts+1),2]){
    x <- Data[k_firsts,2]
    k <- which(Data[,2]==x)
    k_min <- min(k)-1
    n <- (length(which(Data$y.class[k]=="Class 1")) + length(which(Data$y.class[k]=="Class 2")))/length(k)
    a <- (length(which(Data$y.class[1:k_min]=="Class 1")) + 
            length(which(Data$y.class[1:k_min]=="Class 2"))+n*(k_firsts - k_min))/k_firsts 
  }  else{
  a <- (length(which(Data$y.class[1:k_firsts]=="Class 1")) + 
          length(which(Data$y.class[1:k_firsts]=="Class 2")))/k_firsts 
  }
  return(a)
}


##------------------------
## Random extract
##------------------------

random_ranker <- function(dataframe,col_discarded=0,k_max=(ncol(dataframe) - col_discarded)){
  dfl <- nrow(dataframe)
  x <- vector("character")        # metto in un vettore i primi K geni di ogni rank (primi K componenti=primo rank,
  for(j in 1:k_max){                  # da K+1 a 2K ci sono i primi K geni del secondo rank e così via)
    for(i in 1:dfl){                                     
      x[(i-1)*k_max + j] <- as.character(dataframe[i,col_discarded+j])
    }
  }  
  y <- vector("character")
  y <- unique(x) 
  yy <- length(y)

  s <- sample(y,yy)
  AA <- as.data.frame(cbind(s,1:yy))

  return(AA)
}

##-----------------------------------------------
## Funzione che calcola precisione del numero 
## di apparizioni nei primi K posti dei rank
##-----------------------------------------------
no_of_app_ranker <- function(dataframe, col_discarded=0,k_max=(ncol(dataframe) - col_discarded)){
  dfl <- nrow(dataframe)  
  x <- y <-  vector("character")        
  for(j in 1:k_max){                  
    for(i in 1:dfl){                                     
      x[(i-1)*k_max + j] <- as.character(dataframe[i, col_discarded + j])
    }
  }
  
  y <- unique(x)                  
  yy <- length(y)
  
  # In how many rank are our unique genes present?
  z <- vector("numeric")
  for(i in 1:yy) {
    z[i] <- length(grep(y[i], x)) 
  }
  
  AA <- as.data.frame(cbind(y,z))        
  AB <- AA[order(-z),]
  row.names(AB) <- NULL
  a <- 120 - as.numeric(as.character(AB$z))
  AAB <- data.frame(unique.probes = as.character(AB$y), rank = rank(a, ties.method="average"))
   
  return(AAB)
}

##-----------------------------------------------
## Borda Count: statistiche varie
##-----------------------------------------------

borda_count_ranker <- function(dataframe,col_discarded=0,k_max=ncol(dataframe) - col_discarded, est=mean){
  dfl <- nrow(dataframe)  
  x <- y <- vector("character")       
  for(j in 1:k_max){                 
    for(i in 1:dfl){                                     
      x[(i-1)*k_max + j] <- as.character(dataframe[i,col_discarded+j])
    }
  }
  
  y <- unique(x)  
  yy <- length(y)

  # compute Borda_Count matrix
  GeneRank <- matrix(0,yy,dfl)
  rownames(GeneRank) <- y
  colnames(GeneRank) <- c(1:dfl)
  
  ind <- w <-  vector("numeric")
  for(j in 1:(dfl+1)){
    ind[j] <- (j-1)*k_max
  }
  
  for(i in 1:yy){
    for(j in 1:dfl){
      if (is.na(which(y[i] == x[(ind[j]+1):ind[j+1]])[1]%%k_max) == TRUE){
        GeneRank[i,j] <- k_max
      } else if (which(y[i] == x[(ind[j]+1):ind[j+1]])[1]%%k_max == 0){
        GeneRank[i,j] <- k_max - 1
      } else {
        GeneRank[i,j] <- which(y[i]==x[(ind[j]+1):ind[j+1]])[1]%%k_max -1
      }
    }
  }
  
  w <- apply(GeneRank,1,est)
  
  AA <- as.data.frame(cbind(y,w))
  row.names(AA) <- NULL
  AB <- AA[order(w),]  
  row.names(AB) <- NULL  
  a <- as.numeric(as.character(AB$w))
  AAB <- data.frame(unique.probes = as.character(AB$y), rank = rank(a, ties.method="average")) 
  return(AAB)
}

##-----------------------------------------------
## MC4: da script del dott. Argentini
##-----------------------------------------------

mc4_ranker  <-  function(dataframe,col_discarded=0,k_max=ncol(dataframe) - col_discarded, alpha=0.05){
  dfl <- nrow(dataframe)
  x <- y <- vector("character")       
  for(j in 1:k_max){                 
    for(i in 1:dfl){                                     
      x[(i-1)*k_max + j] <- as.character(dataframe[i,col_discarded+j])
    }
  }
  
  y <- unique(x)  
  yy <- length(y)
     dfl <- nrow(dataframe)  
 
    GeneRank <- matrix(0,yy,dfl)
    rownames(GeneRank) <- y
    colnames(GeneRank) <- c(1:dfl)
  
    ind <- vector("numeric")
    for(j in 1:(dfl+1)){
    ind[j] <- (j-1)*k_max
   }
  
    for(i in 1:yy){
      for(j in 1:dfl){
        if (is.na(which(y[i] == x[(ind[j]+1):ind[j+1]])[1]%%k_max) == TRUE){
          GeneRank[i,j] <- k_max
        } else if (which(y[i] == x[(ind[j]+1):ind[j+1]])[1]%%k_max == 0){
          GeneRank[i,j] <- k_max - 1
        } else {
          GeneRank[i,j] <- which(y[i]==x[(ind[j]+1):ind[j+1]])[1]%%k_max -1
        }
      }
    }
  
  obj= as.character(y) 
  t_pro_mat<- matrix(0,ncol=yy,nrow=yy)     
  for (i in 1:yy){
    for (j in 1:yy){
      if (i != j ){
        kk=1
        good_count= 0
        while ( kk <= dfl){
          if (GeneRank[i,kk] < GeneRank[j,kk]){
            good_count= good_count+1
          }
          if (good_count >=round(dfl/2) ){ 
            t_pro_mat[i,j]= 1/yy
            break
          }
          kk=kk+1
          
        }      
      }
    }
    
  } 
  for (j in 1:yy){
    t_pro_mat[j,j]= 1 - sum(t_pro_mat[j,])
  }
  a=alpha
  t_p_mat_t = ((1-a)*t_pro_mat ) + a/yy
  MC4 <- new("markovchain", states = y, transitionMatrix = t_p_mat_t, name = "rank_aggr")
  result <- data.frame(key=y, rank=rank(round(steadyStates(MC4),digits=10),ties.method="average"))   
  result=result[order(result$rank),]
  row.names(result) <- NULL
  return(result)
}

##-------------------------------------------
## bba from Argentini scripts (top_K_partial)
##-------------------------------------------

bba_par_ranker <- function(dataframe,col_discarded=0,k_max=ncol(dataframe) - col_discarded, Nite=1, est=mean, MC4=FALSE){ 
  num <- nrow(dataframe)  
  
  Nite <- Nite + 1
  FLAG <- 1   
  type.est <- ifelse(FLAG ==1, nW <- FALSE, nW <- TRUE) 

  if (Nite < 1 ){
    print("ERROR:: Number of iterazione  is less than 1")
    break
  }
  
  l <- list("vector",num)  
  hl <- list()
  
  n1 <- col_discarded +1
  n2 <- col_discarded + k_max
  
  for(i in 1:num) {  
    a <-  t(dataframe[i,n1:n2]) 
    a <- as.data.frame(cbind(a,row.names(a)))
    hl[[i]] <- hash(keys=as.character(a[,1]), values=as.numeric(a[,2])) 
    l[[i]] <- a[,1]
  }
  
  U <- unique(as.character(unlist(l,use.names=FALSE)))  
  dRank<- matrix(0,ncol=num,nrow=length(U))
  
  BBA.exp <- list()  
  for(i in 1:num) {  
    BBA.exp[[i]]<-  hash( keys=as.character(U), values =lapply(1:length(U),bba.b,U,max=k_max,min=1,l=hl[[i]] ))
  }  
  if (type.est==0) {      
    Est <- matrix(0,ncol=1,nrow=length(U))
    
    for (j in 1:length(U)) {  
      for (ii in 1:num) {
        if ( has.key(as.character(U[j]),hl[[ii]]) ) {     
          dRank[j,ii] <- values(hl[[ii]], U[j])[[1]] 
        }else {                                      
          dRank[j,ii] <-k_max+1 }
      }      
    }
     if(MC4==TRUE){
       alpha <- 0.05
      Est[,1] <- as.data.frame(compute_MC4(dRank,U,alpha))$rank
      print("Estimator: Markov chain")
     } else{
      Est[,1] <- rank(apply(dRank,1,est))
     }
  }
  else{
    print("Not yet implemented")
    break    
  }
  
  TT <- 1
  dRank.S <- dRank           
  obj <-  as.character(U)   
  while (TT != Nite) {   
    if (TT >=2){        
       if(MC4==TRUE){
          Est[,1] <- as.data.frame(compute_MC4(dRank,U,alpha))$rank
        } else{
          Est[,1] <- rank(apply(dRank,1,est)) 
        }  
    }
    print(paste("Step: ",TT," of ",(Nite-1),sep=""))
    c <- EstInput.combinationFORn.Adaptive(dRank,obj,BBA.exp,nW,Est)
    
    if (c$S!=-1) {
      BBA.exp[[c$S]] <- c$H    
      dRank[,c$S] <-c$R 
    }
    TT <- TT+1  
  }
  
  Result <- data.frame(key=as.character(obj), rank=c$R)  
  Result=Result[order(Result$rank),]
  row.names(Result) <- NULL
  return(Result)
}


##---------------------------------------------------------------
## Function called in bba_par_ranker (all from Argentini scripts)
##---------------------------------------------------------------

bba.b <-  function(i,max,min, U,l) {
  if (U[i] %in% keys(l)) {
    p <- ((max-(as.numeric(as.character(values(l,as.character(U[i])))) -min))/max)
    i <- 1- ((max-(as.numeric(as.character(values(l,as.character(U[i])))) -min))/max)  
    return(c(p,0,i))}
   else{
    return(c(0,0,1))
  }
}
##--------------------------------------------

EstInput.combinationFORn.Adaptive <- function(ranki,dd,l,nW,Est) {
  if (nW == FALSE) {  
    Weight <- Adaptive.weight(ranki,Est,length(l),length(dd)) 
  }else{
    Weight <- rep(0,length(l))    
  }
  for (i in 1:length(l)) {      
    if (i== 1)  {
      O <-  hash( keys=dd, values =lapply(dd,massWeight,data=l[[i]] ,W=Weight[i]))
      
    }   
    else  {      
      O <- append(O,hash( keys=dd, values =lapply(dd,massWeight,data=l[[i]] ,W=Weight[i])))
    }  
  }

  if (length(l) == 2) {
    app <-  hash (keys=dd, values = lapply(dd,ConjuntiveRuleHASH,d1=O[[1]],d2=O[[2]]))
  }else {      
     app <-  hash (keys=dd, values = lapply(dd,ConjuntiveRuleHASH,d1=O[[1]],d2=O[[2]]))
    for (i in 3:length(l)) {
      app <-  hash (keys=dd, values = lapply(dd,ConjuntiveRuleHASH,d1=app,d2=O[[i]]))
    }
  }
  data <-  matrix (0,nrow=length(dd),ncol=6)
  data[,1:6] <- t(sapply(dd,retriveKey,d=app,USE.NAMES=FALSE))
  Result <- data.frame(key=dd, data=data[,5])
  if (nW ==FALSE){
    if( all(Weight==0)) {
      print("ho pesi uguali")       
      to.sub <-  sample(1:length(l), 1)
    }else {
      to.sub <- which(abs(Weight)==max(abs(Weight)))
      if (length(to.sub)>1){
        print("ci sono pesi uguali nei peggiori ")
        to.sub <-  to.sub[sample(1:length(to.sub), 1)]            
      }
    }
  }
  else {
    to.sub <- -1
  }
  Nrank <- rank(-Result[,2])
  Result[,2] <- Nrank
  s.new <-  hash( keys=dd,values=lapply(1:length(dd),massSIMPLE1,max=max(Nrank),min=1,x=Result[,2]))
  H=s.new
  return(list(H=s.new,R=Nrank,S=to.sub,W=Weight,O=app))
}
#----------------------------------------------

Adaptive.weight <- function(ranki,Est,L,n){
  f <- -1
  Weight <-  vector(length=L,mode="integer") 
  Fweight <-  vector(length=L,mode="integer") 
  for (i in 1:L) {
    Weight[i] <- Dnorm(ranki[,i],Est)
  }
  if (f==-1){
    Weight<- - Weight
    indAPP <- which(abs(Weight)==min(abs(Weight)))  
    Weight[indAPP] <- abs(Weight[indAPP])
    Fweight <- Weight
    return(Fweight)
  }
  MW <- mean(Weight)
  scarti <- MW-Weight
  if (f==1){
    print("V0")
    Fweight[which(scarti>0)] <- Weight[which(scarti>0)]
    Fweight[which(scarti<0)] <- -Weight[which(scarti<0)]
  }
  if (f==2 ){
    print("V1")
    Fweight[which(scarti>0)] <- scarti[which(scarti>0)]
    Fweight[which(scarti<0)] <- -Weight[which(scarti<0)]
  }
  if (f==3 ){
    print("V2")
    Fweight[which(scarti>0)] <- 1-Weight[which(scarti>0)]
    Fweight[which(scarti<0)] <- -Weight[which(scarti<0)]
  }
  if (f==4){
    print("V3")
    Fweight[which(scarti>0)] <- 1-Weight[which(scarti>0)]
    Fweight[which(scarti<0)] <- -(1-Weight[which(scarti<0)])
  }  
  return(Fweight)
}
#----------------------------------------------------

massWeight <-  function(x,data,W) {
  mb <- retriveKey(x,data)
  return(InBelief(mb,W))
}
#-----------------------------------------------------

InBelief <- function(bba,r) { 
  if (r>=0) {
    A <- bba[1]+r*bba[3]
    C <- 1-A
    return(c(A,0,C))}
  else {
    C <- bba[3]+(abs(r))*bba[1]
    A <- 1-C
    return(c(A,0,C))}
}
#------------------------------------------------------

retriveKey<-  function(x,d)  {     
  ifelse(has.key(x,d), return(c(d[[x]])),return( c(0,0,1))) }
#---------------------------------------------------------

compute_MC4 = function(dRank,obj, alpha){
  n_exp = dim(dRank)[2]
  obj= as.character(obj) 
  t_pro_mat<- matrix(0,ncol=length(obj),nrow=length(obj))     
  for (i in 1:length(obj)){
    for (j in 1:length(obj)){
      if (i != j ){
        kk=1
        good_count= 0
        while ( kk <= n_exp){
          if (dRank[i,kk] < dRank[j,kk]){
            good_count= good_count+1
          }
          if (good_count >=round(n_exp/2) ){ 
            t_pro_mat[i,j]= 1/length(obj)
            break
          }
          kk=kk+1
          
        }      
      }
    }   
  } 
  for (j in 1:length(obj)){
    t_pro_mat[j,j]= 1 - sum(t_pro_mat[j,])
  }
  a=alpha
  t_p_mat_t = ((1-a)*t_pro_mat ) + a/length(obj)
  MC4 <- new("markovchain", states = obj, transitionMatrix = t_p_mat_t, name = "rank_aggr") 
  result = data.frame(key=obj, rank=rank(round(steadyStates(MC4), digits=10), ties.method="average"))
  return( result )
} 
#---------------------------------------------

### D normalizzato la si usa anche per i.D
Dnorm <- function(a,b){
  if (length(a) ==length(b)){
    return(sum(abs(a-b))/(0.5*length(a)^2))}
  else{
    print("errore liste di lunghezza differente")
    return(-1)
  }
}
#------------------------------------------------

ConjuntiveRuleHASH <-  function(d1,d2,keys){
  x <- retriveKey(keys,d1)
  y <- retriveKey(keys,d2)
  A  <- x[1]*y[1]+x[1]*y[3]+ x[3]*y[1]
  B  <- x[2]*y[2]+x[2]*y[3]+ x[3]*y[2]
  nP <- x[3]*y[3]
  konf <-  x[1]*y[2]+x[2] *y[1]
  betP <- sum(A/(1-konf),(nP/(1-konf))*0.5)
  betnP <- sum(B/(1-konf),(nP/(1-konf))*0.5)
  
  #return(c(A,B,nP,konf,betP,betnP))
  return(c(A,B,nP,konf,betP,betnP))
}
#------------------------------------------------

massSIMPLE1 <-  function(i,x,max,min){
  #  x è un vettore in questo caso 
  p <- ((max-(x[i]-min))/max)
  i <- 1-((max-(x[i]-min))/max)  
  return(c(p,0,i))
}





