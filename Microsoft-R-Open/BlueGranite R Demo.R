## ----rmarkdown install---------------------------------------------------
if (!require("rmarkdown")) install.packages("rmarkdown" 
                                            , repos='https://cran.revolutionanalytics.com')
library(rmarkdown)

## ----setup, include=TRUE-------------------------------------------------
knitr::opts_chunk$set(cache = TRUE, 
                      echo  = TRUE)
options(scipen=1, digits=4)

## ----package management--------------------------------------------------
# ensure package 'pacman' for package management is installed
if (!require("pacman")) install.packages("pacman")
library(pacman)

# add any required packages to the p_load() function parameters 
pacman::p_load(rmarkdown # markdown functionality
               , knitr        # for table formatting
               , dplyr        # for data wrangling
               , memisc       # for convenient control structures like 'case'
               , ggplot2      # for better visualizations
               , ggthemes     # color themes for ggplot2
               , ggsci        # Scientific Journal and 
                              # Sci-Fi Themed Color Palettes
               , grid         # enhance ggplot2
               , gridExtra    # enhance ggplot2
               , corrplot     # for corrleation plots
               , reshape2     # for data wrangling
               , randomForest # machine learning pkg
               , tree         # regression tree
               , dendextend   # for hierarchical clustering
               , cluster      # for clustering
               , amap         # for clustering
               , fclust       # for fuzzy clustering
               , factoextra   # fancy cluster plots
               , fpc          # cluster stats
               , mclust       # advanced clustering
               , plyr         # data wrangling
               , update=FALSE)
pacman::p_loaded() # check which packages are loaded

## ----data access---------------------------------------------------------
getwd() # current working directory
data("iris")
dfS <- data.frame(cbind(scale(iris[1:4]), (iris[,"Species"]))) # scaled data frame
dfS <- dplyr::select(dfS, c(feature1 = Sepal.Length
                            , feature2 = Sepal.Width
                            , feature3 = Petal.Length
                            , feature4 = Petal.Width
                            , cluster  = V5)) 

dfS$cluster <- as.factor(dfS$cluster)

rm(iris)

## ----function MultiPlot--------------------------------------------------
# This code creates a correlation matrix with r and p values
# Code from: http://bit.ly/24hV4Xz
# Help page for the function pairs() gives you example how to define panels to plot.

panel.cor <- function(x, y, digits=2, cex.cor) {
  usr          <- par("usr"); on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r            <- abs(cor(x, y))
  txt          <- format(c(r, 0.123456789), digits=digits)[1]
  test         <- cor.test(x,y)
  Signif       <- ifelse(round(test$p.value,3) < 0.001,
                         "p<0.001",
                         paste("p=", round(test$p.value,3))
                         )  
  #text(0.5, 0.25, paste("r=",txt))
  if(missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)
  text(0.5, 0.25, txt, cex = cex.cor * (1 + r) /3)
  text(.5, .75, Signif)
}

# For panel.smooth() function defined cex=, col= and pch= arguments.
panel.smooth <- function (x, y, col = "cornflowerblue", bg = NA, pch = 18, 
                        cex = 0.8, col.smooth = "red", span = 2/3, iter = 3, ...) {
  points(x, y, pch = pch, col = col, bg = bg, cex = cex)
  ok <- is.finite(x) & is.finite(y)
  if (any(ok)) 
    lines(stats::lowess(x[ok], y[ok], f = span, iter = iter), 
          col = col.smooth, ...)
}

# To add histograms, panel.hist() functions should be 
# defined (taken from help file of pairs())
panel.hist <- function(x, ...) {
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5) )
  h <- hist(x, plot = FALSE)
  breaks <- h$breaks; nB <- length(breaks)
  y <- h$counts; y <- y/max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col="coral", ...)
}

# pairs plot of distribution, scatter, r, and p-values between variables
MultiPlot <- function(myCols, myMain) {
  pairs(dfS[, myCols],
        lower.panel=panel.smooth, upper.panel=panel.cor,
        diag.panel=panel.hist, main= myMain)
}

## ----function CorrPlot---------------------------------------------------
# create correlation matrix
# from R Graphics Cookbook

