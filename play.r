compareStocks <- function(queryStock,referenceStock,plot=FALSE) {
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
    plot(ans,type="two",off=1,match.lty=2,match.indices=20)
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
