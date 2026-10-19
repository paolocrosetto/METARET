# Preliminaries ----

## Packages ----

if(is.na(any(installed.packages() == "jsonlite"))){
  install.packages("jsonlite")}
library(jsonlite)

if(is.na(any(installed.packages() == "tidyverse"))){
  install.packages("tidyverse")}
library(tidyverse)

if(is.na(any(installed.packages() == "geojsonR"))){
  install.packages("geojsonR")}
library(geojsonR)

if(is.na(any(installed.packages() == "hrbrthemes"))){
  install.packages("hrbrthemes")}
library(hrbrthemes)

## Directories ----

options(stringsAsFactors=T)

saveDir <- "C:/Users/jaspersen/Desktop/RPW/Final/Output/" 

dataDir <- "C:/Users/jaspersen/Desktop/RPW/Final/"

## Color Palletes and Fonts ----

cbp1 <- c("#999999", "#E69F00", "#56B4E9", "#009E73",
          "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

cbp2 <- c("#000000", "#E69F00", "#56B4E9", "#009E73",
          "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

fontFace <- "serif"

# Figure 2 ----

## import data ----
downloads <- read.csv(file.path(dataDir,"data_DownloadCount.csv"), sep=",",header = TRUE)

## Figure ----
ggplot(data = downloads, aes(x = day, y = downloads)) + geom_line(color = cbp2[1], size = 1)+
  geom_point(color = cbp2[1], size = 2, color =cbp2[1])+
  scale_y_continuous(
    # Features of the first axis
    #name = "Downloads (in 1000s)", 
    name = expression(atop("Downloads", paste("(in 1000s)"))),
    limits = c(0,6000),labels = c("0.0","1.0","2.0","3.0","4.0","5.0","6.0"),breaks = c(0,1000,2000,3000,4000,5000,6000),
  )  +  
  theme(axis.text=element_text(size=25, color = "grey20"), axis.title=element_text(size=25, color = "grey20"), #size = 20
        axis.ticks = element_line(color = "grey60"),
        text = element_text(size = 25, family = fontFace),
        panel.background = element_rect(fill = "white", colour = "grey60"),
        panel.grid.major = element_line(colour = "grey60"),
        axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
        axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 20)))+
  scale_x_continuous(name="Days",  labels=c("1", "15","30","45", "60"), breaks = c(1,15,30,45,60))

ggsave(path = saveDir,"Figure2.png",width = 12, height=4)

# Figure 3(a) ----

## import the data ----
rounds <- read.csv(file.path(dataDir,"data_GameRunCount.csv"), sep=",",header = TRUE)

## Figure ----
ggplot(data = rounds,aes(x = Day, y = NumRuns, color = SampleType)) + geom_line(size = 1, aes(color=SampleType) ) + geom_point(size = 2)+
  scale_y_continuous(
    # Features of the first axis
    name = "Game runs (in 1000s)", limits = c(0,25000),labels = c("0.0","5.0","10.0","15.0","20.0","25.0"),breaks = c(0,5000,10000,15000,20000,25000),
  )  +  
  theme(axis.text=element_text(size=35, color = "grey20"), axis.title=element_text(size=35, color = "grey20"),
        axis.ticks = element_line(color = "grey60"), 
        text = element_text(size = 35, family = fontFace),
        panel.background = element_rect(fill = "white", colour = "grey60"),
        panel.grid.major = element_line(colour = "grey60"),
        axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 10)),
        axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 10)),
        legend.title = element_blank(),
        legend.position = c(.95, .95),
        legend.justification = c("right", "top"),
        legend.box.just =  "top",
        legend.text = element_text(color = "grey20",size = 35),
        legend.spacing.y  = unit(0.0,'cm'),
        legend.background = element_rect(size=0.5, linetype="solid", 
                                         colour ="black"),
        legend.key = element_rect(fill = NA, color = NA),)+
  scale_x_continuous(name="Days",  labels=c("1", "15","30","45", "60"), breaks = c(1,15,30,45,60))+
  scale_color_manual(name = "", labels = c("All", "With consent", "In sample"), values=c("gray1", "gray30", "gray68"))

ggsave(path = saveDir,"Figure3(a).png", width = 12, height=6)

# Figure 3(b) ----

## import data ----
lotAmount <- read.csv(file.path(dataDir,"data_LotteriesCount.csv"), sep=",",header = TRUE)

## Figure ----
ggplot() + geom_line(data = lotAmount, aes(x = day, y = lotteries), color = cbp2[1], size = 1)+
  geom_point(data = lotAmount, aes(x = day, y = lotteries), color = cbp2[1], size = 2, color =cbp2[1])+
  scale_y_continuous(
    # Features of the first axis
    name = "Lotteries (in 1000s)", limits = c(0,5000),labels = c("0.0","1.0","2.0","3.0","4.0","5.0"),breaks = c(0,1000,2000,3000,4000,5000),
  )  +  
  theme(axis.text=element_text(size=35, color = "grey20"), axis.title=element_text(size=35, color = "grey20"),
        axis.ticks = element_line(color = "grey60"), 
        text = element_text(size = 35, family = fontFace),
        panel.background = element_rect(fill = "white", colour = "grey60"),
        panel.grid.major = element_line(colour = "grey60"),
        axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
        axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 10)))+
  scale_x_continuous(name="Days",  labels=c("1", "15","30","45", "60"), breaks = c(1,15,30,45,60)) 

ggsave(path = saveDir,"Figure3(b).png",width = 12, height=6)


