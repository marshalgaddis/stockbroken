# TODO: make the variable names based on query and reference more consistent

library(shiny)
library(datasets)
library(dtw)
library(RCurl)

source("play.r")

tsMatrix <- buildMatrix(list.files("../trialdata"))
gapless_tsMatrix <- tightenUp(tsMatrix)
t <- t(gapless_tsMatrix)
colnames(t) <- t[1,]
u <- t[-1,]

# Define server logic required to plot various variables against mpg
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

  qdf <- reactive({
    retrieveGoogleData(userQuery()$stock, as.numeric(userQuery()$period),
                       url_string())
  })

  winner <- reactive({
    findNN(userQuery()$stock, qdf())
  })
  
  output$queryReport <- renderText({
    paste('you chose: ', userQuery()$stock, "\n", url_string(), sep="")
  })

  output$winner <- renderText({
   paste("The winner is: ", winner())
  })

  output$compPlot <- renderPlot({
    print("\n\n\n LOOOOOOK \n\n\n")
    cat(userQuery()$stock, userQuery()$period, url_string())
    print("")
    # winner <- "lux"
    ans <- compareAgainst(winner(), qdf())
    plot(ans,type="two",off=1,match.lty=2,match.indices=20)
  }, bg="transparent")

  output$taste <- renderPrint({
    print(head(u[,1:7]))
  })

 output$hmPlot <- renderPlot({
   distMatrix <- as.matrix(dist(u))
   heatmap(distMatrix)
 }, bg="transparent")

})
