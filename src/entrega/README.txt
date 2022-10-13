Para replicar los resultados se debe correr los scripts de la siguiente manera:

1- dataset_fe_2lags.R con este script se crea el dataset
2- bayesiana_ultimo_mes_2lags.R es la primer bayesiana para sacar los hiperparametros
3- bayesiana_final.R dado que los hiperparametros dieron muy cerca del limite de learning rate y feature fraction 
se corre esta bayesiana
4- hibridacion_final.R la entrega final se hace una hibridacion de semilleros de los tres mejores modelos de la bayesiana 
anterior, el corte para la entrega fue 10k