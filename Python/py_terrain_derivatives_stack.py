#Import libraries

import os
import sys
import arcpy
from arcpy import env
from arcpy.sa import *
arcpy.CheckOutExtension("Spatial")



#Define function to get mid-latitude value for HLI calculation

#This is from: https://evansmurphy.wixsite.com/evansspatial/arcgis-gradient-metrics-toolbox 
def getMidLat (rExt):
    spRefType = rExt.spatialReference.type
    if spRefType == "Geographic":
        rYMax = rExt.YMax
        rYMin = rExt.YMin
        medianLat = abs((float(rYMax)- float(rYMin))/2+rYMin)
    else:
        wgs84 = arcpy.SpatialReference(4326)
        prjExt = rExt.projectAs(wgs84)
        rYMax = prjExt.YMax
        rYMin = prjExt.YMin
        medianLat = abs((float(rYMax)- float(rYMin))/2+rYMin)
    return medianLat

def returnCurrentSRefOfMap():
    mxd = arcpy.mapping.MapDocument("CURRENT")
    sRef = mxd.activeDataFrame.spatialReference
    return sRef

def isArcMap():
	try:
		mxd = arcpy.mapping.MapDocument("CURRENT")
		return True
	except:
		return False

def checkExt(inDem):
    #arcpy.AddWarning("here = "+env.extent)
    if (env.extent):
        outRaster = Times(inDem,1)
        return outRaster
    else:
        outRaster = inDem
        if isArcMap():
            mapSRef = returnCurrentSRefOfMap()
            desc = arcpy.Describe(inDem)
            if mapSRef.name != desc.spatialReference.name:
                env.outputCoordinateSystem = mapSRef
                outRaster = Times(inDem,1)
        return outRaster



#Define directory holding DEM data
#Will need to set you own paths here

inDir = "Set In Directory"
#Define directory to store outputs in
outDir = "SET OUT DIRECTORY"
#Define input DEM
dem = "DEFINE DEM INPUT"
#Snap all output to DEM
env.snapRaster = dem
#Allow file overwrite
env.overwriteOutput = True
#Do not create pyramids to save time
arcpy.env.pyramids = "NONE"
#Do not calculate raster stats to save time
arcpy.env.rasterStatistics = "NONE"
#Do not apply compression to rasters
arcpy.env.compression = "NONE"
#set workspace to output directory
arcpy.env.workspace = outDir
#set scratch workspace
arcpy.env.scratchWorkspace = "SET SCRATCH DIRECTORY"



#Calculate Terrain Derivatives

#Define input DEM
demIn = dem
scale1 = 7
scale2 = 11
scale3 = 21

#Create and save slope grid using Spatial Analyst Extension
slp = Slope(demIn, "DEGREE")

#Calculate Slope Position
mnEle1 = FocalStatistics(demIn, NbrCircle(scale1, "CELL"),"MEAN")
sp1 = demIn - mnEle1
mnEle2 = FocalStatistics(demIn, NbrCircle(scale2, "CELL"),"MEAN")
sp2 = demIn - mnEle2
mnEle3 = FocalStatistics(demIn, NbrCircle(scale3, "CELL"),"MEAN")
sp3 = demIn - mnEle3

#Calculate Terrain Roughness
stdEle1 = FocalStatistics(demIn, NbrCircle(scale1, "CELL"),"STD")
rph1a = Con(IsNull(stdEle1), 0, stdEle1)
rph1 = Square(rph1a)
stdEle2 = FocalStatistics(demIn, NbrCircle(scale2, "CELL"),"STD")
rph2a = Con(IsNull(stdEle2), 0, stdEle2)
rph2 = Square(rph2a)
stdEle3 = FocalStatistics(demIn, NbrCircle(scale3, "CELL"),"STD")
rph3a = Con(IsNull(stdEle3), 0, stdEle3)
rph3 = Square(rph3a)

#Calculate Topographic Dissection
maxEle1 = FocalStatistics(demIn, NbrCircle(scale1, "CELL"),"MAXIMUM")
minEle1 = FocalStatistics(demIn, NbrCircle(scale1, "CELL"),"MINIMUM")
rngEle1 = Float(maxEle1 - minEle1)
diss_pre1 = Float(demIn - minEle1) / rngEle1
diss1 = Con(rngEle1==0,0,diss_pre1)
maxEle2 = FocalStatistics(demIn, NbrCircle(scale2, "CELL"),"MAXIMUM")
minEle2 = FocalStatistics(demIn, NbrCircle(scale2, "CELL"),"MINIMUM")
rngEle2 = Float(maxEle2 - minEle2)
diss_pre2 = Float(demIn - minEle2) / rngEle2
diss2 = Con(rngEle2==0,0,diss_pre2)
maxEle3 = FocalStatistics(demIn, NbrCircle(scale3, "CELL"),"MAXIMUM")
minEle3 = FocalStatistics(demIn, NbrCircle(scale3, "CELL"),"MINIMUM")
rngEle3 = Float(maxEle3 - minEle3)
diss_pre3 = Float(demIn - minEle3) / rngEle3
diss3 = Con(rngEle3==0,0,diss_pre3)

