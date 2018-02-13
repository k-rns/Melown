# Introduction 

Melown tutorials

+ Starting VTS application: http://vtsdocs.melown.com/en/latest/tutorials/sample-app.html
+ Adding layer switch and legend: http://vtsdocs.melown.com/en/latest/tutorials/landuse-frontend.html


Using your own server, make sure that everything is set up correctly (see Melown_Backend_Tutorial)



# Build up

## Folder structure

**Question: Where do these files need to be put?**

Melown_Frontend:

​	index.html

​	test_sandwich_app.js



## HTML set-up

Filename: index.html

Add two files to your web page, the CSS file and the VTS-Browser library

**QUESTION: Assume everything in the head is compulsory and should not be changed even running it from our own server?**

``` HTML
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8"> 
	<title>Test Sandwich Application - USGS</title>    
	<!-- Include CSS -->    
	<link rel="stylesheet" type="text/css" href="https://cdn.melown.com/libs/vtsjs/browser/v2/vts-browser.min.css"> 
	<!-- Include JavaScript Melown API -->    
	<script type="text/javascript" src="https://cdn.melown.com/libs/vtsjs/browser/v2/vts-browser.min.js"></script>
</head>
<body style = "padding: 0; margin: 0;">
    <div id="map-div" style="width:100%; height:100%;">
    </div>   
<script type="text/javascript" src="sample-app.js"></script>
</body>
</html>
```



## JavaScript set-up

File name: test_sandwich_app.js

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

File name: 

