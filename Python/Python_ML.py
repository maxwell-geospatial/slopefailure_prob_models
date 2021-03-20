#==========================DATA PREP========================================

#Import needed libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import rasterio as rio
import pyspatialml as pml
get_ipython().run_line_magic('matplotlib', 'inline')



#Import specific modules, functions, or methods
from sklearn.ensemble import RandomForestClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.model_selection import GridSearchCV
from sklearn.metrics import confusion_matrix
from sklearn.metrics import classification_report
from sklearn.metrics import roc_curve
from sklearn.metrics import roc_auc_score
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split



#Read in data table
#Will need to set your own directory
lfdata = pd.read_csv('SET YOUR DIRECTORY PATH HERE/lsm_data2.csv')



#Check data table
lfdata.head()



#Split data into training and testing sets
#Set random state for reproducibility
train, test = train_test_split(lfdata, test_size=0.33, random_state=42, shuffle=True, stratify=lfdata["class"])
print(len(train))
print(len(test))
print(train.groupby(['class']).size())
print(test.groupby(['class']).size())



#Separate y and x in both the train and test sets
#Create subsets of predictor variables by type 
train_y = train['class']
train_x = train.drop(columns=['class'])
test_y = test['class']
test_x = test.drop(columns=['class'])



train_x_terrain = train_x.iloc[:,0:32]
test_x_terrain = test_x.iloc[:,0:32]
train_x_lith = train_x.iloc[:,40:]
test_x_lith = test_x.iloc[:,40:]
train_x_dist = train_x.iloc[:,32:40]
test_x_dist = test_x.iloc[:,32:40]
train_x_nterrain = train_x.iloc[:,32:]
test_x_nterrain = test_x.iloc[:,32:]



print(list(train_x))
print(list(train_x_terrain))
print(list(train_x_lith))
print(list(train_x_dist))
print(list(train_x_nterrain))



#Re-scale variables 
#This is required for SVM and k-NN but not RF
scaler = StandardScaler()
scale_fit = scaler.fit(train_x)
train_x2 = pd.DataFrame(scale_fit.transform(train_x))
test_x2 = pd.DataFrame(scale_fit.transform(test_x))
print(train_x.head())
print(train_x2.head())


#=======================TRAIN CLASSIFIERS==================================

#Train classifiers
rf_comp =  RandomForestClassifier(n_estimators=200)
knn_comp = KNeighborsClassifier(n_neighbors=7)
svm_comp =  SVC()



rf_compM = rf_comp.fit(train_x2, train_y)
knn_compM = knn_comp.fit(train_x2, train_y)
svm_compM = rf_comp.fit(train_x2, train_y)

#===========================MAKE PREDICTIONS AND VALIDATE===================================

#Predict the test data
#Generate classification report
pred_rf_comp= rf_compM.predict(test_x2)
pred_knn_comp = knn_compM.predict(test_x2)
pred_svm_comp = svm_compM.predict(test_x2)
print(classification_report(test_y, pred_rf_comp))
print(classification_report(test_y, pred_knn_comp))
print(classification_report(test_y, pred_svm_comp))



#Obtain predicted class probabilities
#Generate ROC curves and AUC metric
test_y2 = test_y.to_numpy()
my_dict = {"not":0, "slopeD":1}
test_y3 = np.asarray([my_dict[zi] for zi in test_y2])

rf_comp_prob = rf_compM.predict_proba(test_x2)
knn_comp_prob = knn_compM.predict_proba(test_x2)
svm_comp_prob = svm_compM.predict_proba(test_x2)

print("RF: " + str(roc_auc_score(test_y3, rf_comp_prob[:,1])))
print("K-NN: " + str(roc_auc_score(test_y3, knn_comp_prob[:,1])))
print("SVM: " + str(roc_auc_score(test_y3, svm_comp_prob[:,1]))) 



