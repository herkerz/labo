# para correr el Google Cloud
#   8 vCPU
#  64 GB memoria RAM
# 256 GB espacio en disco

# son varios archivos, subirlos INTELIGENTEMENTE a Kaggle

#limpio la memoria
rm( list=ls() )  #remove all objects
gc()             #garbage collection

require("data.table")
require("primes")
require("lightgbm")



kdataset       <- "./datasets/dataset_2lags.csv.gz"
ksemilla_azar  <- 225533  #Aqui poner la propia semilla
ktraining      <- c( 202101)   #periodos en donde entreno
kfuture        <- c( 202103 )   #periodo donde aplico el modelo final


kexperimento   <- "hibridacion_test_2lags"

ksemilla_primos  <-  223354
ksemillerio  <- 50

kmax_bin           <-    31
klearning_rate     <-     0.008045173
knum_iterations    <-   1739
knum_leaves        <-   25
kmin_data_in_leaf  <-  round(768/.15)
kfeature_fraction  <-     0.214607455


kmax_bin_2           <-    31
klearning_rate_2     <-     0.006310055
knum_iterations_2    <-   1846
knum_leaves_2        <-   32
kmin_data_in_leaf_2  <-  round(756/.15)
kfeature_fraction_2  <-   0.202134467


kmax_bin_3           <-    31
klearning_rate_3     <-     0.004136601
knum_iterations_3    <-   3248
knum_leaves_3        <-   26
kmin_data_in_leaf_3  <-  round(753/.15)
kfeature_fraction_3  <-    0.20204492

kmax_bin_4           <-    31
klearning_rate_4     <-    0.004560237
knum_iterations_4    <-   1967
knum_leaves_4        <-   30
kmin_data_in_leaf_4  <-  round(641/.15)
kfeature_fraction_4  <-     0.200297769


kmax_bin_5           <-    31
klearning_rate_5     <-     0.004187669
knum_iterations_5    <-   2984
knum_leaves_5        <-   24
kmin_data_in_leaf_5  <-  round(793/.15)
kfeature_fraction_5  <-    0.20321509


kmax_bin_6           <-    31
klearning_rate_6     <-     0.010911834
knum_iterations_6    <-   833
knum_leaves_6        <-   21
kmin_data_in_leaf_6  <-  round(779/.15)
kfeature_fraction_6  <-    0.236638357

kmax_bin_7           <-    31
klearning_rate_7     <-     0.004697998
knum_iterations_7    <-   2464
knum_leaves_7        <-   22
kmin_data_in_leaf_7  <-  round(813/.15)
kfeature_fraction_7  <-     0.388856047


kmax_bin_8           <-    31
klearning_rate_8     <-     0.015560758
knum_iterations_8    <-   391
knum_leaves_8        <-   20
kmin_data_in_leaf_8  <-  round(722/.15)
kfeature_fraction_8  <-    0.391755783


kmax_bin_9           <-    31
klearning_rate_9     <-     0.004228606
knum_iterations_9    <-   2659
knum_leaves_9        <-   33
kmin_data_in_leaf_9  <-  round(774/.15)
kfeature_fraction_9  <-    0.232202495


kmax_bin_10           <-    31
klearning_rate_10     <-     0.009088436
knum_iterations_10    <-   682
knum_leaves_10        <-   19
kmin_data_in_leaf_10  <-  round(678/.15)
kfeature_fraction_10  <-    0.247599126

#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#Aqui empieza el programa

#genero un vector de una cantidad de PARAM$semillerio  de semillas,  buscando numeros primos al azar
primos  <- generate_primes(min=100000, max=1000000)  #genero TODOS los numeros primos entre 100k y 1M
set.seed( ksemilla_primos ) #seteo la semilla que controla al sample de los primos
ksemillas  <- sample(primos)[ 1:ksemillerio ]   #me quedo con PARAM$semillerio primos al azar


setwd( "~/buckets/b1" )

#cargo el dataset donde voy a entrenar
dataset  <- fread(kdataset, stringsAsFactors= TRUE)


#--------------------------------------

#paso la clase a binaria que tome valores {0,1}  enteros
#set trabaja con la clase  POS = { BAJA+1, BAJA+2 } 
#esta estrategia es MUY importante
dataset[ , clase01 := ifelse( clase_ternaria %in%  c("BAJA+2","BAJA+1"), 1L, 0L) ]

#--------------------------------------

#los campos que se van a utilizar
campos_buenos  <- setdiff( colnames(dataset), c("clase_ternaria","clase01") )

