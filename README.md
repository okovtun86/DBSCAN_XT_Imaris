# DBSCAN_XT_Imaris
A custom Imaris XT to run DBSCAN clustering algorithm on a Surfaces object

To run within Imaris (tested in Imaris 10.0), copy the .m Matlab script and the associated compiled .exe into the XTensions folder in the Imaris installation directory.

The .exe was compiled in Matlab 2022b using 
```
mcc -m C:\...test\SurfacesCluster.m -d C:\...\test
```

DBSCAN is executed as follows:
```
minpts = 5; 
epsilon = 1;
labels = dbscan(vXYZ,epsilon,minpts);
```

The DBSCAN algorithm was first proposed by Ester and colleagues in 1996:
Ester, Martin, et al. "A density-based algorithm for discovering clusters in large spatial databases with noise." kdd. Vol. 96. No. 34. 1996.
