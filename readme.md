# A quick note on leaflet
GjT  
2 juillet 2015  

## Intro

Leaflet is one of the most popular open-source JavaScript libraries for interactive maps. It’s used by websites ranging from The New York Times and The Washington Post to GitHub and Flickr, as well as GIS specialists like OpenStreetMap, Mapbox, and CartoDB.

The R package `leaflet` made by rstudio (thanks to the team) makes it easy to integrate and control leaflet and map

It becomes very popular since a year, when we have to deal with javascript to integrate stuff like : cluster, dynamic legends, combination with json.

The step by step tutorial here : [https://rstudio.github.io/leaflet/](https://rstudio.github.io/leaflet/)

## A quick code

Whit the few following lines of code, we can plot a dynamic map.

Here, It is about spain and some spots where people meet


```r
# Read and organize data
load("./../garage_score.RData")
load("./../xptIOP.RData")

sp_data= dplyr::select(data,entity,garage_lon,garage_lat,global_scoring,claims_volume_2011_2014,
                   NAME_2)
```

Packages and data cleaning


```r
# Package to use
library(rgdal)
```

```
## Loading required package: sp
## rgdal: version: 1.0-4, (SVN revision 548)
##  Geospatial Data Abstraction Library extensions to R successfully loaded
##  Loaded GDAL runtime: GDAL 1.11.2, released 2015/02/10
##  Path to GDAL shared files: C:/Users/g-tchinde/Documents/R/win-library/3.2/rgdal/gdal
##  GDAL does not use iconv for recoding strings.
##  Loaded PROJ.4 runtime: Rel. 4.9.1, 04 March 2015, [PJ_VERSION: 491]
##  Path to PROJ.4 shared files: C:/Users/g-tchinde/Documents/R/win-library/3.2/rgdal/proj
##  Linking to sp version: 1.1-1
```

```r
library("dplyr")
```

```
## 
## Attaching package: 'dplyr'
## 
## The following objects are masked from 'package:stats':
## 
##     filter, lag
## 
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
require(devtools)
```

```
## Loading required package: devtools
```

```r
library(rCharts) ; 
library("rMaps") ; 
```

```
## 
## Attaching package: 'rMaps'
## 
## The following objects are masked from 'package:rCharts':
## 
##     Datamaps, Leaflet, makeChoroData, processChoroData, rqMap
```

```r
library(leaflet)

sp_data = filter(sp_data,garage_lon>=-10)
names(sp_data)<- c("entity","long","lat","score","nb_claims","city")

# Contours of spain
filename<-list.files(".", pattern=".shp", full.names=FALSE)
filename<-gsub(".shp", "", filename)
dat<-readOGR(".", filename) 
```

```
## OGR data source with driver: ESRI Shapefile 
## Source: ".", layer: "ESP_adm2"
## with 51 features
## It has 11 fields
```

```r
# ----- Transform to EPSG 4326 - WGS84 (required)
subdat<-spTransform(dat, CRS("+init=epsg:4326"))
# ----- change name of field we will map
names(subdat)
```

```
##  [1] "ID_0"      "ISO"       "NAME_0"    "ID_1"      "NAME_1"   
##  [6] "ID_2"      "NAME_2"    "NL_NAME_2" "VARNAME_2" "TYPE_2"   
## [11] "ENGTYPE_2"
```

```r
names(subdat)[names(subdat) == "NAME_1"]<-"city"
#leafdat<-paste(getwd(), "/",  ".geojson", sep="") 
#writeOGR(subdat, leafdat, layer="", driver="GeoJSON")
sp_json <- readLines("./ESP_adm2.geojson", warn = FALSE) %>% paste(collapse = "\n") 
```

Mapping


```r
# mapping
sp_data$cut <- with(sp_data, cut(nb_claims, 
                                breaks=quantile(nb_claims,
                                                probs=seq(0,1, by=0.1)), 
                                include.lowest=TRUE))

my_colors  <- colorFactor(
  palette = "Blues",
  domain = sp_data$cut
)


m= leaflet(sp_data) %>%
  addTiles()%>%
  addCircleMarkers(radius = ~log(nb_claims), lng= ~long,
                   lat=~lat, opacity = 0.3, weight=1,
                   color = ~my_colors(cut)) %>%
  addMarkers(
    clusterOptions = markerClusterOptions()) %>% 
  addGeoJSON(sp_json,weight = 1,fill = FALSE,opacity = 0.5,color = "#444444")%>%
  addLegend("bottomright", pal = my_colors, values = ~cut,
            title = "Nb of what I want",
            opacity = 1
  )

m
```
It looks like 

![my leaflet][id]





Done ! 

[id]: images/lflt.PNG "A simple leaflet"

