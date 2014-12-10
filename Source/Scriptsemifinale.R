source("Funzioni_2.0.R")
k_prec <- c(5,10,20,55) 
##------------------------
## Read data
##------------------------
Flavonoids <- read.table("flavonoids_55_rank.csv", sep=",")
colnames(Flavonoids) <- c("alpha", "Tile Dimension", "Number of Iteration", 1:55)
a <- c(1:60,65:124)
Flavonoids <- Flavonoids[a,]
row.names(Flavonoids) <- NULL

BigTable <- read.table("BigTable.csv", header=F, sep=",")
colnames(BigTable) <- c("alpha", "Tile Dimension", "Number of Iteration", 1:55)
b <- c(1:80,85:164)
BigTable <- BigTable[b,]
row.names(BigTable) <- NULL

NewBigTable <- read.table("new_big_table.csv", header=T, sep="\t")
colnames(NewBigTable) <- c("alpha", "Tile Dimension", "Number of Iteration", 1:55)
NewBigTable <- NewBigTable[b,]
row.names(NewBigTable) <- NULL

ClassTable <- read.table("unique_probes_annotated_Supp Table.csv", header=T, sep="\t")

dataframe_classes <- ClassTable[,c(1,5)]
##------------------------
## Smaller lists
##------------------------
BigTableT <- BigTable[,1:23]
BigTableT10 <- BigTable[,1:13]

##------------------------
## Data.frames
##------------------------
## From BigTable we can create some other smaller dataframes, where to aplly our rankings methods.

Exp1 <- BigTable[81:160,]
row.names(Exp1) <- NULL

Exp4 <- BigTable[1:80,]
row.names(Exp4) <- NULL

lowite <- vector("numeric")
lowite <- sort(c(which(BigTable[,3]==20),which(BigTable[,3]==50)))
Low_it <- BigTable[lowite,]
row.names(Low_it) <- NULL

highite <- vector("numeric")
highite <- sort(c(which(BigTable[,3]==1500),which(BigTable[,3]==2000)))
High_it <- BigTable[highite,]
row.names(High_it) <- NULL

smalltile <- vector("numeric")
smalltile <- sort(c(which(BigTable[,2]==50),which(BigTable[,2]==100)))
Small_t <- BigTable[smalltile,]
row.names(Small_t) <- NULL

bigtile <- vector("numeric")
bigtile <- sort(c(which(BigTable[,2]==1750),which(BigTable[,2]==2000)))
Big_t <- BigTable[bigtile,]
row.names(Big_t) <- NULL

## Flavonoids
bigtileF <- vector("numeric")
bigtileF <- sort(c(which(Flavonoids[,2]==1750),which(Flavonoids[,2]==2000)))
Big_tF <- Flavonoids[bigtileF,]
row.names(Big_tF) <- NULL

##--------------------------------------
## Applicazione esperimenti a dataframe
##--------------------------------------
dataframe <- BigTableT10 # cambiare qua dataframe da considerare. 

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

AA <- bba.x_par_ranker(dataframe,3)
AA <- bba.x2_par_ranker(dataframe,3)

for(i in 1:length(k_prec)){
  a[i] <- precision_computator(AA, dataframe_classes, k_prec[i])
}
print(a)


AA <- mc4_ranker(Flavonoids,3)
write.table(AA,file="Flavonoids(all)MC4.txt",sep="\t")

