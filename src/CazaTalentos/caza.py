import numpy as np
from statsmodels.sandbox.stats.runs import runstest_1samp 
import random
import matplotlib.pyplot as plt

def ftirar(prob, qty):
  return sum(np.random.rand(qty) < prob)


mejor = 0.7
peloton = np.arange(0.5,0.6,0.001)
jugadores = np.append(mejor, peloton)


vec_ftirar = np.vectorize(ftirar)


ganadores_totales = []
tiros_totales = []

for i in range(100):

  cantidad_tiros = []
  #---------- primer trial
  tiros_1 = 90
  distribucion_teorica = np.random.binomial(tiros_1, mejor,size=10000)
  limite = np.quantile(distribucion_teorica,0.01)

  cantidad_tiros.append(len(jugadores) * tiros_1)
  aciertos = vec_ftirar(jugadores, tiros_1)
  mask = (aciertos > limite)

  remanentes = jugadores[mask]
  aciertos = aciertos[mask]
  total_aciertos = remanentes + aciertos

  #--------- segundo trial
  tiros_2 = 100
  distribucion_teorica = np.random.binomial(tiros_2, mejor,size=10000)
  limite = np.quantile(distribucion_teorica,0.01)

  cantidad_tiros.append(len(remanentes) * tiros_2)
  aciertos_2 = vec_ftirar(remanentes, tiros_2)
  mask_2 = (aciertos_2 > limite)

  remanentes_2 = remanentes[mask_2]
  aciertos_2 = aciertos_2[mask_2]
  total_aciertos = total_aciertos[mask_2] + aciertos_2

  #--------- tercer trial
  tiros_3 = 155
  distribucion_teorica = np.random.binomial(tiros_3, mejor,size=10000)
  limite = np.quantile(distribucion_teorica,0.01)

  cantidad_tiros.append(len(remanentes_2) * tiros_3)
  aciertos_3 = vec_ftirar(remanentes_2, tiros_3)
  mask_3 = (aciertos_3 > limite)

  remanentes_3 = remanentes_2[mask_3]
  aciertos_3 = aciertos_3[mask_3]
  total_aciertos = total_aciertos[mask_3] + aciertos_3

  ganador_idx = np.argmax(np.floor(total_aciertos))
  ganador = remanentes_3[ganador_idx]

  ganadores_totales.append(ganador)
  tiros_totales.append(sum(cantidad_tiros))

print(ganadores_totales)
print(tiros_totales)
# def trial(jugadores, tiros):
#   ganadores = []
#   cantidad_tiros = []
#   remanentes = jugadores
#   while len(remanentes) != 1:
#     cantidad_tiros.append(len(remanentes)*tiros)
#     aciertos = vec_ftirar(remanentes,tiros)
#     mask = (aciertos > limite)


#     if len(remanentes[mask]) == 0: 
#       print("vaciooo")
#       return random.sample(remanentes) , sum(cantidad_tiros)
#     else:
#       remanentes = remanentes[mask]
#   return remanentes, sum(cantidad_tiros)

# ganadores_historicos = []
# tiros_historicos = []


# for i in range(20):
#   ganador = trial(jugadores)
#   ganadores_historicos.append(ganador[0])

# plt.hist(ganadores_historicos)
# plt.show()
# for i in range(2):

#   ganador, tiros = trial(jugadores)
#   ganadores_historicos.append(ganador)
#   tiros_historicos.append(tiros)

  


# plt.hist(ganadores_historicos)
# plt.show()
# plt.hist(tiros_historicos)
# plt.show()