#--------------------------------------


#establezco donde entreno
dataset[ , train  := 0L ]
dataset[ foto_mes %in% ktraining, train  := 1L ]

#--------------------------------------
#creo las carpetas donde van los resultados
#creo la carpeta donde va el experimento
# HT  representa  Hiperparameter Tuning
dir.create( "./exp/",  showWarnings = FALSE ) 
dir.create( paste0("./exp/", kexperimento, "/" ), showWarnings = FALSE )
setwd( paste0("./exp/", kexperimento, "/" ) )   #Establezco el Working Directory DEL EXPERIMENTO



#dejo los datos en el formato que necesita LightGBM
dtrain  <- lgb.Dataset( data= data.matrix(  dataset[ train==1L, campos_buenos, with=FALSE]),
                        label= dataset[ train==1L, clase01] )

dapply  <- dataset[ foto_mes== kfuture ]


tb_prediccion_semillerio  <- dapply[  , list(numero_de_cliente) ]
tb_prediccion_semillerio[ , pred_acumulada := 0L ]

for( semilla  in  ksemillas )
{
  #genero el modelo
  #estos hiperparametros  salieron de una laaarga Optmizacion Bayesiana
  modelo  <- lgb.train( data= dtrain,
                        param= list( objective=          "binary",
                                     max_bin=            kmax_bin,
                                     learning_rate=      klearning_rate,
                                     num_iterations=     knum_iterations,
                                     num_leaves=         knum_leaves,
                                     min_data_in_leaf=   kmin_data_in_leaf,
                                     feature_fraction=   kfeature_fraction,
                                     seed=               semilla,
                                     feature_pre_filter= FALSE
                        )
  )
  
  #aplico el modelo a los datos nuevos
  prediccion  <- predict( modelo, 
                          data.matrix( dapply[, campos_buenos, with=FALSE ]) )
  
  #calculo el ranking
  prediccion_semillerio  <- frank( prediccion,  ties.method= "random" )
  
  #acumulo el ranking de la prediccion
  tb_prediccion_semillerio[ , paste0( "pred_", semilla ) :=  prediccion ]
  tb_prediccion_semillerio[ , pred_acumulada := pred_acumulada + prediccion_semillerio ]
  
  
  
  ########---------------------------------------------------------------------------------
  
  modelo_2  <- lgb.train( data= dtrain,
                          param= list( objective=          "binary",
                                       max_bin=            kmax_bin_2,
                                       learning_rate=      klearning_rate_2,
                                       num_iterations=     knum_iterations_2,
                                       num_leaves=         knum_leaves_2,
                                       min_data_in_leaf=   kmin_data_in_leaf_2,
                                       feature_fraction=   kfeature_fraction_2,
                                       seed=               semilla,
                                       feature_pre_filter= FALSE
                          )
  )
  
  #aplico el modelo a los datos nuevos
  prediccion  <- predict( modelo_2, 
                          data.matrix( dapply[, campos_buenos, with=FALSE ]) )
  
  #calculo el ranking
  prediccion_semillerio  <- frank( prediccion,  ties.method= "random" )
  
  #acumulo el ranking de la prediccion
  tb_prediccion_semillerio[ , paste0( "pred_", semilla ) :=  prediccion ]
  tb_prediccion_semillerio[ , pred_acumulada := pred_acumulada + prediccion_semillerio ]
  
  ########--------------------------------------------------------------------------------
  
  
  modelo_3  <- lgb.train( data= dtrain,
                          param= list( objective=          "binary",
                                       max_bin=            kmax_bin_3,
                                       learning_rate=      klearning_rate_3,
                                       num_iterations=     knum_iterations_3,
                                       num_leaves=         knum_leaves_3,
                                       min_data_in_leaf=   kmin_data_in_leaf_3,
                                       feature_fraction=   kfeature_fraction_3,
                                       seed=               semilla,
                                       feature_pre_filter= FALSE
                          )
  )
  
  #aplico el modelo a los datos nuevos
  prediccion  <- predict( modelo_3, 
                          data.matrix( dapply[, campos_buenos, with=FALSE ]) )
  
  #calculo el ranking
  prediccion_semillerio  <- frank( prediccion,  ties.method= "random" )
  
  #acumulo el ranking de la prediccion
  tb_prediccion_semillerio[ , paste0( "pred_", semilla ) :=  prediccion ]
  tb_prediccion_semillerio[ , pred_acumulada := pred_acumulada + prediccion_semillerio ]
  
  ########--------------------------------------------------------------------------------
  
  
  modelo_4  <- lgb.train( data= dtrain,
                          param= list( objective=          "binary",
                                       max_bin=            kmax_bin_4,
                                       learning_rate=      klearning_rate_4,
                                       num_iterations=     knum_iterations_4,
                                       num_leaves=         knum_leaves_4,
                                       min_data_in_leaf=   kmin_data_in_leaf_4,
                                       feature_fraction=   kfeature_fraction_4,
                                       seed=               semilla,
                                       feature_pre_filter= FALSE
                          )
  )
  
  #aplico el modelo a los datos nuevos
  prediccion  <- predict( modelo_4, 
                          data.matrix( dapply[, campos_buenos, with=FALSE ]) )
  
  #calculo el ranking
  prediccion_semillerio  <- frank( prediccion,  ties.method= "random" )
  
  #acumulo el ranking de la prediccion
  tb_prediccion_semillerio[ , paste0( "pred_", semilla ) :=  prediccion ]
  tb_prediccion_semillerio[ , pred_acumulada := pred_acumulada + prediccion_semillerio ]  
  
  ########--------------------------------------------------------------------------------
  
  
  modelo_5  <- lgb.train( data= dtrain,
                          param= list( objective=          "binary",
                                       max_bin=            kmax_bin_5,
                                       learning_rate=      klearning_rate_5,
                                       num_iterations=     knum_iterations_5,
                                       num_leaves=         knum_leaves_5,
                                       min_data_in_leaf=   kmin_data_in_leaf_5,
                                       feature_fraction=   kfeature_fraction_5,
                                       seed=               semilla,
                                       feature_pre_filter= FALSE
                          )
  )
  
  #aplico el modelo a los datos nuevos
  prediccion  <- predict( modelo_5, 
                          data.matrix( dapply[, campos_buenos, with=FALSE ]) )
  
  #calculo el ranking
  prediccion_semillerio  <- frank( prediccion,  ties.method= "random" )
  
  #acumulo el ranking de la prediccion
  tb_prediccion_semillerio[ , paste0( "pred_", semilla ) :=  prediccion ]
  tb_prediccion_semillerio[ , pred_acumulada := pred_acumulada + prediccion_semillerio ]
  
  ########--------------------------------------------------------------------------------
  
  
  modelo_6  <- lgb.train( data= dtrain,
                          param= list( objective=          "binary",
                                       max_bin=            kmax_bin_6,
                                       learning_rate=      klearning_rate_6,
                                       num_iterations=     knum_iterations_6,
                                       num_leaves=         knum_leaves_6,
                                       min_data_in_leaf=   kmin_data_in_leaf_6,
                                       feature_fraction=   kfeature_fraction_6,
                                       seed=               semilla,
                                       feature_pre_filter= FALSE
                          )
  )
  
  #aplico el modelo a los datos nuevos
  prediccion  <- predict( modelo_6, 
                          data.matrix( dapply[, campos_buenos, with=FALSE ]) )
  
  #calculo el ranking
  prediccion_semillerio  <- frank( prediccion,  ties.method= "random" )
  
  #acumulo el ranking de la prediccion
  tb_prediccion_semillerio[ , paste0( "pred_", semilla ) :=  prediccion ]
  tb_prediccion_semillerio[ , pred_acumulada := pred_acumulada + prediccion_semillerio ]
  
  
  ########--------------------------------------------------------------------------------
  
  
  modelo_7  <- lgb.train( data= dtrain,
                          param= list( objective=          "binary",
                                       max_bin=            kmax_bin_7,
                                       learning_rate=      klearning_rate_7,
                                       num_iterations=     knum_iterations_7,
                                       num_leaves=         knum_leaves_7,
                                       min_data_in_leaf=   kmin_data_in_leaf_7,
                                       feature_fraction=   kfeature_fraction_7,
                                       seed=               semilla,
                                       feature_pre_filter= FALSE
                          )
  )
  
  #aplico el modelo a los datos nuevos
  prediccion  <- predict( modelo_7, 
                          data.matrix( dapply[, campos_buenos, with=FALSE ]) )
  
  #calculo el ranking
  prediccion_semillerio  <- frank( prediccion,  ties.method= "random" )
  
  #acumulo el ranking de la prediccion
  tb_prediccion_semillerio[ , paste0( "pred_", semilla ) :=  prediccion ]
  tb_prediccion_semillerio[ , pred_acumulada := pred_acumulada + prediccion_semillerio ]
  
  
  
  ########--------------------------------------------------------------------------------
  
  
  modelo_8  <- lgb.train( data= dtrain,
                          param= list( objective=          "binary",
                                       max_bin=            kmax_bin_8,
                                       learning_rate=      klearning_rate_8,
                                       num_iterations=     knum_iterations_8,
                                       num_leaves=         knum_leaves_8,
                                       min_data_in_leaf=   kmin_data_in_leaf_8,
                                       feature_fraction=   kfeature_fraction_8,
                                       seed=               semilla,
                                       feature_pre_filter= FALSE
                          )
  )
  
  #aplico el modelo a los datos nuevos
  prediccion  <- predict( modelo_8, 
                          data.matrix( dapply[, campos_buenos, with=FALSE ]) )
  
  #calculo el ranking
  prediccion_semillerio  <- frank( prediccion,  ties.method= "random" )
  
  #acumulo el ranking de la prediccion
  tb_prediccion_semillerio[ , paste0( "pred_", semilla ) :=  prediccion ]
  tb_prediccion_semillerio[ , pred_acumulada := pred_acumulada + prediccion_semillerio ]
  
  
  ########--------------------------------------------------------------------------------
  
  
  modelo_9  <- lgb.train( data= dtrain,
                          param= list( objective=          "binary",
                                       max_bin=            kmax_bin_9,
                                       learning_rate=      klearning_rate_9,
                                       num_iterations=     knum_iterations_9,
                                       num_leaves=         knum_leaves_9,
                                       min_data_in_leaf=   kmin_data_in_leaf_9,
                                       feature_fraction=   kfeature_fraction_9,
                                       seed=               semilla,
                                       feature_pre_filter= FALSE
                          )
  )
  
  #aplico el modelo a los datos nuevos
  prediccion  <- predict( modelo_9, 
                          data.matrix( dapply[, campos_buenos, with=FALSE ]) )
  
  #calculo el ranking
  prediccion_semillerio  <- frank( prediccion,  ties.method= "random" )
  
  #acumulo el ranking de la prediccion
  tb_prediccion_semillerio[ , paste0( "pred_", semilla ) :=  prediccion ]
  tb_prediccion_semillerio[ , pred_acumulada := pred_acumulada + prediccion_semillerio ]
  
  
  ########--------------------------------------------------------------------------------
  
  
  modelo_10  <- lgb.train( data= dtrain,
                           param= list( objective=          "binary",
                                        max_bin=            kmax_bin_10,
                                        learning_rate=      klearning_rate_10,
                                        num_iterations=     knum_iterations_10,
                                        num_leaves=         knum_leaves_10,
                                        min_data_in_leaf=   kmin_data_in_leaf_10,
                                        feature_fraction=   kfeature_fraction_10,
                                        seed=               semilla,
                                        feature_pre_filter= FALSE
                           )
  )
  
  #aplico el modelo a los datos nuevos
  prediccion  <- predict( modelo_10, 
                          data.matrix( dapply[, campos_buenos, with=FALSE ]) )
  
  #calculo el ranking
  prediccion_semillerio  <- frank( prediccion,  ties.method= "random" )
  
  #acumulo el ranking de la prediccion
  tb_prediccion_semillerio[ , paste0( "pred_", semilla ) :=  prediccion ]
  tb_prediccion_semillerio[ , pred_acumulada := pred_acumulada + prediccion_semillerio ]
}

#grabo el resultado de cada modelo
fwrite( tb_prediccion_semillerio,
        file= "tb_prediccion_semillerio.txt.gz",
        sep= "\t" )

tb_entrega  <-  dapply[ , list( numero_de_cliente, foto_mes ) ]
tb_entrega[  , prob := tb_prediccion_semillerio$pred_acumulada ]

#grabo las probabilidad del modelo
fwrite( tb_entrega,
        file= "prediccion.txt",
        sep= "\t" )

#ordeno por probabilidad descendente
setorder( tb_entrega, -prob )


#genero archivos con los  "envios" mejores
#deben subirse "inteligentemente" a Kaggle para no malgastar submits
cortes <- seq( 8000, 10000, by=500 )
for( envios  in  cortes )
{
  tb_entrega[  , Predicted := 0L ]
  tb_entrega[ 1:envios, Predicted := 1L ]
  
  fwrite( tb_entrega[ , list(numero_de_cliente, Predicted)], 
          file= paste0(  kexperimento, "_", envios, ".csv" ),
          sep= "," )
}
