
# Read and organize data
rm(list= ls())
load("../rdefault/garage_score.RData")
load("../rdefault/xptIOP.RData")

sp_data= dplyr::select(data,entity,garage_lon,garage_lat,global_scoring,claims_volume_2011_2014,
                   NAME_2)

# Package to use
library("dplyr")
require(devtools)
library(rCharts) ; 
library("rMaps") ; 
library(leaflet)

sp_data = filter(sp_data,garage_lon>=-10)
names(sp_data)<- c("entity","long","lat","score","nb_claims","city")

# Contours de l'espagne
filename<-list.files(".", pattern=".shp", full.names=FALSE)
filename<-gsub(".shp", "", filename)
dat<-readOGR(".", filename) 
# ----- Transform to EPSG 4326 - WGS84 (required)
subdat<-spTransform(dat, CRS("+init=epsg:4326"))
# ----- change name of field we will map
names(subdat)
names(subdat)[names(subdat) == "NAME_1"]<-"city"
leafdat<-paste(getwd(), "/",  ".geojson", sep="") 
writeOGR(subdat, leafdat, layer="", driver="GeoJSON")
sp_json <- readLines("./ESP_adm2.geojson", warn = FALSE) %>% paste(collapse = "\n") 

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
