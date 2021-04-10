#Set Working Directory
setwd("SET YOUR OWN WORKING DIRECTORY")

#Read in needed libraries
require(randomForest)
require(pROC)
require(raster)
require(rgdal)
require(tmap)
require(ggplot2)
require(caret)
library(tidyr)
require(dplyr)

#Read in aster stack
#Can download data from http://www.wvview.org/research.html
set <- read.csv("lsm_data2.csv")
stack <- brick("stack2.img")

#Load a saved model
my_model <- readRDS("YOUR SAVED MODEL")

#Predict to raster grid
namelst <- colnames(set)[2:ncol(train)]
names(stack) <- namelst
predict(stack, all.model, type="prob", index=2, na.rm=TRUE, 
        progress="window", overwrite=TRUE, 
        filename="NAME OF RASER OUTPUT")

#Read in and visualize prediction
raster_result <- raster("NAME OF RASTER OUTPUT")
tm_shape(raster_result)+
  tm_raster(palette="YlOrRd")+
  tm_layout(legend.outside = TRUE)+
  tm_layout(title = "Slope Failure Probability", title.size = 1.5)