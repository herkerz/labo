test_v2_bayesiana_under: se entreno con 4 meses 202011,202010,202009,202008 para testear en 202101
tiene un undersampling del 0.15
se utilizo el dataset historico ajustado por ipc sin FE


test_v2_bayesiana_sin_under: se entreno con 4 meses 202011,202010,202009,202008 para testear en 202101
NO tiene undersampling
se utilizo el dataset historico ajustado por ipc sin FE

test_enero: este script utiliza enero para chequear las ganancias de los modelos y asi comparar.
la idea es comparar los mejore modelos de las bayesianas en enero y asi validar el undersampling
