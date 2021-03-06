#Load Packages
library(raster)
library(spatialEco)
library(RSAGA)
library(sf)
library(dplyr)

#Find SAGA
env <- rsaga.env()

#Read DEM
dem <- "YOUR TO YOUR DEM DATA"
demData <- raster(dem)

#Read in tiles
tiles <- st_read("PATH TO YOUR PROCESSING TILES")

#Load a saved model
my_model <- readRDS("YOUR SAVED MODEL")

#Define output directory
#Will need to set your own paths
outDir <- "OUTPUT DIRECTORY FOR RASTERS"
pntPreds = "OUTPUT DIRECTORY FOR FINAL RASTER PREDICTIONS"

#Find DEM cell size and save to variable
cellSize <- res(demData)[1]

buffDist = 100

#Set processing scales
scale1 = 7
scale2 =11
scale3 = 21

for(tNum in 1:nrow(tiles)){
  tileIn <- tiles %>% filter(TileNum == tNum)
  
  tileB <- st_buffer(tileIn, 100)
  
  inDem <- crop(demData, tileB)
  
  #Calculations from Raster package
  slp <- slopeAspect(inDem, out=c('slope'), unit='radians',neighbors=8)
  
  
  #Calculations from spatialEco
  
  #Topographic Dissection
  diss1 <- dissection(inDem, s=scale1)
  diss2 <- dissection(inDem, s=scale2)
  diss3 <- dissection(inDem, s=scale3)
  
  #Surface Area Ratio
  sar <- sar(inDem, s = NULL)
  
  #Surface Relief Ratio
  srr1 <- srr(inDem, s=scale1)
  srr2 <- srr(inDem, s=scale2)
  srr3 <- srr(inDem, s=scale3)
  
  #Solar-Radiation Aspect Index     
  trasp <- trasp(inDem)
  
  #Heat Load Index
  hli <- hli(inDem)
  
  #Calculations using SAGA
  
  #Save DEM to SAGA Format
  raster::writeRaster(inDem, paste0(outDir, "saga_dem.sgrd"),overwrite = TRUE, NAflag = 0)
  
  # Morphometric Features
  RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 23,
                            param = list(DEM = paste0(outDir,"saga_dem.sgrd"), 
                                         FEATURES = paste0(outDir,"SAGA_feat", as.character(scale1), ".sgrd"),
                                         ELEVATION = paste0(outDir,"SAGA_gen", as.character(scale1), ".sgrd"),
                                         SLOPE = paste0(outDir,"SAGA_slp", as.character(scale1), ".sgrd"),
                                         ASPECT = paste0(outDir,"SAGA_asp", as.character(scale1), ".sgrd"),
                                         PROFC = paste0(outDir,"SAGA_pro", as.character(scale1), ".sgrd"),
                                         PLANC = paste0(outDir,"SAGA_plan", as.character(scale1), ".sgrd"),
                                         LONGC = paste0(outDir,"SAGA_long", as.character(scale1), ".sgrd"),
                                         CROSC = paste0(outDir,"SAGA_cross", as.character(scale1), ".sgrd"),
                                         MAXIC = paste0(outDir,"SAGA_maxc", as.character(scale1), ".sgrd"),
                                         MINIC = paste0(outDir,"SAGA_minc", as.character(scale1), ".sgrd"),
                                         SIZE= scale1),
                            show.output.on.console = TRUE, invisible = TRUE,
                            env = env)
  
  RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 23,
                            param = list(DEM = paste0(outDir,"saga_dem.sgrd"), 
                                         FEATURES = paste0(outDir,"SAGA_feat", as.character(scale2), ".sgrd"),
                                         ELEVATION = paste0(outDir,"SAGA_gen", as.character(scale2), ".sgrd"),
                                         SLOPE = paste0(outDir,"SAGA_slp", as.character(scale2), ".sgrd"),
                                         ASPECT = paste0(outDir,"SAGA_asp", as.character(scale2), ".sgrd"),
                                         PROFC = paste0(outDir,"SAGA_pro", as.character(scale2), ".sgrd"),
                                         PLANC = paste0(outDir,"SAGA_plan", as.character(scale2), ".sgrd"),
                                         LONGC = paste0(outDir,"SAGA_long", as.character(scale2), ".sgrd"),
                                         CROSC = paste0(outDir,"SAGA_cross", as.character(scale2), ".sgrd"),
                                         MAXIC = paste0(outDir,"SAGA_maxc", as.character(scale2), ".sgrd"),
                                         MINIC = paste0(outDir,"SAGA_minc", as.character(scale2), ".sgrd"),
                                         SIZE= scale2),
                            show.output.on.console = TRUE, invisible = TRUE,
                            env = env)
  
  RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 23,
                            param = list(DEM = paste0(outDir,"saga_dem.sgrd"), 
                                         FEATURES = paste0(outDir,"SAGA_feat", as.character(scale3), ".sgrd"),
                                         ELEVATION = paste0(outDir,"SAGA_gen", as.character(scale3), ".sgrd"),
                                         SLOPE = paste0(outDir,"SAGA_slp", as.character(scale3), ".sgrd"),
                                         ASPECT = paste0(outDir,"SAGA_asp", as.character(scale3), ".sgrd"),
                                         PROFC = paste0(outDir,"SAGA_pro", as.character(scale3), ".sgrd"),
                                         PLANC = paste0(outDir,"SAGA_plan", as.character(scale3), ".sgrd"),
                                         LONGC = paste0(outDir,"SAGA_long", as.character(scale3), ".sgrd"),
                                         CROSC = paste0(outDir,"SAGA_cross", as.character(scale3), ".sgrd"),
                                         MAXIC = paste0(outDir,"SAGA_maxc", as.character(scale3), ".sgrd"),
                                         MINIC = paste0(outDir,"SAGA_minc", as.character(scale3), ".sgrd"),
                                         SIZE= scale3),
                            show.output.on.console = TRUE, invisible = TRUE,
                            env = env)
  
  #Topographic Roughness Index
  RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 16,
                            param = list(DEM = paste0(outDir,"saga_dem.sgrd"), 
                                         TRI = paste0(outDir, "saga_tri", as.character(scale1), ".sgrd"),
                                         RADIUS = scale1),
                            show.output.on.console = TRUE, invisible = TRUE,
                            env = env)
  
  
  RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 16,
                            param = list(DEM = paste0(outDir,"saga_dem.sgrd"), 
                                         TRI = paste0(outDir, "saga_tri", as.character(scale2), ".sgrd"),
                                         RADIUS = scale2),
                            show.output.on.console = TRUE, invisible = TRUE,
                            env = env)
  
  RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 16,
                            param = list(DEM = paste0(outDir,"saga_dem.sgrd"), 
                                         TRI = paste0(outDir, "saga_tri", as.character(scale3), ".sgrd"),
                                         RADIUS = scale3),
                            show.output.on.console = TRUE, invisible = TRUE,
                            env = env)
  #Topographic Position Index
  RSAGA::rsaga.geoprocessor(lib = "ta_morphometry", module = 18,
                            param = list(DEM = paste0(outDir,"saga_dem.sgrd"), 
                                         TPI = paste0(outDir,"saga_tpi.sgrd"),
                                         STANDARD = TRUE,
                                         RADIUS_MIN = scale1,
                                         RADIUS_MAX = scale3),
                            show.output.on.console = TRUE, invisible = TRUE,
                            env = env)
  
  
  saga_slp1 <- raster(paste0(outDir,"SAGA_slp", as.character(scale1), ".sdat"))
  saga_slp2 <- raster(paste0(outDir,"SAGA_slp", as.character(scale2), ".sdat"))
  saga_slp3 <- raster(paste0(outDir,"SAGA_slp", as.character(scale3), ".sdat"))
  
  saga_tri1 <- raster(paste0(outDir,"saga_tri", as.character(scale1), ".sdat"))
  saga_tri2 <- raster(paste0(outDir,"saga_tri", as.character(scale1), ".sdat"))
  saga_tri3 <- raster(paste0(outDir,"saga_tri", as.character(scale1), ".sdat"))
  
  saga_tpi <- raster(paste0(outDir,"saga_tpi.sdat"))
  
  saga_proCrv1 <- raster(paste0(outDir,"SAGA_tri", as.character(scale1), ".sdat"))
  saga_proCrv2 <- raster(paste0(outDir,"SAGA_tri", as.character(scale2), ".sdat"))
  saga_proCrv3 <- raster(paste0(outDir,"SAGA_tri", as.character(scale3), ".sdat"))
  
  saga_plnCrv1 <- raster(paste0(outDir,"SAGA_plan", as.character(scale1), ".sdat"))
  saga_plnCrv2 <- raster(paste0(outDir,"SAGA_plan", as.character(scale2), ".sdat"))
  saga_plnCrv3 <- raster(paste0(outDir,"SAGA_plan", as.character(scale3), ".sdat"))
  
  saga_lngCrv1 <- raster(paste0(outDir,"SAGA_long", as.character(scale1), ".sdat"))
  saga_lngCrv2 <- raster(paste0(outDir,"SAGA_long", as.character(scale2), ".sdat"))
  saga_lngCrv3 <- raster(paste0(outDir,"SAGA_long", as.character(scale3), ".sdat"))
  
  saga_csCrv1 <- raster(paste0(outDir,"SAGA_cross", as.character(scale1), ".sdat"))
  saga_csCrv2 <- raster(paste0(outDir,"SAGA_cross", as.character(scale2), ".sdat"))
  saga_csCrv3 <- raster(paste0(outDir,"SAGA_cross", as.character(scale3), ".sdat"))
  
  #Fix CRS
  crs(saga_slp1) <- crs(inDem)
  crs(saga_slp2) <- crs(inDem)
  crs(saga_slp3) <- crs(inDem)
  
  crs(saga_tri1) <- crs(inDem)
  crs(saga_tri2) <- crs(inDem) 
  crs(saga_tri3) <- crs(inDem) 
  
  crs(saga_tpi) <- crs(inDem)
  
  crs(saga_proCrv1) <- crs(inDem) 
  crs(saga_proCrv2) <- crs(inDem) 
  crs(saga_proCrv3) <- crs(inDem)  
  
  crs(saga_plnCrv1) <- crs(inDem) 
  crs(saga_plnCrv2) <- crs(inDem) 
  crs(saga_plnCrv3) <- crs(inDem) 
  
  crs(saga_lngCrv1) <- crs(inDem) 
  crs(saga_lngCrv2) <- crs(inDem) 
  crs(saga_lngCrv3) <- crs(inDem) 
  
  crs(saga_csCrv1) <- crs(inDem) 
  crs(saga_csCrv2) <- crs(inDem) 
  crs(saga_csCrv3) <- crs(inDem) 
  
  #Write output to grid stack
  topo_stack <- stack(c(slp,diss1,diss2,diss3,sar,srr1,
                        srr2,srr3, trasp,hli,saga_slp1,saga_slp2,saga_slp3,
                        saga_tri1,saga_tri2,saga_tri3,saga_tpi,saga_proCrv1,saga_proCrv2, 
                        saga_proCrv3,saga_plnCrv1,saga_plnCrv2,saga_plnCrv3,saga_lngCrv1,
                        saga_lngCrv2,saga_lngCrv3,saga_csCrv1,saga_csCrv2,saga_csCrv3))
  
  #It is not necessary to save the stack to disk to make the prediction
  #writeRaster(topo_stack, paste0(outDir, "NAME RASTER OUTPUT"), overwrite=TRUE)
  
  names(topo_stack) <- c("slp","diss1","diss2","diss3","sar","srr1",
                      "srr2","srr3", "trasp","hli","saga_slp1","saga_slp2","saga_slp3",
                      "saga_tri1","saga_tri2","saga_tri3","saga_tpi","saga_proCrv1","saga_proCrv2", 
                      "saga_proCrv3","saga_plnCrv1","saga_plnCrv2","saga_plnCrv3","saga_lngCrv1",
                      "saga_lngCrv2","saga_lngCrv3","saga_csCrv1","saga_csCrv2","saga_csCrv3")
  
  #Predict to raster grid
  predict(topo_tack, my_model, type="prob", index=2, na.rm=TRUE, 
          progress="window", overwrite=TRUE, 
          filename=paste0("pred_", as.character(tNum), ".tif"))

}