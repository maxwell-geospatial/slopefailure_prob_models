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

#Read in table and raster stack
set <- read.csv("lsm_data.csv")
stack <- brick("stack.img")

#Clean and prep data 
setb <- set[,c(3, 61:105)]
setb$rktyp <- NULL
setb$unit <- NULL
setc <- filter(setb, class == "not" | class == "slopeD")

setc$class <- as.factor(setc$class)
setc$steve <- as.factor(setc$steve)
setc$dspm <- as.factor(setc$dspm)
setc$drain <- as.factor(setc$drain)

setc[setc == "-9999"] <- NA
setc$steve <- droplevels(setc$steve)
setc$dspm <- droplevels(setc$dspm) 
setc$drain <- droplevels(setc$drain)
setc$class <- droplevels(setc$class)
setd <- drop_na(setc)

#Split data to train and test sets
#Can set random seed for reproducibility
set.seed(42)
test <- setd %>% group_by(class) %>% sample_n(298, replace=FALSE)
remaining <- dplyr::setdiff(setd, test)
set.seed(42)
train <- remaining %>% group_by(class) %>% sample_n(1500, replace=FALSE)

train <- as.data.frame(train)

#Create models using different feature spaces
set.seed(42)
all.model <- randomForest(y= factor(train[,1]), train[,2:ncol(train)], ntree=501, importance=T, confusion=T, err.rate=T)
set.seed(42)
t.model <- randomForest(y= factor(train[,1]), train[,2:33], ntree=501, importance=T, confusion=T, err.rate=T)
set.seed(42)
ls.model <- randomForest(y= factor(train[,1]), train[,42:44], ntree=501, importance=T, confusion=T, err.rate=T)
set.seed(42)
dist.model <- randomForest(y= factor(train[,1]), train[,34:41], ntree=501, importance=T, confusion=T, err.rate=T)
set.seed(42)
nt.model <- randomForest(y= factor(train[,1]), train[,34:44], ntree=501, importance=T, confusion=T, err.rate=T)

#Predict test data and compare models
all_val <- as.data.frame(predict(all.model, test, type="prob", norm.votes=TRUE, predict.all=FALSE, proximity=FALSE, nodes=FALSE))
names(all_val) <- c("not","slope")
all_val$exp <- test$class

t_val <- as.data.frame(predict(t.model, test, type="prob", norm.votes=TRUE, predict.all=FALSE, proximity=FALSE, nodes=FALSE))
names(t_val) <- c("not","slope")
t_val$exp <- test$class

ls_val <- as.data.frame(predict(ls.model, test, type="prob", norm.votes=TRUE, predict.all=FALSE, proximity=FALSE, nodes=FALSE))
names(ls_val) <- c("not","slope")
ls_val$exp <- test$class

rd_val <- as.data.frame(predict(dist.model, test, type="prob", norm.votes=TRUE, predict.all=FALSE, proximity=FALSE, nodes=FALSE))
names(rd_val) <- c("not","slope")
rd_val$exp <- test$class

nt_val <- as.data.frame(predict(nt.model, test, type="prob", norm.votes=TRUE, predict.all=FALSE, proximity=FALSE, nodes=FALSE))
names(nt_val) <- c("not","slope")
nt_val$exp <- test$class

#Calculate ROC/AUC
all_result_df <- data.frame(all_val)
all_roc <- roc(factor(test$class), all_result_df$slope)
auc_all <- auc(all_roc)


#Calculate ROC/AUC
t_result_df <- data.frame(t_val)
t_roc <- roc(factor(test$class), t_result_df$slope)
auc_t <- auc(t_roc)


#Calculate ROC/AUC
nt_result_df <- data.frame(nt_val)
nt_roc <- roc(factor(test$class), nt_result_df$slope)
auc_nt <- auc(nt_roc)


#Calculate ROC/AUC
ls_result_df <- data.frame(ls_val)
ls_roc <- roc(factor(test$class), ls_result_df$slope)
auc_ls <- auc(ls_roc)


#Calculate ROC/AUC
rd_result_df <- data.frame(rd_val)
rd_roc <- roc(factor(test$class), rd_result_df$slope)
auc_rd <- auc(rd_roc)

explst <- c("All", "Terrain", "Lith/Soil", "Dist", "Not Terrain")
auclst <- c(auc_all, auc_t, auc_ls, auc_rd, auc_nt)
aucresults <- data.frame(explst, auclst)
names(aucresults) <- c("Experiment", "AUC")
aucresults

