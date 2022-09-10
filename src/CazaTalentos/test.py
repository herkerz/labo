import numpy as np
from statsmodels.sandbox.stats.runs import runstest_1samp 
import random
import matplotlib.pyplot as plt

def f_tirar(prob, qty):
    tiros = np.random.rand(qty)
    aciertos = sum(tiros < prob)
    
    runs_start = np.nonzero(np.diff(np.r_[[-np.inf], tiros < prob , [np.inf]]))[0]
    runs = len(runs_start)

    return  aciertos, runs


mejor = 0.7
peloton = np.arange(0.5,0.6,0.001)
jugadores = np.append(mejor, peloton)


vec_ftirar = np.vectorize(f_tirar)


aciertos = vec_ftirar(jugadores, 100)

ganadores_totales = []
tiros_totales = []

for i in range(100):

  cantidad_tiros = []
  #---------- primer trial
  tiros_1 = 50
  distribucion_teorica = np.random.binomial(tiros_1, mejor,size=10000)
  limite = np.quantile(distribucion_teorica,0.005)

  cantidad_tiros.append(len(jugadores) * tiros_1)
  aciertos, runs = vec_ftirar(jugadores, tiros_1)
  mask = (aciertos > limite)

  remanentes = jugadores[mask]
  aciertos = aciertos[mask]
  runs = runs[mask]
  total_runs = remanentes + runs
  total_aciertos = remanentes + aciertos


  #--------- segundo trial
  tiros_2 = 100
  distribucion_teorica = np.random.binomial(tiros_2, mejor,size=10000)
  limite = np.quantile(distribucion_teorica,0.01)

  cantidad_tiros.append(len(remanentes) * tiros_2)
  aciertos_2, runs_2 = vec_ftirar(remanentes, tiros_2)
  mask_2 = (aciertos_2 > limite)

  remanentes_2 = remanentes[mask_2]
  aciertos_2 = aciertos_2[mask_2]
  runs_2 = runs_2[mask_2]
  total_runs = total_runs[mask_2] + runs_2
  total_aciertos = total_aciertos[mask_2] + aciertos_2

  #--------- tercer trial
  tiros_3 = 200
  distribucion_teorica = np.random.binomial(tiros_3, mejor,size=10000)
  limite = np.quantile(distribucion_teorica,0.01)

  cantidad_tiros.append(len(remanentes_2) * tiros_3)
  aciertos_3, runs_3 = vec_ftirar(remanentes_2, tiros_3)
  mask_3 = (aciertos_3 > limite)

  remanentes_3 = remanentes_2[mask_3]
  aciertos_3 = aciertos_3[mask_3]
  runs_3 = runs_3[mask_3]
  total_runs = total_runs[mask_3] + runs_3
  total_aciertos = total_aciertos[mask_3] + aciertos_3
  
  ratio = np.floor(total_aciertos) / np.floor(total_runs)
#   ganador_idx = np.argmax(ratio)
  ganador_idx = np.argmax(np.floor(total_aciertos))
  ganador = remanentes_3[ganador_idx]

  ganadores_totales.append(ganador)
  tiros_totales.append(sum(cantidad_tiros))

print(np.unique(ganadores_totales,return_counts = True))
print("################")
print(sum(np.array(tiros_totales) > 15000))