#Plot ROC curves
fpr1, tpr1, _ = roc_curve(test_y3,  rf_comp_prob[:, 1])
fpr2, tpr2, _ = roc_curve(test_y3,  knn_comp_prob[:, 1])
fpr3, tpr3, _ = roc_curve(test_y3,  svm_comp_prob[:, 1])
plt.plot(fpr1,tpr1, color ='red', lw=2, label="RF")
plt.plot(fpr2,tpr2, color ='green', lw=2, label="K-NN")
plt.plot(fpr3,tpr3, color ='blue', lw=2, label="SVM")
plt.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--')
plt.xlim([-.05, 1.0])
plt.ylim([-.05, 1.05])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('Compare Algorithms')
plt.legend(loc="lower right")
plt.show()


#=============================COMPARE FEATURE SPACES=============================

#Use random forest to compare different feature spaces
rf1 = RandomForestClassifier(n_estimators=200)
mall = rf1.fit(train_x, train_y)
rf2 = RandomForestClassifier(n_estimators=200)
mterr = rf2.fit(train_x_terrain, train_y)
rf3 = RandomForestClassifier(n_estimators=200)
mlith = rf3.fit(train_x_lith, train_y)
rf4 = RandomForestClassifier(n_estimators=200)
mdist = rf4.fit(train_x_dist, train_y)
rf5 = RandomForestClassifier(n_estimators=200)
mnterr = rf5.fit(train_x_nterrain, train_y)



#Predict to validation data an compare models models
pred_mall = mall.predict(test_x)
print(confusion_matrix(test_y,pred_mall))
print(classification_report(test_y, pred_mall))

pred_terr = mterr.predict(test_x_terrain)
print(confusion_matrix(test_y, pred_terr))
print(classification_report(test_y, pred_terr))

pred_mlith = mlith.predict(test_x_lith)
print(confusion_matrix(test_y,pred_mlith))
print(classification_report(test_y, pred_mlith))

pred_mdist = mdist.predict(test_x_dist)
print(confusion_matrix(test_y,pred_mdist))
print(classification_report(test_y, pred_mdist))

pred_mnterr = mnterr.predict(test_x_nterrain)
print(confusion_matrix(test_y,pred_mnterr))
print(classification_report(test_y, pred_mnterr))



#Predict class probabilities
pred_mall = mall.predict_proba(test_x)
pred_terr = mterr.predict_proba(test_x_terrain)
pred_mlith = mlith.predict_proba(test_x_lith)
pred_mdist = mdist.predict_proba(test_x_dist)
pred_mnterr = mnterr.predict_proba(test_x_nterrain)



#Obtain ROC curves and AUC metric for all models
test_y2 = test_y.to_numpy()
my_dict = {"not":0, "slopeD":1}
test_y3 = np.asarray([my_dict[zi] for zi in test_y2])
print("AUC for All: " + str(roc_auc_score(test_y3, pred_mall[:,1])))

test_y2 = test_y.to_numpy()
my_dict = {"not":0, "slopeD":1}
test_y3 = np.asarray([my_dict[zi] for zi in test_y2])
print("AUC for Just Terrain: " + str(roc_auc_score(test_y3, pred_terr[:,1])))

test_y2 = test_y.to_numpy()
my_dict = {"not":0, "slopeD":1}
test_y3 = np.asarray([my_dict[zi] for zi in test_y2])
roc_auc_score(test_y3, pred_mlith[:,1])
print("AUC for Just Distance: " + str(roc_auc_score(test_y3, pred_mdist[:,1])))

test_y2 = test_y.to_numpy()
my_dict = {"not":0, "slopeD":1}
test_y3 = np.asarray([my_dict[zi] for zi in test_y2])
print("AUC for Just Lithology: " + str(roc_auc_score(test_y3, pred_mlith[:,1])))

test_y2 = test_y.to_numpy()
my_dict = {"not":0, "slopeD":1}
test_y3 = np.asarray([my_dict[zi] for zi in test_y2])
print("AUC for Not Terrain: " + str(roc_auc_score(test_y3, pred_mnterr[:,1])))



