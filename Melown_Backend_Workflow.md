# Introduction
Below is a tutorial setting up a 3D interactive website (such as Mars in Google Earth) on your own server, using the Melown Tech VTS 3D map streaming and rendering stack. 

Tutorials to do so can be found here:  
+ Set up the VTS backend environment (done by Rich Signell, USGS): http://vtsdocs.melown.com/en/latest/tutorials/vtsbackend.html
+ Setting up terrain and bound layers: http://vtsdocs.melown.com/en/latest/tutorials/mars-peaks-and-valleys.html  
+ Setting up monolitic vector layer: http://vtsdocs.melown.com/en/latest/tutorials/mars-peaks-and-valleys-searchable-nomenclature.html#the-labels  
+ Setting up tiled vector layer (not used here directly): http://vtsdocs.melown.com/en/latest/tutorials/cadastre.html  
+ Configuration file structure explanation : https://github.com/Melown/vts-mapproxy/blob/master/docs/resources.md
+ Layers checking on and off in browser:  http://vtsdocs.melown.com/en/latest/tutorials/landuse-frontend.html   

Usefull terminology:
+ geoidGrid = The geoid is the shape that the surface of the oceans would take under the influence of Earth's gravity and rotation alone, in the absence of other influences such as winds and tides. The grid EGM96 (Earth Gravitational Model 1996) is a geopotential model of the Earth consisting of spherical harmonic coefficients complete to degree and order 36. Currently, WGS 84 uses the EGM96 (Earth Gravitational Model 1996) geoid, revised in 2004.  
Read about geoidGird terminology: http://vtsdocs.melown.com/en/latest/reference/concepts.html 

+ Mapproxy explanation: http://vtsdocs.melown.com/en/latest/reference/server/mapproxy/  
Mapproxy store: ``` /var/vts/mapproxy/store```  
The mapproxy freezes resource definitions in its store. If the original data was moved and configuration was properly adjusted, the frozen paths (that is where you get the gdal errors) will be wrong. The freezing is important for production environment but here it is more of a trouble. There is fortunately an easy workaround - you just need to get rid of the store:  
   + Stop mapproxy: ``` $ sudo /etc/init.d/vts-backend-mapproxy stop ```  
   + Remove the store (just move it for further analysis, should you/we need it later): ``` $ sudo mv /var/vts/mapproxy/store /var/vts/mapproxy/store.old``` 
   + Restart mapproxy: ```sudo /etc/init.d/vts-backend-mapproxy start``` 

+ Create MBTiles from the geojson (used to create tiled vector layer-cadastre tutorial)  
MBTiles = file format for storing tilesets  
Tilesets = Collection of raster or vector data broken up into a uniform grid of square tiles at 22 preset zoom levels. Tilesets are used in Mapbox libraries and SDKs as a core piece of making maps visible on mobile devices or in the browser. They are also the main mechanism we use for determining map views.Tilesets are highly cacheable and load quickly. Mapbox relies heavily on both raster and vector tilesets to keep our maps fast and efficient.  



# Preparation
Important directories to make:  
+ Resource directory: ```/etc/vts/mapproxy/sandwich.d ```   
+ Dataset directory: ```/var/vts/mapproxy/datasets/sandwich```  

Edit mapproxy resource configuration: ```/etc/vts/mapproxy/resources.json``` by adding line for sandwich resources: 
```
[
    { "include": "examples.d/*.json" },
    { "include": "mars-case-study.d/*.json"  },
    { "include": "sandwich.d/*.json" }
]  
```
During resource preparation it is advisible to turn off the mapproxy, so that you have time to correct mistakes in your configuration (do this as ubuntu user, not vts): ```$ sudo /etc/init.d/vts-backend-mapproxy stop``` 
Later you can turn the mapproxy back on (only as ubuntu user): ```sudo /etc/init.d/vts-backend-mapproxy start``` and examine the log (``` less /var/log/vts/mapproxy.log```) , everything should be saying "Ready to serve" 


# Set up a DEM (terrain/dynamic surface)
Terrain/DEM layer: actual heights  
Dataset: /var/vts/mapproxy/datasets/sandwich -- DEM/MAX/MIN/CUBICSPLINE  
Resource configuration file: /etc/vts/mapproxy/sandwich.d/sandwich_dem.json 

