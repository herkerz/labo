#Optimizacion Bayesiana de hiperparametros de  rpart

#limpio la memoria
rm( list=ls() )  #remove all objects
gc()             #garbage collection

require("data.table")
require("rlist")

require("rpart")
require("parallel")

#paquetes necesarios para la Bayesian Optimization
require("DiceKriging")
require("mlrMBO")


#Defino la  Optimizacion Bayesiana

kBO_iter  <- 200   #cantidad de iteraciones de la Optimizacion Bayesiana


ksemillas  <- c(694649, 390101, 483139, 279679, 524743,
                694647, 390103, 483137, 279673, 524747) 

hs  <- makeParamSet(
  makeNumericParam("cp"       , lower= -1   , upper=    -.9),
  makeIntegerParam("minsplit" , lower=  1L  , upper= 1200L),  #la letra L al final significa ENTERO
  makeIntegerParam("minbucket", lower=  1L  , upper= 1L),
  makeIntegerParam("maxdepth" , lower=  75L  , upper=   13L),
  forbidden = quote( minbucket > 0.5*minsplit ) )             # minbuket NO PUEDE ser mayor que la mitad de minsplit


#------------------------------------------------------------------------------


loguear  <- function( reg, arch=NA, folder="./work/", ext=".txt", verbose=TRUE )
{
  archivo  <- arch
  if( is.na(arch) )  archivo  <- paste0( folder, substitute( reg), ext )
  
  if( !file.exists( archivo ) )  #Escribo los titulos
  {
    linea  <- paste0( "fecha\t", 
                      paste( list.names(reg), collapse="\t" ), "\n" )
    
    cat( linea, file=archivo )
  }
  
  linea  <- paste0( format(Sys.time(), "%Y%m%d %H%M%S"),  "\t",     #la fecha y hora
                    gsub( ", ", "\t", toString( reg ) ),  "\n" )
  
  cat( linea, file=archivo, append=TRUE )  #grabo al archivo
  
  if( verbose )  cat( linea )   #imprimo por pantalla
}
#------------------------------------------------------------------------------

particionar  <- function( data, division, agrupa="", campo="fold", start=1, seed=NA )
{
  if( !is.na( seed)  )   set.seed( seed )
  
  bloque  <- unlist( mapply(  function(x,y) { rep( y, x ) }, division, seq( from=start, length.out=length(division) )  ) )
  
  data[ , (campo) :=  sample( rep( bloque, ceiling(.N/length(bloque))) )[1:.N],
        by= agrupa ]
}

#------------------------------------------------------------------------------

EstimarGanancia  <- function( x )
{
  GLOBAL_iteracion  <<-  GLOBAL_iteracion + 1
  
  xval_folds  <- 5

  ganancia <- ArbolesMontecarlo( x)
  
  xx  <- x
  xx$xval_folds  <-  xval_folds
  xx$ganancia  <- ganancia
  xx$iteracion <- GLOBAL_iteracion
  loguear( xx,  arch= archivo_log )
  
  return( ganancia )
}
#------------------------------------------------------------------------------

ArbolEstimarGanancia  <- function( semilla, param_basicos )
{
  particionar( dataset, division=c(7,3), agrupa="clase_ternaria", seed= semilla )  #Cambiar por la primer semilla de cada uno !
  
  modelo  <- rpart("clase_ternaria ~ .",     #quiero predecir clase_ternaria a partir del resto
                   data= dataset[ fold==1],  #fold==1  es training,  el 70% de los datos
                   xval= 0,
                   control= param_basicos )  #aqui van los parametros del arbol
  
  prediccion  <- predict( modelo,   #el modelo que genere recien
                          dataset[ fold==2],  #fold==2  es testing, el 30% de los datos
                          type= "prob") #type= "prob"  es que devuelva la probabilidad
  

  ganancia_test  <- dataset[ fold==2, 
                             sum( ifelse( prediccion[, "BAJA+2"]  >  0.025,
                                          ifelse( clase_ternaria=="BAJA+2", 78000, -2000 ),
                                          0 ) )]
  
  ganancia_test_normalizada  <-  ganancia_test / 0.3
  
  return( ganancia_test_normalizada )
}
#------------------------------------------------------------------------------

ArbolesMontecarlo  <- function(  param_basicos )
{
  ganancias  <- mcmapply( ArbolEstimarGanancia, 
                          ksemillas,   #paso el vector de semillas, que debe ser el primer parametro de la funcion ArbolEstimarGanancia
                          MoreArgs= list( param_basicos),  #aqui paso el segundo parametro
                          SIMPLIFY= FALSE,
                          mc.cores= 1 )  #se puede subir a 5 si posee Linux o Mac OS
  
  ganancia_promedio  <- mean( unlist(ganancias) )
  
  return( ganancia_promedio )
}



setwd("C:\\Users\\hgker\\Desktop\\master_ds\\mineria") 


dataset  <- fread("./datasets/competencia1_2022.csv")   

dir.create( "./exp/",  showWarnings = FALSE ) 
dir.create( "./exp/HT3210/", showWarnings = FALSE )
setwd("./exp/HT3210/")   


archivo_log  <- "HT321.txt"
archivo_BO   <- "HT321.RDATA"

GLOBAL_iteracion  <- 0

if( file.exists(archivo_log) )
{
  tabla_log  <- fread( archivo_log )
  GLOBAL_iteracion  <- nrow( tabla_log )
}


funcion_optimizar  <- EstimarGanancia

configureMlr( show.learner.output= FALSE)

obj.fun  <- makeSingleObjectiveFunction(
  fn=       funcion_optimizar,
  minimize= FALSE,   #estoy Maximizando la ganancia
  noisy=    TRUE,
  par.set=  hs,
  has.simple.signature = FALSE
)

ctrl  <- makeMBOControl( save.on.disk.at.time= 600,  save.file.path= archivo_BO)
ctrl  <- setMBOControlTermination(ctrl, iters= kBO_iter )
ctrl  <- setMBOControlInfill(ctrl, crit= makeMBOInfillCritEI())

surr.km  <- makeLearner("regr.km", predict.type= "se", covtype= "matern3_2", control= list(trace= TRUE))

if( !file.exists( archivo_BO ) ) {
  
  run  <- mbo( fun=     obj.fun, 
               learner= surr.km,
               control= ctrl)
  
} else  run  <- mboContinue( archivo_BO )   