CorrPlot <- function(myCols, order, myTitle) {

  d.cor <- dfS[, myCols]
  
  mcor <- cor(d.cor, use = "complete.obs")
  mcor <- round(mcor, digits=2)
  
  # generate a lighter color palette
  col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
  
  # order	parameter options
  # the ordering method of the correlation matrix.
  # "original" for original order (default).
  # "AOE" for the angular order of the eigenvectors.
  # "FPC" for the first principal component order.
  # "hclust" for the hierarchical clustering order.
  # "alphabet" for alphabetical order.
  
  # plot using corrplot package
  corrplot(mcor, 
           method="shade", 
           shade.col=NA, 
           tl.col="black", 
           tl.srt=20,
           col=col(200), 
           addCoef.col="black", 
           addCoefasPercent = TRUE,
           order=order,
           type="lower",
           tl.cex = .90,
           cl.cex = 0.90,
           pch.cex = 0.5,
           title = title(myTitle, line = -1)
           )
} 

## ----function more plots-------------------------------------------------
# barplot
# legend location may  be specified by setting x to a single keyword from the list
# "bottomright", "bottom", "bottomleft", "left", "topleft", "top", "topright", "right"
# and "center". 
myBarplot <- function(myCenters, k, title) {
  barplot(t(myCenters)
          , beside = TRUE
          , xlab="cluster"
          , ylab="value"
          , legend.text = TRUE
          , col = 2:6
          , args.legend = list(x = "bottom")
          , main = title)
}

# CreateDenPlot to create a density plot (smooth histogram), with params
#   myData  : data frame (e.g. metal)
#   xString : string vector of variable name to use for 
#             x axis of density plot (e.g. "Mill.Head.FeCuR..")
#   myFill  : string vector of variable to use for fill (multiple series)
#             (e.g. "CuCluster")
CreateDenPlot <- function(myData, xString, myFill) {
  ggplot(myData, aes_string(x = xString, fill = myFill, colour=myFill)) +
    geom_density(alpha = 0.3) +
    theme_bw() +
    theme(legend.position="bottom") +
    scale_color_jco() +
    scale_fill_jco() +
    theme(axis.title.x = element_blank()) +
    ggtitle(paste0(xString, collapse = NULL))
}


## ----fn viz cluster plots------------------------------------------------
# function CreateBoxPlot is boxplot with following params
#  myData       : data frame
#  xString      : string vector of variable name to use for 
#                 x axis of box plot (e.g. "cluster")
#  yString      : string value  of variable name to use for 
#                 y axis of box plot (e.g. "feature1")
CreateBoxPlot <- function(myData, xString, yString) {  
  ggplot(myData,
         aes_string(x = xString
           , y = yString
           , colour = xString
           , fill = xString)) +
    
  geom_boxplot(notch          = FALSE
               , width        = 0.50
               , outlier.size = 3
               , lwd          = .90
               , fatten       = 0
               , alpha        = 0.3) +
    
  stat_summary(fun.y   = "mean"
               , geom  = "point"
               , shape = 20
               , size  = 4
               , fill  = "white") +
    
  stat_summary(fun.y    = "mean"
               , geom   = "text"
               , vjust  = -1.85
               , hjust  = 0.0
               , colour = "black"
               , aes(label = round(..y.., digits = 3))) + 
    
  # stat_boxplot(geom = "errorbar", lwd = 1, width = 0.5) +
    
  theme_bw() +
  scale_fill_jco() +
  scale_color_jco() +
  theme(legend.position = "right") +
  theme(axis.title.x = element_blank()) +
  theme(axis.title.y = element_blank()) +
  ggtitle(paste0(yString, collapse = NULL))
}

# grid_arrange_shared_legend helper function to create gtable object of
# multiple plots with one legend at the bottom, with parameters
#   ... : ggplot objects (multiple plot objects)
grid_arrange_shared_legend <- function(..., position = c("bottom", "right")) {

  plots <- list(...)
  position <- match.arg(position)
  g <- ggplotGrob(plots[[1]] + theme(legend.position=position))$grobs
  legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
  lheight <- sum(legend$height)
  lwidth <- sum(legend$width)
  gl <- lapply(plots, function(x) x + theme(legend.position="none"))

  combined <- switch(position,
                     "bottom" = arrangeGrob(do.call(arrangeGrob, gl),
                                            legend,
                                            ncol = 1,
                                            heights = unit.c(unit(1, "npc") - lheight, lheight)),
                     "right" = arrangeGrob(do.call(arrangeGrob, gl),
                                           legend,
                                           ncol = 2,
                                           widths = unit.c(unit(1, "npc") - lwidth, lwidth)))

  grid.newpage()
  # grid.draw(combined) # original code, draws the plot (but I want an object)
  arrangeGrob(combined) # this returns a gtable object
}

