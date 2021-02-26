#Call in packages
library(raster)
library(randomForest)

#Read trained model file
disk_model <- readRDS("D:/v_r_landslide/inputs/v_r_model.rds")

#Read in stack of predictor variables
predgrid <- brick("D:/v_r_landslide/stack/preds.tif")

#Rename bands to match table
r_lst <- c("slp", "sp21", "sp11", "sp7", "rph21", "rph11", "rph7", "diss21", "diss11", "diss7",      
"slpmn21", "slpmn11", "slpmn7", "sei", "hli", "asp_lin", "sar", "ssr21", "ssr11", "ssr7", "crossc21", "crossc11", "crossc7", 
"planc21", "planc11", "planc7", "proc21", "proc11", "proc7", "longc21", "longc11", "longc7", "us_dist", "state_dist", 
"local_dist", "strm_dist", "strm_cost", "us_cost", "state_cost", "local_cost", "rktyp", "steve", "dspm", "drain") 

#Sort names alphabetically
r_lst2 <- sort(r_lst)

#Apply names to raster brick
names(predgrid) <- r_lst2

#Predict on raster brick
predict(predgrid, disk_model, type="prob", index=2, overwrite=TRUE, filename="D:/v_r_landslide/stack/pred_out.tif")