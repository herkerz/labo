import matplotlib.pyplot as plt
import pandas as pd
import matplotlib.dates as mdates

def plot_surface(url: str, max_depth: int):
    df = pd.read_table(url,parse_dates=["fecha"])
    df = df[df["maxdepth"] == max_depth]
    
    x = df["minsplit"]
    y = df["minbucket"]
    z = df["ganancia"]
    
    ax = plt.axes(projection='3d')

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
        
    ax.set_title(f'Ganancia Optimizacion Bayesiana Max Depth {max_depth}')
    ax.set_xlabel("minbucket")
    ax.set_ylabel("minsplit")
    ax.set_zlabel("Ganancia")
    plt.show()   
        
        
    
url = "https://raw.githubusercontent.com/herkerz/labo/main/src/zulip/data/baye_max_depth_7_8.txt"

# plot_surface(url, 8)

url_zoom = "https://raw.githubusercontent.com/herkerz/labo/main/src/zulip/data/baye_max_depth_7_8_zoom.txt"

# plot_surface(url_zoom, 8)


url_14= "https://raw.githubusercontent.com/herkerz/labo/main/src/zulip/data/baye_max_depth_13_14.txt"

# plot_surface(url_14, 14)

compare_surface([url,url_14],[8,14])