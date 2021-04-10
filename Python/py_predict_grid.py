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
import pickle

#===========================Save and Load Model===================================

#Path to model
pkl_filename = "py_model.pkl"

#Load model
with open(pkl_filename, 'rb') as file:
    pickle_model = pickle.load(file)

#==========================PREDICT TO GRID STACK======================================

#Read in raster grid
#We had best luck with TIF file
#Change band names to match variables
r_preds = pml.Raster("SET YOUR PATH/stack2.tif")
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
result = r_preds.predict_proba(estimator=pickle_model)



#Write result to file
result.write("SET YOUR PATH/slp_pred.tif")



#Read in and plot resulting prediction
#First band is predicted probability for not slope failure, second band is for slope failure
m_result = rio.open("SET YOUR PATH/slp_pred.tif")
m_result_arr = m_result.read(2)
plt.rcParams['figure.figsize'] = [10, 8]
plt.imshow(m_result_arr, cmap="YlOrRd", vmin=0, vmax=1)
