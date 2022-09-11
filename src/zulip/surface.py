import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

def plot_surface(url: str, max_depth: int):
    df = pd.read_table(url,parse_dates=["fecha"])
    df = df[df["maxdepth"] == max_depth]
    
    x = df["minsplit"]
    y = df["minbucket"]
    z = df["ganancia"]
    
    ax = plt.axes(projection='3d',)

    ax.plot_trisurf(x, y, z,
                    cmap="viridis",
                    alpha=0.75)

    ax.set_title(f'Ganancia Optimizacion Bayesiana Max Depth {max_depth}')
    ax.set_xlabel("minbucket")
    ax.set_ylabel("minsplit")
    ax.set_zlabel("Ganancia")
    plt.show()   

def compare_surface(urls: list, max_depths: list):
    ax = plt.axes(projection='3d')
    
    for url, max_depth in zip(urls,max_depths):
        
        df = pd.read_table(url,parse_dates=["fecha"])
        df = df[df["maxdepth"] == max_depth]
        x = df["minsplit"]
        y = df["minbucket"]
        z = df["ganancia"]
        
        surf = ax.plot_trisurf(x, y, z,
                        alpha=0.7,
                        label=f"Max Depth {max_depth}")
        surf._facecolors2d = surf._facecolor3d
        surf._edgecolors2d = surf._edgecolor3d
        ax.legend()
        
    ax.set_title('Ganancia Optimizacion Bayesiana')
    ax.set_xlabel("minbucket")
    ax.set_ylabel("minsplit")
    ax.set_zlabel("Ganancia")
    plt.show()   
        
        
    
# url = "https://raw.githubusercontent.com/herkerz/labo/main/src/zulip/data/baye_max_depth_7_8.txt"

# plot_surface(url, 8)

url_9 = "https://raw.githubusercontent.com/herkerz/labo/main/src/zulip/data/baye_max_depth_9_10.txt"

plot_surface(url_9, 9)


# url_14= "https://raw.githubusercontent.com/herkerz/labo/main/src/zulip/data/baye_max_depth_13_14.txt"

# plot_surface(url_14, 14)

# compare_surface([url_14,url_zoom],[14,10])

df = pd.read_table(url_9,parse_dates=["fecha"])


fig, (ax1,ax2) = plt.subplots(nrows=2,
                              ncols=1,
                              figsize=(18,12),
                              sharex=True)


sns.scatterplot(x= range(len(df)), 
                y=df["minsplit"],
                size=df["minbucket"],
                hue=df["maxdepth"],
                palette=['darkgray', 'darkgreen'],
                ax = ax1)

ax1.set_title("Iteration Nº")

sns.lineplot(x=range(len(df)),
            y=df["ganancia"].rolling(15).mean(),
            ax= ax2,
            c= "k")
ax2.set_title("Ganancia por iteracion")
ax2.set_xlabel("Iteracion Nº")
plt.show()