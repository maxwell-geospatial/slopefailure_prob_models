#Load Packages
library(raster)
library(spatialEco)
library(RSAGA)

#Find SAGA
env <- rsaga.env()

#Read DEM
dem_data <- "D:/terrain_paper/lidar/dem.img"
inDem <- raster(dem_data)

#Define output directory
#Will need to set your own paths
outDir <- "D:/terrain_paper/lidar/r_out"

#Find DEM cell size and save to variable
cellSize <- res(inDem)[1]

#Set processing scales
scale1 = 7
scale2 =11
scale3 = 21

#Calculations from Raster package
slp <- slopeAspect(inDem, out=c('slope'), unit='radians',neighbors=8)
writeRaster(slp, paste0(outDir, "slp.img"))


#Calculations from spatialEco

#Topographic Dissection
diss1 <- dissection(inDem, s=scale1)
diss2 <- dissection(inDem, s=scale2)
diss3 <- dissection(inDem, s=scale3)
writeRaster(diss1, paste0(outdir, "diss1", as.character(scale1), ".img"))
writeRaster(diss2, paste0(outdir, "diss1", as.character(scale2), ".img"))
writeRaster(diss3, paste0(outdir, "diss1", as.character(scale3), ".img"))

#Surface Area Ratio
sar <- sar(inDem, s = NULL)
writeRaster(sar, paste0(outDir, "sar.img"))

#Surface Relief Ratio
srr1 <- srr(inDem, s=scale1)
srr2 <- srr(inDem, s=scale2)
srr3 <- srr(inDem, s=scale3)
writeRaster(srr1, paste0(outdir, "srr", as.character(scale1), ".img"))
writeRaster(srr2, paste0(outdir, "srr", as.character(scale2), ".img"))
writeRaster(srr3, paste0(outdir, "srr", as.character(scale3), ".img"))

#Solar-Radiation Aspect Index     
trasp <- trasp(inDem)
writeRaster(trasp, paste0(outDir, "tasp.img"))

#Heat Load Index
hli <- hli(inDem)
writeRaster(hli, paste0(outDir, "hli.img"))

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