# CreateDenPlot to create a density plot (smooth histogram), with params
#   myData  : data frame (e.g. metal)
#   xString : string vector of variable name to use for 
#             x axis of density plot (e.g. "feature1")
#   myFill  : string vector of variable to use for fill (multiple series)
#             (e.g. "cluster")
CreateDenPlot <- function(myData, xString, myFill) {
  ggplot(myData, aes_string(x = xString, fill = myFill, colour=myFill)) +
    geom_density(alpha = 0.3) +
    theme_bw() +
    theme(legend.position="bottom") +
    scale_color_jco() +
    scale_fill_jco() +
    theme(axis.title.x = element_blank()) +
    ggtitle(paste0(xString, collapse = NULL))
}

## ----eda MultiPlot-------------------------------------------------------
# MultiPlot is a pairs plot of distribution, 
# scatter, r, and p-values between variables

# MultiPlot function has params
#   myCols : columns to include in correlation matrix
#   myMain : plot title

MultiPlot(c("feature1", "feature2", "feature3", "feature4")
            ,  "MultiPlot from Scaled Data Set")

## ----eda CorrPlot--------------------------------------------------------
# create correlation matrix

# CorrPlot function has params
#   myCOls  :  columns to include in correlation matrix
#   order   :  paramter to control ordering of cols in matrix, in quotes
#   myTitle :  chart title, in quotes

# order	parameter options
# the ordering method of the correlation matrix.
# "original" for original order (default).
# "AOE" for the angular order of the eigenvectors.
# "FPC" for the first principal component order.
# "hclust" for the hierarchical clustering order.
# "alphabet" for alphabetical order.

order <- "original"
# par(mfrow=c(1,1)
#     # mar = c(0,0,2,0)
#     )

# features
dfSFeat <- c("feature1"
             , "feature2"
             , "feature3"
             , "feature4")

myCols <- c(dfSFeat)

# call plotting function
# break up plots b/c of so many variables
myTitle <- "Correlation Matrix"
CorrPlot(myCols
         , order
         , myTitle
         )

## ----clustering fit------------------------------------------------------
set.seed(93)

# set # of clusters
k <- 3

# K means
fitKM <- kmeans(scale(dfS[,1:4]), iter.max = 500, k)
fitKM
summary(fitKM)
table(fitKM$cluster) # num obs by cluster
fitKM$centers # center of cluster

# medoids
# PAM (partitioning around medoids)
fitPAM <- cluster::pam(dfS[,1:4], k)
fitPAM
summary(fitPAM)
table(fitPAM$clustering)
fitPAM$medoids # center of cluster

# FKM w medoids and noise (fuzzy clustering) 
fitPAM.n <- FKM.med.noise(dfS[,1:4]
                          , k = k
                          , m = 1.5
                          , delta = 4
                          , RS = 3)
table(fitPAM.n$clus[,1])

# calc primary and seconday cluster assignment and probability
clusProbs              <- data.frame(round(fitPAM.n$U, 3)) # cluster probabilities
colnames(clusProbs)    <- paste("prob", colnames(clusProbs), sep = "_") # rename columns

clusProbs$primClus     <- fitPAM.n$clus[,1] # primary clster number
clusProbs$primClusProb <- round(fitPAM.n$clus[,2],3) # primary cluster probability

clusProbs$secClus      <- apply(clusProbs # secondary cluster
                                , 1
                                , function(x) which(rank(x, ties.method = "first")==3)) # secondary cluster

clusProbs$secClusProb  <- apply(clusProbs # secondary cluster probability
                                , 1
                                , function(x) x[which(rank(x, ties.method = "first")==3)]) # sec cluster prob

# table of results
dResults         <- dfS # initialize results table with original chem values 
dResults         <- cbind(dResults, clusProbs)    # cluster membership; probability by cluster
dResults$tot     <- rowSums(round(fitPAM.n$U, 3)) # calc sum of probability across clusters
dResults$probOut <- round(1 - dResults$tot, 3)    # prob of being in outlier cluster

# calc principal components
myPrincomp <- prcomp(dfS[1:4])
# myPrincomp$x # matrix of principal component values
# plot prin comp
p1 <- fviz_pca_var(myPrincomp) +
  theme_bw()