ggroc(list("Soil/Lithology"=ls_roc, "Roads/Streams"=rd_roc, 
           "All Except Terrain"=nt_roc, "Just Terrain"=t_roc, "All Variables"=all_roc), lwd=1.2)+
  geom_abline(intercept = 1, slope = 1, color = "red", linetype = "dashed", lwd=1.2)+
  labs(x="Specificity", y="Sensitivity")+
  scale_color_manual(values= c('#ff7f00','#984ea3','#4daf4a','#3773b8','#e41a1c'))+
  theme_bw()+
  theme(axis.text.y = element_text(size=12))+
  theme(axis.text.x = element_text(size=12))+
  theme(plot.title = element_text(face="bold", size=18))+
  theme(axis.title = element_text(size=14))+
  theme(strip.text = element_text(size = 14))+
  theme(legend.title=element_blank())+
  theme(legend.position= c(.9, .15))

#Predict to raster grid
namelst <- colnames(set)[61:105]
names(stack) <- namelst
predict(stack, all.model, type="prob", index=2, na.rm=TRUE, progress="window", overwrite=TRUE, filename="D:/teaching/rf_out/rf_sf.img")

raster_result <- raster("D:/teaching/rf_out/rf_sf.img")
tm_shape(raster_result)+
  tm_raster(palette="YlOrRd")+
  tm_layout(legend.outside = TRUE)+
  tm_layout(title = "Wetland Probability", title.size = 1.5)


#Split data
#Remove categorical predictor variables (not valid for k-NN and SVM)
Train <- train[1:41]
Val <- test[1:41]

#K-NN
set.seed(42)
trainctrl <- trainControl(method = "cv", number = 5, verboseIter = FALSE)

knn.model <- train(class~., data=Train, method = "knn",
                   tuneLength = 10,
                   preProcess = c("center", "scale"),
                   trControl = trainctrl,
                   metric="Kappa")

knn.predict <-predict(knn.model, Val)
confusionMatrix(knn.predict, Val$class, mode="everything", positive="slopeD")

pred_testknn <- predict(knn.model, Val, index=2, type="prob", norm.votes=TRUE, predict.all=FALSE, proximity=FALSE, nodes=FALSE)
pred_testknn <- data.frame(pred_testknn)
pred_test_rocknn <- roc(Val$class, pred_testknn$slopeD)
auc(pred_test_rocknn)

#Random Forest
set.seed(42)
trainctrlrf <- trainControl(method = "cv", number = 5, verboseIter = FALSE)

rf.model <- train(class~., data=Train, method = "rf", 
                  tuneLength = 10,
                  ntree=500,
                  importance=TRUE,
                  preProcess = c("center", "scale"),
                  trControl = trainctrlrf,
                  metric="Kappa")

rf.predict <-predict(rf.model, Val)
confusionMatrix(rf.predict, Val$class, mode="everything", positive="slopeD")

pred_testrf <- predict(rf.model, Val, index=2, type="prob", norm.votes=TRUE, predict.all=FALSE, proximity=FALSE, nodes=FALSE)
pred_testrf <- data.frame(pred_testrf)
pred_test_rocrf <- roc(Val$class, pred_testrf$slopeD)
auc(pred_test_rocrf)

#SVM
set.seed(42)
trainctrlsvm <- trainControl(method = "cv", number = 5, verboseIter = FALSE, classProbs=TRUE)

svm.model <- train(class~., data=Train, method = "svmRadial",
                   tuneLength = 10,
                   preProcess = c("center", "scale"),
                   trControl = trainctrlsvm,
                   metric="Kappa")

svm.predict <-predict(svm.model, Val)
confusionMatrix(svm.predict, Val$class, mode="everything", positive="slopeD")

pred_testsvm <- predict(svm.model, Val, index=2, type="prob")
pred_testsvm <- data.frame(pred_testsvm)
pred_test_rocsvm <- roc(Val$class, pred_testsvm$slopeD)
auc(pred_test_rocsvm)
ggroc(list("k-NN"=pred_test_rocknn, "RF"=pred_test_rocrf, 
           "SVM"=pred_test_rocsvm), lwd=1.2)+
  geom_abline(intercept = 1, slope = 1, color = "red", linetype = "dashed", lwd=1.2)+
  labs(x="Specificity", y="Sensitivity")+
  scale_color_manual(values= c('#ff7f00','#984ea3','#4daf4a'))+
  theme_bw()+
  theme(axis.text.y = element_text(size=12))+
  theme(axis.text.x = element_text(size=12))+
  theme(plot.title = element_text(face="bold", size=18))+
  theme(axis.title = element_text(size=14))+
  theme(strip.text = element_text(size = 14))+
  theme(legend.title=element_blank())+
  theme(legend.position= c(.9, .15))



