# Introduction 

Melown tutorials

+ Starting VTS application: http://vtsdocs.melown.com/en/latest/tutorials/sample-app.html
+ Adding layer switch and legend: http://vtsdocs.melown.com/en/latest/tutorials/landuse-frontend.html


Using your own server, make sure that everything is set up correctly (see Melown_Backend_Tutorial).



Contact backend-frontend: http://vtsdocs.melown.com/en/latest/architecture.html and clicking further to links, concepts and terminology: http://vtsdocs.melown.com/en/latest/reference/concepts.html#storage

The main point of contact between backend and frontend is a [Map configuration](http://vtsdocs.melown.com/en/latest/reference/concepts.html#map-configuration) represented by `mapConfig.json` file which is the first file the client asks for and which contains complete configuration needed to render given map.

The main point of contact between backend and frontend is a [Map configuration](http://vtsdocs.melown.com/en/latest/reference/concepts.html#map-configuration) represented by `mapConfig.json` file which is the first file the client asks for and which contains complete configuration needed to render given map.





# Build up

## Folder structure

**Question: Where do these files need to be put?**

Melown_Frontend:

​	index.html

​	test_sandwich_app.js



## HTML set-up

Filename: index.html

Add two files to your web page, the CSS file and the VTS-Browser library

**QUESTION: Assume that the Javascript Melown API does not have to be changed? ?**

``` HTML
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8"> 
	<title>Sandwich Application - USGS</title>    
	<!-- Include CSS -->    
	<link rel="stylesheet" type="text/css" href="https://cdn.melown.com/libs/vtsjs/browser/v2/vts-browser.min.css"> 
	<!-- Include JavaScript Melown API -->    
	<script type="text/javascript" src="https://cdn.melown.com/libs/vtsjs/browser/v2/vts-browser.min.js"></script>
</head>
<body style = "padding: 0; margin: 0;">
    <div id="map-div" style="width:100%; height:100%;">
    </div>   
<script type="text/javascript" src="sandwich_app.js"></script>
</body>
</html>
```



## JavaScript set-up

File name: sandwich_app.js and reference to this file in the <body> section, under <script>

**QUESTION: What mapConfig.json should be used here? **

```javascript

/* Basic example with 3D map */
// create map in the html div with id 'map-div'    
// parameter 'map' sets path to the map which will be displayed    
// you can create your own map on melown.com

(function startDemo() {    
	var browser = vts.browser('map-div', {
        		map: 'https://cdn.melown.com/mario/store/melown2015/map-config/melown/VTS-Tutorial-map/mapConfig.json'
    });
})();

```





## CSS set-up

CSS file. Take the start CSS file from melown:https://cdn.melown.com/libs/vtsjs/browser/v2/vts-browser.min.css and add whatever you want to add to this (i.e. [Adding layer switch and legend]( http://vtsdocs.melown.com/en/latest/tutorials/landuse-frontend.html))

File name: sandwich_style.css and reference to it in the HTML file in the <head> section 