#Plot ROC curves
fpr1, tpr1, _ = roc_curve(test_y3,  pred_mall[:, 1])
fpr2, tpr2, _ = roc_curve(test_y3,  pred_terr[:, 1])
fpr3, tpr3, _ = roc_curve(test_y3,  pred_mlith[:, 1])
fpr4, tpr4, _ = roc_curve(test_y3,  pred_mdist[:, 1])
fpr5, tpr5, _ = roc_curve(test_y3,  pred_mnterr[:, 1])
plt.plot(fpr1,tpr1, color ='red', lw=2, label="All Variables")
plt.plot(fpr2,tpr2, color ='green', lw=2, label="Terrain")
plt.plot(fpr3,tpr3, color ='blue', lw=2, label="Lithology")
plt.plot(fpr4,tpr4, color ='orange', lw=2, label="Distance")
plt.plot(fpr5,tpr5, color ='yellow', lw=2, label="Not Terrain")
plt.plot([0, 1], [0, 1], color='navy', lw=2, linestyle='--')
plt.xlim([-.05, 1.0])
plt.ylim([-.05, 1.05])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('Compare Feature Space')
plt.legend(loc="lower right")
plt.show()


#==========================PREDICT TO GRID STACK======================================

#Read in raster grid
#We had best luck with TIF file
#Change band names to match variables
r_preds = pml.Raster("C:/Users/amaxwel6/Downloads/Landslides/Landslides/stack2.tif")
print(r_preds.names)
r_preds.rename({'stack2_1':"slp", 
               'stack2_2':"sp21", 
               'stack2_3':"sp11", 
               'stack2_4': "sp7", 
               'stack2_5':"rph21", 
               'stack2_6':"rph11", 
               'stack2_7':"rph7", 
               'stack2_8':"diss21", 
               'stack2_9':"diss11", 
               'stack2_10':"diss7", 
               'stack2_11':"slpmn21", 
               'stack2_12':"slpmn11", 
               'stack2_13':"slpmn7", 
               'stack2_14':"sei", 
               'stack2_15':"hli", 
               'stack2_16':"asp_lin", 
               'stack2_17':"sar", 
               'stack2_18':"ssr21", 
               'stack2_19':"ssr11", 
               'stack2_20':"ssr7", 
               'stack2_21':"crossc21",
               'stack2_22':"crossc11", 
               'stack2_23':"crossc7", 
               'stack2_24':"planc21", 
               'stack2_25': "planc11", 
               'stack2_26':"planc7", 
               'stack2_27':"proc21", 
               'stack2_28':"proc11", 
               'stack2_29':"proc7", 
               'stack2_30':"longc21", 
               'stack2_31':"longc11", 
               'stack2_32':"longc7", 
               'stack2_33':"us_dist", 
               'stack2_34':"state_dist", 
               'stack2_35':"local_dist", 
               'stack2_36':"strm_dist", 
               'stack2_37':"strm_cost", 
               'stack2_38':"us_cost", 
               'stack2_39':"state_cost", 
               'stack2_40':"local_cost", 
               'stack2_41':"steve",
               'stack2_42':"dspm",
               'stack2_43':"drain"} 
              )
print(r_preds.names)



#Predict class probabilities for each raster cell
result = r_preds.predict_proba(estimator=mall)



#Write result to file
result.write("SET YOUR PATH/slp_pred.tif")



#Read in and plot resulting prediction
#First band is predicted probability for not slope failure, second band is for slope failure
m_result = rio.open("C:/Users/amaxwel6/Downloads/Landslides/Landslides/slp_pred.tif")
m_result_arr = m_result.read(2)
plt.rcParams['figure.figsize'] = [10, 8]
plt.imshow(m_result_arr, cmap="YlOrRd", vmin=0, vmax=1)

