library(sf)
library(raster)
library(dplyr)
library(spData)
library(spDataLarge)
library(tmap)    # for static and interactive maps
library(leaflet) # for interactive maps
library(ggplot2) # tidyverse data visualization package
library(googleVis)
library(leaflet)
library(rbokeh)

df <- read.csv("DATA/df_mod.csv", sep = ",")
  
data("World")
countries = df %>% group_by(country) %>%
  summarise(CRRA = mean(r),
            Observartions = n()) %>% 
  rename(name=country) 
  
new_tab = left_join(World, countries, by = "name") 

tmap_mode("view") 

tm_shape(new_tab) +
  tm_fill('CRRA', 
             title = "Risk propensity",
            breaks = c(0, 0.2, 0.4, 0.6, Inf),
             textNA = "No data yet",
             colorNA = "white",
            popup.vars = c("CRRA","Observartions")
             ) + tm_borders() +
  tm_layout("World Density Population Map") + 
  tm_basemap("Stamen.Watercolor") + tm_view(set.view = c(40, 20, 1))