p2 <- fviz_pca_ind(myPrincomp) +
  theme_bw()

grid.arrange(p1,p2, ncol = 2)

dResults$prin1 <- round(myPrincomp$x[,1],4)
dResults$prin2 <- round(myPrincomp$x[,2],4)

# identify outliers (probability of being in the outlier cluster > 20%)
myOut <- which(dResults$probOut > 0.20)

# refit without outliers
fitPAM.n2 <- FKM.med.noise(dfS[-myOut,1:4]
                          , k = k
                          , m = 1.5
                          , delta = 3
                          , RS = 1)

fitPAM.n$medoid # which points are medoids
fitPAM.n$H # medoid center
fitPAM.n$clus[1:150,] # which cluster assigned with associated probability
SIL(dfS[,1:4], fitPAM.n$U)
SIL.F(dfS[,1:4], fitPAM.n$U, 1)
plot.fclust(fitPAM.n
            , pca = TRUE
           #, ucex = TRUE # magnify by max membership
            , umin = 0.40) # membership threshhold 
                                    #for assignment to cluster
print.fclust(fitPAM.n)
summary(fitPAM.n)

## ----clustering visualizations-------------------------------------------
# barplot of cluster composition by feature
par(mfrow = c(1, 1), xpd = TRUE)
myBarplot(fitKM$centers,  k, "K means") # K means
myBarplot(fitPAM$medoids, k, "PAM") # PAM
myBarplot(fitPAM.n$H,     k, "PAM w fuzzy clustering") # PAM w fuzzy clustering
myBarplot(fitPAM.n$H,     k, "PAM w fuzzy clustering, outliers removed") # PAM w fuzzy clustering, outliers removed

# matrix of scatter plots by feature, colored by cluster
par(mfrow = c(1, 1))
plot(dfS[,1:4], col = fitKM$cluster, main = "KM") # KM
plot(dfS[,1:4], col = fitPAM$clustering, main = "PAM") # PAM matrix
plot(dfS[,1:4], col = fitPAM.n$clus[,1], main = "PAM w fuzzy clustering") # PAM.n matrix
plot(dfS[-myOut,1:4], col = fitPAM.n2$clus[,1], main = "PAM w fuzzy clustering, outliers removed") # PAM.n2 matrix

par(mfrow = c(2, 2))
plot(dfS[,2:3], col = fitKM$cluster, main = "KM")  # KM Var v Vol
plot(dfS[,2:3], col = fitPAM$clustering, main = "PAM") # PAM Var v Vol
plot(dfS[,2:3], col = fitPAM.n$clus[,1], main = "PAM w fuzzy clustering") # PAM.n Var v Vol
plot(dfS[-myOut,2:3], col = fitPAM.n2$clus[,1], main = "PAM w fuzzy clustering, outliers removed") # PAM.n Var v Vol
par(mfrow = c(1, 1))

# calc principal components
myPrincomp <- prcomp(dfS[,1:4])
myPrincomp$x[1:10,] # matrix of principal component values
p1 <- fviz_pca_var(myPrincomp) +
  theme_bw()

p2 <- fviz_pca_ind(myPrincomp) +
  theme_bw()

grid.arrange(p1,p2, ncol = 2)

# bivariate cluster plot on prin comp scale
par(mfrow = c(1, 1))
clusplot(dfS[,1:4], fitKM$cluster, color=TRUE, shade=TRUE, main = "KM") # KM
clusplot(dfS[,1:4], fitPAM$clustering, color=TRUE, shade=TRUE, main = "PAM") # PAM
clusplot(dfS[,1:4], fitPAM.n$clus[,1], color=TRUE, shade=TRUE, main = "PAM w fuzzy clustering") # PAM.n
clusplot(dfS[-myOut,1:4], fitPAM.n2$clus[,1], color=TRUE, shade=TRUE, main = "PAM w fuzzy clustering, outliers removed") # PAM.n2
par(mfrow = c(1, 1))

# scatter plot of cluster by principal components 1 and 2
# KM
p1 <- fviz_cluster(fitKM, data = myPrincomp$x[,c(1,2)]) +
  theme_bw() + ggtitle("KM")
p1

# PAM
p2 <- fviz_cluster(fitPAM) +
  theme_bw() + ggtitle("PAM")
p2

