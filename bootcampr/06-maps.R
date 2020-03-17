library(tidyverse)
library(sf)
# install.packages(c("tidyverse","sf"))

churches <- read_csv("https://raw.githubusercontent.com/unolibraries/workshops/master/bootcampr/data/churches.csv")
glimpse(churches)

churches %>% 
  ggplot() +
  geom_point(aes(x = Longitude, y = Latitude)) + 
  labs(title = "Churches in New Orleans")

## Task: Add a subtitle 
churches %>% 
  ggplot() +
  geom_point(aes(x = Latitude, y = Longitude)) + 
  labs(title = "Churches in New Orleans",
       subtitle = "Congregations in 1940s New Orleans")

## Task: Change the color of the points for the Congregation
churches %>% 
  ggplot() +
  geom_point(aes(x = Latitude, y = Longitude, color = Congregation)) + 
  labs(title = "Churches in New Orleans",
       subtitle = "Congregations in 1940s New Orleans") +
  theme(legend.position = "none")

theme_set(theme_minimal())

# Basemap
## ggmap for fetching our basemap 
library(ggmap) # install.packages('ggmap')
basemap <- get_stamenmap(bbox = c(left = min(churches$Longitude), 
                                  right = max(churches$Longitude), 
                                  bottom = min(churches$Latitude), 
                                  top = max(churches$Latitude)),
                         zoom = 12)

ggmap(basemap) +
  geom_point(data = churches, aes(x = Longitude, y = Latitude, color = Congregation),
             size = 2, alpha = 0.7) + 
  labs(title = "Churches in New Orleans",
       subtitle = "Congregations in 1940s New Orleans") +
  theme(legend.position = "none")

## Task: Plot the race of the congregation. Turn on the legend.
ggmap(basemap) +
  geom_point(data = churches, aes(x = Longitude, y = Latitude, color = Congregation_Race),
             size = 2, alpha = 0.7) + 
  labs(title = "Churches in New Orleans",
       subtitle = "Congregations in 1940s New Orleans")

# Leaflet
## interactive maps
library(leaflet)

leaflet() %>% 
  addTiles()

## Providing lat/lon 
leaflet() %>%
  setView(lng = -90.0715, lat = 29.9510, zoom = 12) %>% 
  addTiles()

## Leaflet tile providers 
leaflet() %>%
  setView(lng = -90.0715, lat = 29.9510, zoom = 12) %>%
  addProviderTiles(provider = providers$Esri.NatGeoWorldMap)

leaflet() %>%
  setView(lng = -90.0715, lat = 29.9510, zoom = 12) %>%
  addProviderTiles(provider = providers$CartoDB.Positron)

## WMS tiles 
leaflet() %>% 
  addTiles() %>% 
  setView(-90.0715, 29.9510, zoom = 4) %>% 
  addWMSTiles(
    "http://mesonet.agron.iastate.edu/cgi-bin/wms/nexrad/n0r.cgi",
    layers = "nexrad-n0r-900913",
    options = WMSTileOptions(format = "image/png", transparent = TRUE),
    attribution = "Weather data (c) 2012 IEM Nexrad"
  )

## Add polygons
leaflet() %>% 
  addTiles() %>% 
  addRectangles(
    lng1 = min(churches$Longitude), lat1 = min(churches$Latitude),
    lng2 = max(churches$Longitude), lat2 = max(churches$Latitude),
    fillColor = "transparent",
    color = "steelblue"
  )

# Leaflet churches 
leaflet(data = churches) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>% 
  addCircleMarkers(
    radius = 3, 
    fillOpacity = 0.7,
    stroke = FALSE
  )

# Leaflet palettes
pal <- colorFactor(
  palette = c('#a6cee3',
              '#1f78b4',
              '#33a02c',
              '#fb9a99',
              '#e31a1c',
              '#fdbf6f'),
  domain = churches$Congregation_Race
)

leaflet(data = churches) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>% 
  addCircleMarkers(
    radius = 3, 
    fillColor = ~pal(Congregation_Race),
    fillOpacity = 0.7,
    stroke = FALSE
  ) %>% 
  addLegend("bottomright", pal = pal, values = ~Congregation_Race,
            title = "Race of Congregation",
            opacity = 1)

# Shapefiles 
holc <- st_read("static/data/cartodb-query.shp")

holcpal <- colorFactor(
  palette = c("green","blue","yellow","red"),
  domain = holc$holc_grade
)

leaflet(data = churches) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>% 
  addPolygons(data = holc,
              stroke = FALSE,
              smoothFactor = 0.5,
              fillColor = ~holcpal(holc_grade),
              fillOpacity = 0.3) %>% 
  addCircleMarkers(
    radius = 3, 
    fillColor = ~pal(Congregation_Race),
    fillOpacity = 0.7,
    stroke = TRUE,
    weight = 1, # stroke width in pixels
    color = "black"
  ) %>% 
  addLegend("bottomright", pal = pal, values = ~Congregation_Race,
            title = "Race of Congregation",
            opacity = 1)
