compareStocks <- function(queryStock,referenceStock,
                          plot=FALSE,twoway=TRUE,heat=FALSE) {
  query <- read.csv(paste("trialdata/",toupper(queryStock),".csv",sep=''),
                    header=FALSE, as.is=TRUE,
                    col.names=c("symbol","date","time",
                                "open","high","low","close","volume"))
  #print("got query")
  ref <- read.csv(paste("trialdata/",toupper(referenceStock),".csv",sep=''),
                  header=FALSE, as.is=TRUE,
                  col.names=c("symbol","date","time",
                              "open","high","low","close","volume"))
  #print("got ref")
  
  dt = paste(query$date, query$time, sep=' ')
  query$datetime <- as.numeric(strptime(dt, "%Y-%m-%d %H:%M:%S"))
  
  dt = paste(ref$date, ref$time, sep=' ')
  ref$datetime <- as.numeric(strptime(dt, "%Y-%m-%d %H:%M:%S"))
  
  query_ts <- subset(query, select=c(datetime,open),datetime %in% ref$datetime)
  ref_ts <- subset(ref, select=c(datetime,open),datetime %in% query$datetime)
  
  ref_ts$datetime <- (ref_ts$datetime - ref_ts$datetime[1]) / 300
  query_ts$datetime <- (query_ts$datetime - query_ts$datetime[1]) / 300
  
  r <- 100 * (ref_ts$open)/(ref_ts$open[1])
  q <- 100 * (query_ts$open)/(query_ts$open[1])
  
  ans <- dtw(q,r,k=TRUE,dist.method="Euclidean")
  if (plot == TRUE) {
    if (twoway == TRUE) {
      plot(ans,type="two",off=1,match.lty=2,match.indices=20)
    }
    else if (heat) {
      par(mfrow=c(1,2))
      plot(ans,type="three",off=1,match.lty=2,match.indices=20)
      heatmap(as.matrix(ans$costMatrix),Rowv=NA,Colv=NA)
    }
    else {
      plot(ans,type="three",off=1,match.lty=2,match.indices=20)
    }
  }  
  return(ans$distance)
}

testfunc <- function(arg) {
  cat("this is", arg)
}

findNN <- function(ref) {
  winner <- NULL
  winDist <- Inf
  for (stock in list.files("trialdata")) {
    stockName <- unlist(strsplit(stock, "\\."))[1]
    # print(stockName)
    if (toupper(ref) != stockName) {
      val <- compareStocks(stockName,ref)
      if (val < winDist) {
        winDist <- val
        winner <- stockName
      }
    }
  }
  cat("winner is: ", winner)
  return(winner)
}

### The earlier functions should be redefined in terms of this one

retrieveTS <- function(stock, period) {
  query <- read.csv(paste("trialdata/",stock,sep=''),
                    header=FALSE, as.is=TRUE,
                    col.names=c("symbol","date","time",
                                "open","high","low","close","volume"))
  
  dt = paste(query$date, query$time, sep=' ')
  query$datetime <- as.numeric(strptime(dt, "%Y-%m-%d %H:%M:%S"))
  # query_ts <- subset(query, select=c(datetime,open),datetime %in% ref$datetime)
  query$datetime <- (query$datetime - query$datetime[1]) / period
  
  query$open <- 100 * (query$open)/(query$open[1])

  return(subset(query, select = c(datetime, open)))
}

### Unused because folding in R sucks 
instersectAppend <- function(accumulatedFrame, stock) {
  y <- retrieveTS(stock,300)
  merge(y, accumulatedFrame, by="datetime", all=TRUE)
}

### Lots of missing data (means lots of "NA"s in the final matrix). Needs
### to be cleaned up by copying previous values

buildMatrix <- function(files) {
  mat <- retrieveTS(files[1],300)
  matsuffix <- unlist(strsplit(files, "\\."))[1]
  for (stock in files[2:length(files)]) {
    y <- retrieveTS(stock,300)
    ysuffix <- unlist(strsplit(stock, "\\."))[1]
    mat <- merge(y, mat, by="datetime", all=TRUE,
                 suffixes = c(ysuffix, ""))
    # print(mat)
  }
  colnames(mat)[length(mat)] <- paste("open", matsuffix, sep="")
  # print(mat)
  return(mat)
}

repeat.before = function(x) {   # repeats the last non NA value. Keeps leading NA
  ind = which(!is.na(x))      # get positions of nonmissing values
  if(is.na(x[1]))             # if it begins with a missing, add the 
    ind = c(1,ind)        # first position to the indices
  rep(x[ind], times = diff(   # repeat the values at these indices
    c(ind, length(x) + 1) )) # diffing the indices + length yields how often 
}                               # they need to be repeated

tightenUp <- function(tss) {
  for (i in 2:(length(tss))) {
    tss[,i] <- repeat.before(tss[,i])
  }
  return(tss)
}