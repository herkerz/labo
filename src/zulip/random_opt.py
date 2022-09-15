import matplotlib.pyplot as plt
import pandas as pd
from matplotlib import colors

url = "https://raw.githubusercontent.com/herkerz/labo/main/src/zulip/data/random_forest_incompleto.txt"



def hyper_opt(url):
    df = pd.read_table(url,parse_dates=["fecha"])
    
    x = df["num.trees"]
    y = df["max.depth"]
    z = df["min.node.size"]
    size = df["mtry"]
    ganancia = df["ganancia"]
    
    
    
    divnorm=colors.TwoSlopeNorm(vmin=min(ganancia), vcenter=max(ganancia) * .95, vmax=max(ganancia))
    fig = plt.figure()
    ax = fig.add_subplot(projection = "3d")
    scat = ax.scatter(x,
               y,
               z,
               sizes=ganancia/100000,
               c=size,
               cmap="bwr",
               )
    
    ax.set_xlabel('num.trees')
    ax.set_ylabel('max.depth')
    ax.set_zlabel('min.node.size')
    fig.colorbar(scat, ax=ax)
    plt.show()
    
hyper_opt(url)
    