#Calculate Mean Slope
slpmn1 = FocalStatistics(slp,NbrCircle(scale1, "CELL"),"MEAN")
slpmn2 = FocalStatistics(slp,NbrCircle(scale2, "CELL"),"MEAN")
slpmn3 = FocalStatistics(slp,NbrCircle(scale3, "CELL"),"MEAN")

#Calculate Site Exposure Index
aspect = Aspect(demIn)
cosAsp = Cos(Divide(Times(3.142,Minus(aspect,180)),180))
sei = Times(slp,cosAsp)

#Calculate Heat Load Index
dscRaster = arcpy.Describe(demIn)
ext = dscRaster.extent
midLat = getMidLat(ext)
l = float(midLat) * 0.017453293
cl = math.cos(float(l))
sl = math.sin(l)
tmp1 = slp * 0.017453293               
tmp2 = aspect * 0.017453293              
tmp3 = Abs(3.141593 - Abs(tmp2 - 3.926991))     
tmp4 = Cos(tmp1)
tmp5 = Sin(tmp1)
tmp6 = Cos(tmp3)
tmp7 = Sin(tmp3)
hli = Exp( -1.467 +  1.582 * cl * tmp4  - 1.5 * tmp6 * tmp5 * sl - 0.262 * sl * tmp5  + 0.607 * tmp7 * tmp5)

#Calculate Linear Aspect
tmp2=SetNull(aspect<0,(450.0-aspect)/57.296)
tmp3=Sin(tmp2)
tmp4=Cos(tmp2)
tmp5=FocalStatistics(tmp3,NbrRectangle(3,3,"CELL"),"SUM","DATA")
tmp6=FocalStatistics(tmp4,NbrRectangle(3,3,"CELL"),"SUM","DATA")
#The *100 and 36000(360*100) / 100 allow for two decimal points since Fmod appears to be gone
tmpMod = Mod(((450-(ATan2(tmp5,tmp6)*57.296))*100),36000)/100
asp_lin = Con((tmp5==0) & (tmp6==0),-1, tmpMod)

# Calculate Surface Relief Ratio
conTmp1 = Float(maxEle1 - minEle1)
outVal1 = Float(mnEle1 - minEle1) / conTmp1
srr1 = Con(conTmp1==0,0,outVal1)
conTmp2 = Float(maxEle2 - minEle2)
outVal2 = Float(mnEle2 - minEle2) / conTmp2
srr2 = Con(conTmp2==0,0,outVal2)
conTmp3 = Float(maxEle3 - minEle3)
outVal3 = Float(mnEle3 - minEle3) / conTmp3
srr3 = Con(conTmp3==0,0,outVal3)

#Calculate Surface Area Ratio
r = checkExt(demIn)
dscRaster = arcpy.Describe(r)
cellSize = dscRaster.meanCellHeight
c = cellSize * cellSize
v = math.pi/180
tmp1 = Slope(r,"DEGREE") * v
sar =  Float(c) / Cos(tmp1)

#Calculate Surface Curvatures
neighDist1 = str(scale1/cellSize) + " METERS"
neighDist2 = str(scale2/cellSize) + " METERS"
neighDist3 = str(scale3/cellSize) + " METERS"
mnCrv1 = SurfaceParameters(demIn, "MEAN_CURVATURE", "BIQUADRATIC", neighDist1,
                                         "FIXED_NEIGHBORHOOD", "METER")
mnCrv2 = SurfaceParameters(demIn, "MEAN_CURVATURE", "BIQUADRATIC", neighDist2,
                                         "FIXED_NEIGHBORHOOD", "METER")
mnCrv3 = SurfaceParameters(demIn, "MEAN_CURVATURE", "BIQUADRATIC", neighDist3,
                                         "FIXED_NEIGHBORHOOD", "METER")
proCrv1 = SurfaceParameters(demIn, "PROFILE_CURVATURE", "BIQUADRATIC", neighDist1,
                                         "FIXED_NEIGHBORHOOD", "METER")
proCrv2 = SurfaceParameters(demIn, "PROFILE_CURVATURE", "BIQUADRATIC", neighDist2,
                                         "FIXED_NEIGHBORHOOD", "METER")
proCrv3 = SurfaceParameters(demIn, "PROFILE_CURVATURE", "BIQUADRATIC", neighDist3,
                                         "FIXED_NEIGHBORHOOD", "METER")
tanCrv1 = SurfaceParameters(demIn, "TANGENTIAL_CURVATURE", "BIQUADRATIC", neighDist1,
                                         "FIXED_NEIGHBORHOOD", "METER")
tanCrv2 = SurfaceParameters(demIn, "TANGENTIAL_CURVATURE", "BIQUADRATIC", neighDist2,
                                         "FIXED_NEIGHBORHOOD", "METER")
tanCrv3 = SurfaceParameters(demIn, "TANGENTIAL_CURVATURE", "BIQUADRATIC", neighDist3,
                                         "FIXED_NEIGHBORHOOD", "METER")

#Save as grid stack

rlist = [slp, sp1, sp2, sp3, rph1, rph2, rph3, diss1, diss2, diss3, slpmn1, slpmn2, slpmn3,
         sei, hli, asp_lin, srr1, srr2, srr3, sar, mnCrv1, mnCrv2, mnCrv3, proCrv1, proCrv2, 
         proCrv3, tanCrv1, tanCrv2,tanCrv3]
arcpy.CompositeBands_management(rlist, outDir + "OUTPUT RASTER NAME")

