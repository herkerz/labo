import matplotlib.pyplot as plt
import pandas as pd
import matplotlib.dates as mdates

df = pd.read_table(r"C:\\Users\\hgker\\Desktop\\master_ds\\mineria\\baye_max_depth_7_8.txt",parse_dates=["fecha"])

# df_7 = df[df.maxdepth==7]

# x7 = df_7["minbucket"]
# y7= df_7["minsplit"]
# z7 = df_7["ganancia"]

# df_8 = df[df.maxdepth==8]

# x8 = df_8["minbucket"]
# y8= df_8["minsplit"]
# z8 = df_8["ganancia"]




# fig = plt.figure()
# ax = plt.axes(projection='3d')

# #ax.plot_trisurf(x7, y7, z7,cmap="spring",alpha=0.73)
# ax.plot_trisurf(x8, y8, z8,cmap="viridis",alpha=0.75)

# ax.set_title('surface')
# ax.set_xlabel("minbucket")
# ax.set_ylabel("minsplit")
# ax.set_zlabel("ganancia")
# plt.show()


df_zoom = pd.read_table(r"C:\\Users\\hgker\\Desktop\\master_ds\\mineria\\baye_max_depth_7_8_zoom.txt",parse_dates=["fecha"])

df_8z = df_zoom[df_zoom.maxdepth==8]

x8_zoom  = df_8z["minbucket"]
y8_zoom = df_8z["minsplit"]
z8_zoom = df_8z["ganancia"]


fig = plt.figure()
ax = plt.axes(projection='3d')

#ax.plot_trisurf(x7, y7, z7,cmap="spring",alpha=0.73)
ax.plot_trisurf(x8_zoom, y8_zoom, z8_zoom,cmap="viridis",alpha=0.75)

ax.set_title('surface')
ax.set_xlabel("minbucket")
ax.set_ylabel("minsplit")
ax.set_zlabel("ganancia")
plt.show()


