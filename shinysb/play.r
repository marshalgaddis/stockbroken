# TODO: remove redundant trialdata in this shinysb directory; figure out why
# this app can't just pull the data from the parent directory
`%tin%` <- function(x, y) {
    mapply(assign, as.character(substitute(x)[-1]), y,
      MoreArgs = list(envir = parent.frame()))
    invisible()
}

retrieveGoogleData <- function(symbol, period, url) {
  data <- getURL(url)
  lines <- strsplit(data, '\n')[[1]][-c(1:7)]
  returnData <- as.data.frame(matrix(rep(NA, length(lines)*8),ncol=8))
  colnames(returnData) <- c('symbol','date','time','open','high','low','close','volume')
  # returnData <- rep(NA, length(lines))
  for (i in 1:length(lines)) {
    # cat(lines[i], "\n")
    c(off,c,h,l,o,v) %tin% strsplit(lines[i], ',')[[1]]
    if (unlist(strsplit(off,""))[[1]] == 'a') {
      day <- as.numeric(substring(off,2))
      off <- 0
      # cat("got it: line ", i, ", day: ", day, "\n")
    }
    else {
      off <- as.numeric(off)
    }
    # c(open,high,low,close,volume) %tin% as.numeric(c(o,h,l,c,v))
    dt <- as.POSIXct(day + (period * off), origin='1970-01-01')
    date <- format(dt, "%Y-%m-%d")
    time <- format(dt, "%H:%M:%S")
    # print(dt)
    returnData[i,] <- c(toupper(symbol),date,time,o,h,l,c,v)
  }
  returnData$open <- as.numeric(returnData$open)
  returnData$close <- as.numeric(returnData$close)
  returnData$high <- as.numeric(returnData$high)
  returnData$low <- as.numeric(returnData$low)
  returnData$volume <- as.numeric(returnData$volume)
  return(returnData)
}


compareOldStocks <- function(queryStock,referenceStock,
                             plot=FALSE,twoway=TRUE,heat=FALSE) {
  queryFrame <- read.csv(paste("../trialdata/",toupper(queryStock),".csv",sep=''),
                         header=FALSE, as.is=TRUE,
                         col.names=c("symbol","date","time",
                                     "open","high","low","close","volume"))
  #print("got query")
  refFrame <- read.csv(paste("../trialdata/",toupper(referenceStock),".csv",sep=''),
                       header=FALSE, as.is=TRUE,
                       col.names=c("symbol","date","time",
                                   "open","high","low","close","volume"))
  #print("got ref")
  return(compareStocks(queryFrame,refFrame,plot,twoway,heat))
}

compareAgainst <- function(queryStock,referenceStockFrame,
                           plot=FALSE,twoway=TRUE,heat=FALSE) {
  queryStockFrame <- read.csv(paste("../trialdata/",toupper(queryStock),".csv",sep=''),
                              header=FALSE, as.is=TRUE,
                              col.names=c("symbol","date","time",
                                          "open","high","low","close","volume"))
  #print("got query")
  return(compareStocks(queryStockFrame,referenceStockFrame,plot,twoway,heat))
  # return(query)
}
  
compareStocks <- function(query,ref,
                          plot=FALSE,twoway=TRUE,heat=FALSE) {
  dt = paste(query$date, query$time, sep=' ')
  query$datetime <- as.numeric(strptime(dt, "%Y-%m-%d %H:%M:%S"))
  query$datetime <- (query$datetime - query$datetime[1]) / 300
  # print(head(dt))
  
  dt = paste(ref$date, ref$time, sep=' ')
  ref$datetime <- as.numeric(strptime(dt, "%Y-%m-%d %H:%M:%S"))
  ref$datetime <- (ref$datetime - ref$datetime[1]) / 300
  # print(head(dt))
  
  query_ts <- subset(query, select=c(datetime,open),datetime %in% ref$datetime)
  # print("query_ts")
  # print(head(query_ts))
  ref_ts <- subset(ref, select=c(datetime,open),datetime %in% query$datetime)
  # print("ref_ts")
  # print(head(ref_ts))
  

  # print("query_ts$datetime:")
  # print(head(query_ts$datetime))
  # print("ref_ts$datetime:")
  # print(head(ref_ts$datetime))
  
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
  #return(ans$distance)
  return(ans)
}

testfunc <- function(arg) {
  cat("this is", arg)
}


# TODO: move the data retrieval function into its own reactive server.R
# variable, then pass that in as the only argument to findNN().
findNN <- function(symbol, period, referenceURL) {
  winner <- NULL
  winDist <- Inf
  ref <- retrieveGoogleData(toupper(symbol), period, referenceURL)
  print(head(ref))
  print(list.files("../trialdata"))
  for (stock in list.files("../trialdata")) {
    stockName <- unlist(strsplit(stock, "\\."))[1]
    print(stockName)
    if (toupper(symbol) != stockName) {
      val <- compareAgainst(stockName,ref)$distance
      cat("stock: ", stockName, ",  dtw: ", val, "\n")
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
  query <- read.csv(paste("../trialdata/",stock,sep=''),
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
