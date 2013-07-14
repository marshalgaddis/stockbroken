# TODO: make the variable names based on query and reference more consistent

library(shiny)
library(datasets)
library(dtw)
library(RCurl)

source("play.r")

## This can be used to cluster and/or heatmap all of the current data
##
# tsMatrix <- buildMatrix(list.files("../trialdata"))
# gapless_tsMatrix <- tightenUp(tsMatrix)
# t <- t(gapless_tsMatrix)
# colnames(t) <- t[1,]
# u <- t[-1,]

## Generate a filler plot
##
# png("exampleplot.png")
# dem <- compareOldStocks("abg","acm")
# plot(dem,type="two",off=1,match.lty=2,match.indices=20)
# dev.off()

## Some global state for remembering recent queries and 
## writing them out as html
##
queryList <- NULL

makeQueryLinkText <- function(x) {
  return(paste("<li> ",
               "<a href='https://www.google.com/finance?q=",
               x,
               "'> ",
               x,
               "</a> ",
               "</li>", sep=""))
}

queryListToString <- function(ql) {
  strings <- lapply(ql, makeQueryLinkText)
  return(paste("<ul>", do.call("paste", strings), "</ul>"))
}

# Define server logic required to plot best match
shinyServer(function(input, output) {

  userQuery <- reactive({
    list(stock=toupper(input$stock), period=input$period, days=input$days)
  })

  url_string <- reactive({
    paste("http://www.google.com/finance/getprices?q=", userQuery()$stock,
          "&i=", userQuery()$period,
          "&p=", userQuery()$days,
          "d&f=d,o,h,l,c,v", sep="")
  })

  output$queryReport <- renderText({
    url_string()
  })

  updateQueryList <- reactive({
    # The assignment here is global. This is probably bad practice.
    queryList <<- c(userQuery()$stock, queryList)
  })

  output$recent <- renderUI({
    HTML(queryListToString(updateQueryList()))
  })

  ################################################## 
  ## Save time while working on other things by
  ## commenting out this interactive part
  ################################################## 

  qdf <- reactive({
    retrieveGoogleData(userQuery()$stock, as.numeric(userQuery()$period),
                       url_string())
  })

  winner <- reactive({
    findNN(userQuery()$stock, qdf())
  })
  
  output$winner <- renderText({
   paste("The winner is: ", winner())
  })

  output$compPlot <- renderPlot({
    #print("\n\n\n LOOOOOOK \n\n\n")
    #cat(userQuery()$stock, userQuery()$period, url_string())
    #print("")
    # winner <- "lux"
    ans <- compareAgainst(winner(), qdf())
    q <- winner()
    r <- userQuery()$stock
    m <- paste("Most similar stock on file:", q)
    plot(ans,type="two",off=1,match.lty=2,match.indices=20,
         main=m, xlab=r, ylab=q)
  }, bg="transparent")

  ################################################## 

  output$fillerPlot <- renderPlot({
    dem <- compareOldStocks("abg","acm")
    m <- "Most similar stock on file: ACM"
    plot(dem,type="two",off=1,match.lty=2,match.indices=20,
         ylab="ACM",main=m)
    mtext(side=4, line=1, "ABG")
  })


## Generates a preview table and heatmap of the current database
##
#  output$taste <- renderPrint({
#    print(head(u[,1:7]))
#  })
#
# output$hmPlot <- renderPlot({
#   distMatrix <- as.matrix(dist(u))
#   heatmap(distMatrix)
# }, bg="transparent")

})