# PAM.n 
myList <- list(data = dfS[,1:4], cluster = fitPAM.n$clus[,1] )
p3 <- fviz_cluster(myList) +
  theme_bw() + ggtitle("PAM w fuzzy clustering")
p3

# PAM.n2
myList <- list(data = dfS[-myOut,1:4], cluster = fitPAM.n2$clus[,1] )
p4 <- fviz_cluster(myList) +
  theme_bw() + ggtitle("PAM w fuzzy clustering, outliers removed")
p4

grid.arrange(p1, p2, p3, p4, ncol = 2)

# scatter plot of cluster by 2 features at a time
# currenlty only setup with K means
fviz_cluster(fitKM, data = dfS[,c(1,3)]) +
  theme_bw()

fviz_cluster(fitKM, data = dfS[,c(2,3)]) +
  theme_bw()

fviz_cluster(fitKM, data = dfS[,c(1,3)]) +
  theme_bw()

############################################################
# silhouette metric for within and between cluster distances
# KM
silKM = silhouette(fitKM$cluster, dist(dfS[,1:4]))
summary(silKM)
plot(silKM, col=2:(k+1), main = "KM")

# Objects with negative silhouette
neg_sil_index.KM <- which(silKM[, 'sil_width'] < 0)
silKM[neg_sil_index.KM, , drop = FALSE]

# PAM
silPAM <- silhouette(fitPAM)
summary(silPAM)
plot(silPAM, col=2:(k+1), main = "PAM")
# alternate silhouette plot
fviz_silhouette(fitPAM, label = TRUE) +
  theme_bw()
# Objects with negative silhouette
neg_sil_index.PAM <- which(silPAM[, 'sil_width'] < 0)
silPAM[neg_sil_index.PAM, , drop = FALSE]

# PAM.n
silPAM.n = silhouette(fitPAM.n$clus[,1], dist(dfS[,1:4]))
summary(silPAM.n)
plot(silPAM.n, col=2:(k+1), main = "PAM w fuzzy clustering")
# Objects with negative silhouette
neg_sil_index.PAM.n <- which(silPAM.n[, 'sil_width'] < 0)
silPAM.n[neg_sil_index.PAM.n, , drop = FALSE]

# PAM.n2
silPAM.n2 = silhouette(fitPAM.n2$clus[,1], dist(dfS[-myOut,1:4]))
summary(silPAM.n2)
plot(silPAM.n2, col=2:(k+1), main = "PAM w fuzzy clustering, outliers removed")
# Objects with negative silhouette
neg_sil_index.PAM.n2 <- which(silPAM.n2[, 'sil_width'] < 0)
silPAM.n2[neg_sil_index.PAM.n2, , drop = FALSE]

# multiple sihouette plots on page
par(mfrow = c(1, 1))
plot(silKM, col=2:(k+1), main = "KM")
plot(silPAM, col=2:(k+1), main = "PAM")
plot(silPAM.n, col=2:(k+1), main = "PAM w fuzzy clustering")
plot(silPAM.n2, col=2:(k+1), main = "PAM w fuzzy clustering, outliers removed")

###
# density plot
# CreateDenPlot to create a density plot (smooth histogram), with params
#   myData  : data frame (e.g. metal)
#   xString : string vector of variable name to use for 
#             x axis of density plot (e.g. "feature1")
#   myFill  : string vector of variable to use for fill (multiple series)
#             (e.g. "cluster")
myFill  <- "cluster"
denFtr1 <- CreateDenPlot(dfS, "feature1", myFill)
denFtr2 <- CreateDenPlot(dfS, "feature2", myFill)
denFtr3 <- CreateDenPlot(dfS, "feature3", myFill)
denFtr4 <- CreateDenPlot(dfS, "feature4", myFill)

# grid plot of all individual density plots

# intermediate function to create a gtable object with a shared legend
# grid_arrange_shared_legend helper function to create gtable object of
# multiple plots with one legend at the bottom, with parameters
#   ... : ggplot objects (multiple plot objects)
myGtable.den <- grid_arrange_shared_legend(denFtr1
                                           , denFtr2
                                           , denFtr3
                                           , denFtr4)

# create grid plot of density plots
grid.arrange(myGtable.den
             , top = textGrob("Density Plots of Cluster Features"
                              , gp = gpar(fontsize=16)))


## ----export results------------------------------------------------------
# write resuts table
#write.csv(dResults, "Myoutput.csv")

