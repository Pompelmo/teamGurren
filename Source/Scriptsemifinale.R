source("Funzioni_2.0.R")
k_prec <- c(5,10,20,55) 
##------------------------
## Read data
##------------------------
# Flavonoids <- read.table("flavonoids_55_rank.csv", sep=",")
# colnames(Flavonoids) <- c("alpha", "Tile Dimension", "Number of Iteration", 1:55)
# a <- c(1:60,65:124)
# Flavonoids <- Flavonoids[a,]
# row.names(Flavonoids) <- NULL
# 
Fos <- read.table("new_big_table.csv", sep=",", header=T)
colnames(Fos) <- c("alpha", "Tile Dimension", "Number of Iteration", 1:55)
a <- c(1:80,85:164)
Fos <- Fos[a,]
row.names(Fos) <- NULL

ClassTable <- read.table("FOS_Classes_v6.csv", header=F, sep=",")

##------------------------
## Smaller lists
##------------------------
# BigTableT <- Fos[,1:23]
# BigTableT10 <- Fos[,1:13]

##------------------------
## Data.frames
##------------------------
## From Fos we can create some other smaller dataframes, where to aplly our rankings methods.

Exp1 <- Fos[81:160,]
row.names(Exp1) <- NULL

Exp4 <- Fos[1:80,]
row.names(Exp4) <- NULL

lowite <- vector("numeric")
lowite <- sort(c(which(Fos[,3]==20),which(Fos[,3]==50)))
Low_it <- Fos[lowite,]
row.names(Low_it) <- NULL

highite <- vector("numeric")
highite <- sort(c(which(Fos[,3]==1500),which(Fos[,3]==2000)))
High_it <- Fos[highite,]
row.names(High_it) <- NULL

smalltile <- vector("numeric")
smalltile <- sort(c(which(Fos[,2]==50),which(Fos[,2]==100)))
Small_t <- Fos[smalltile,]
row.names(Small_t) <- NULL

bigtile <- vector("numeric")
bigtile <- sort(c(which(Fos[,2]==1750),which(Fos[,2]==2000)))
Big_t <- Fos[bigtile,]
row.names(Big_t) <- NULL

## Flavonoids
# bigtileF <- vector("numeric")
# bigtileF <- sort(c(which(Flavonoids[,2]==1750),which(Flavonoids[,2]==2000)))
# Big_tF <- Flavonoids[bigtileF,]
# row.names(Big_tF) <- NULL

##--------------------------------------
## Applicazione esperimenti a dataframe
##--------------------------------------
dataframe <- Fos  # cambiare qua dataframe da considerare. 


# Per usare le varie funzioni su dataframe
a <- vector("numeric")
AA <- random_ranker(dataframe,col_discarded=3)
AA <- no_of_app_ranker(dataframe, 3)

AA <- borda_count_ranker(dataframe,3)
AA <- borda_count_ranker(dataframe,3, est=min)

AA <- mc4_ranker(dataframe,3)
AA <- mc4_ranker(dataframe,3, alpha=0.01)

AA <- bba_par_ranker(dataframe,3)
AA <- bba_par_ranker(dataframe, 3, Nite=(nrow(dataframe)/2))

AA <- bba_par_ranker(dataframe, 3, est=min)
AA <- bba_par_ranker(dataframe, 3, est=min, Nite=(nrow(dataframe)/2))

AA <- bba_par_ranker(dataframe, col_discarded=3, Nite=1, MC4=TRUE)
AA <- bba_par_ranker(dataframe, col_discarded=3, Nite=(nrow(dataframe)/2), MC4=TRUE)

# per la precisione
for(i in 1:length(k_prec)){
  a[i] <- precision_computator(AA, ClassTable, k_prec[i])
}
print(a)

# write.table(AA, "ranker_aggregator.txt", sep=" ")