### Prepare the DEM 
Copy DEM to the dataset folder used by the VTS backend (works only if you're logged in as the vts user): ```$ cp /home/ubuntu/data/drone/2017-03-16_Sandwich_v1_DEM_10cm.tif /var/vts/mapproxy/datasets/sandwich```  

Change directory for easy use: ```$ cd /var/vts/mapproxy/datasets/sandwich```  

Generate 3 sets of overviews of the DEM with different resampling algorithm:  
```
$ for resampling in min max cubicspline; do \
    generatevrtwo --input 2017-03-16_Sandwich_v1_DEM_10cm.tif \
        --output 2017-03-16_Sandwich_v1_DEM_10cm.$resampling \
        --resampling $resampling --overwrite 1; done
```
Try to add if not work: --co PREDICTOR=3  

Create directory to hold symbolic links (in the directory you've changed to):   
```
$ mkdir sandwich_dem_resampling && cd sandwich_dem_resampling
$ ln -s ../2017-03-16_Sandwich_v1_DEM_10cm.cubicspline/dataset dem
$ ln -s ../2017-03-16_Sandwich_v1_DEM_10cm.min/dataset dem.min
$ ln -s ../2017-03-16_Sandwich_v1_DEM_10cm.max/dataset dem.max
$ cd .. 
```

Take measurements of one of the newly created datasets:```$ mapproxy-calipers sandwich_dem_resampling/dem.min --referenceFrame melown2015```  
Measurements:    
range: 15,23 4983,6095:4984,6096  
position: obj,-70.481013,41.765911,float,0.000000,0.000000,-90.000000,0.000000,2407.202226,45.000000  

Mapproxy tiling: make sure that the tiling and the names of the dem on which the tiling has happened are the same!!!  
```
$ mapproxy-tiling --input sandwich_dem_resampling --referenceFrame melown2015 \
    --lodRange 15,23 --tileRange 4983,6095:4984,6096
```

### Set up the terrain resource configuration file
Create resource configuration file: ```$ touch /etc/vts/mapproxy/sandwich.d/sandwich_dem.json```  
With following content: position is from the mapproxy-callipers outcome. 
```
[{
    "group" : "sandwich",
    "id" : "sandwich_dem_resampling",
    "comment" : "Sandwich DEM",
    "type" : "surface",
    "driver" : "surface-dem",
    "definition" : {
        "dataset" : "sandwich/sandwich_dem_resampling",
        "geoidGrid": "egm96_15.gtx",
        "introspection": {
            "tms": {
                "group": "sandwich",
                "id": "sandwich_ortho"
            },
            "position": ["obj",-70.481013,41.765911,"float",0.000000,0.000000,-90.000000,0.000000,2407.202226,45.000000]
        }
    },
    "referenceFrames" : {
        "melown2015" : {
            "lodRange" : [ 15, 23 ],
            "tileRange" : [
                [ 4983, 6095 ],
                [ 4984, 6096 ]
            ]
        }
    },
    "registry" : {
        "credits" : {
            "USGS eastern region" : {
                "id" : 206,
                "notice" : "USGS - Chis Sherwood"
            }
        }
    },
    "credits" : [ "USGS eastern region" ]
}]
```

# Set up bound layers:  
VOCABULARY: Bound layers are tiled texture/imagery layers draped over surfaces. Map configuration (resources.json) tells client which bound layers should be bound to a particular surface  

Global mosaic/context layer: orthophoto  
Dataset: /var/vts/mapproxy/datasets/sandwich -- ORTHO/AVERAGE  
Resource configuration file: /etc/vts/mapproxy/sandwich.d/sandwich_ortho.json 

### Prepare the orthophoto
Build overviews for the orthophoto imagery with generatevrtwo function. (Input variable is a file, the ouput variable is a directory!): No wrapx parameter if it is not a global dataset     
```$ generatevrtwo --input /var/vts/mapproxy/datasets/sandwich/2017-03-16_Sandwich_v1_ORTHO_10cm.tif  --output /var/vts/mapproxy/datasets/sandwich/2017-03-16_Sandwich_v1_ORTHO_10cm.average --resampling average --co PREDICTOR=2 --co ZLEVEL=9 --tileSize 4096x4096``` 

The virtual dataset is created in /dataset. Create symbolic link to access it (convenience purporse):  
```$ ln -s /var/vts/mapproxy/datasets/sandwich/2017-03-16_Sandwich_v1_ORTHO_10cm.average/dataset /var/vts/mapproxy/datasets/sandwich/sandwich_ortho```  

Take measurements from the dataset using the mapproxy-callipers command. The outcomes are needed in a further stage.   
```
$ cd /var/vts/mapproxy/datasets/sandwich
$ mapproxy-calipers sandwich_ortho --referenceFrame melown2015 
```
Results:  
range: 15,23 4983,6095:4984,6096
position: obj,-70.480140,41.766404,float,0.000000,0.000000,-90.000000,0.000000,1369.695663,45.000000  

### Set up the mosaic resource configuration file
Create a resource configuration file for the orthophoto: ```$  /etc/vts/mapproxy/sandwich.d/sandwich_ortho.json``` and edit is as described below:    
```
[{
    "group" : "sandwich",
    "id" : "sandwich_ortho",
    "comment" : "Sandwich March 2017 ORTHO",
    "type" : "tms",
    "driver" : "tms-raster",
    "definition" :  {
        "dataset" : "sandwich/sandwich_ortho",
        "format" : "jpg",
        "transparent" : false
    },
    "referenceFrames" : {
        "melown2015" : {
            "lodRange" : [ 15, 23 ],
            "tileRange" : [
                [ 4983, 6095 ],
                [ 4984, 6096 ]
            ]
        }
    },
    "registry" : {
        "credits" : {
            "USGS eastern region" : {
                "id" : 206,
                 "notice" : "USGS - Chris Sherwood"
            }
        }
    },
    "credits" : [ "USGS eastern region" ]
}]
```

# Set up vector layer (monolithic):  
Set up a "monolithic geodata free layer definition" - geodata-vector driver, instead of a geodata-vector-tiled driver found at the cadastre. Put the .kmz, .json or .shp file in the dataset folder: ```var/vts/mapproxy/datasets/sandwich/vector/Targets.json ```   

### Create the resource configuration file
In VTS terminology, you will create a monolithic geodata free layer definition. Among other things, it defines the path to the feature dataset (definition.dataset) and elevation DEM (definition.demDataset). Create a resource configuration file at ```/etc/vts/mapproxy/sandwich.d/sandwich_vector.json ``` with the following contents. The vector layer will have the same tile range as SRTM DEM because larger is not needed.
```
[{
    "comment": "Sandwich sampling location 10 January 2018",   
    "group": "sandwich",
    "id": "vector", 
    "type": "geodata",   
    "driver": "geodata-vector",    
    "definition": {
        "dataset": "sandwich/vector/Targets.json",
        "demDataset": "sandwich/sandwich_dem_resampling",
        "geoidGrid": "egm96_15.gtx",
        "displaySize": 1024,
        "mode": "auto",
        "styleUrl": "file:sandwich/vector/sampling_locations.style",
        "introspection": {
            "surface": {
                "group": "sandwich",
                "id": "sandwich_dem_resampling"
            },
            "browserOptions": {}
        }
    },
    "referenceFrames": {
        "melown2015": {
            "lodRange": [15,23],
            "tileRange": [[4983,6095], [4984,6096]]
        }
    },
    "registry": {
        "credits": {"USGS eastern region": { "id": 206, "notice" : "USGS - Chris Sherwood" }}
    },
    "credits": ["USGS eastern region"]
}]
```
### Create the style configuration file
Geodata free layers are stylable in a manner remotely resembling CSS. The style file is referenced in the above resource definition (definition.styleUrl). The file does not exist yet. Fix this by putting the following into ``` /var/vts//mapproxy/datasets/sandwich/vector/sampling_locations.style ```:  

How to format VTS geodata can be found here: https://github.com/Melown/vts-browser-js/wiki/VTS-Geodata-Format

```
{
    "layers": {
        "point-labels": {
        "filter": ["<=","$diameter",2],
        "label": true,
        "label-size": 20,
        "zbuffer-offset": [-1,0,0],
        "culling": 90,
        "visibility-abs": [0,120000]
        },
        "labels-size0": {
            "filter": [">","$diameter",2],
            "label": true,
            "label-size": 20,
            "zbuffer-offset": [-1,0,0],
            "culling": 90,
            "visibility-rel": [{"str2num":"$diameter"}, 1000, 0.08, 0.8]
        }
    }
}
```



# Error log
Check the error log for mistakes: ``` /var/log/vts/mapproxy.log ```  




# URL's
Following URL contains the mosaic: 
http://jetstream.signell.us:8070/mapproxy/melown2015/tms/sandwich/sandwich_ortho/  
Build-up of the URL can be found here: http://vtsdocs.melown.com/en/latest/reference/server/vts-backend.html#how-it-works 



Following URL should hold the 3D map: http://jetstream.signell.us:8070/mapproxy/melown2015/surface/sandwich/sandwich_dem_resampling/  

Description URL: ``` <server>:<port>/<reference-frame>/<resource-type>/<resource-group>/<resource-id>/ ```

imilarly, URL `localhost:8070/store/` points to VTSD upstream which supports directory listing allowing to browse to particular [storage](http://vtsdocs.melown.com/en/latest/reference/concepts.html#storage), [tileset](http://vtsdocs.melown.com/en/latest/reference/concepts.html#tileset) or [storage view](http://vtsdocs.melown.com/en/latest/reference/concepts.html#storage-view).

# Summary

Datasets: 

+ /var/vts/mapproxy/datasets/sandwich/sandwich_dem_resampling

+ /var/vts/mapproxy/datasets/sandwich/sandwich_ortho

+ /var/vts/mapproxy/datasets/sandwich/vector/Targets.json

  ​



Resources: 

+  /etc/vts/mapproxy/sandwich.d/sandwich_dem.json
+ /etc/vts/mapproxy/sandwich.d/sandwich_ortho.json
+ /etc/vts/mapproxy/sandwich.d/sandwich_vector.json