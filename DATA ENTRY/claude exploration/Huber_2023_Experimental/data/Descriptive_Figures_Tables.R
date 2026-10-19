# Preliminaries ----

## Packages ----

if(is.na(any(installed.packages() == "tidyverse"))){
  install.packages("tidyverse")}
library(tidyverse)

if(is.na(any(installed.packages() == "hrbrthemes"))){
  install.packages("hrbrthemes")}
library(hrbrthemes)

if(is.na(any(installed.packages() == "plyr"))){
  install.packages("plyr")}
library(plyr)

if(is.na(any(installed.packages() == "table1"))){
  install.packages("table1")}
library(table1)

if(is.na(any(installed.packages() == "stargazer"))){
  install.packages("stargazer")}
library(stargazer)

if(is.na(any(installed.packages() == "knitr"))){
  install.packages("knitr")}
library(knitr)

if(is.na(any(installed.packages() == "plm"))){
  install.packages("plm")}
library(plm)

if(is.na(any(installed.packages() == "gridExtra"))){
  install.packages("gridExtra")}
library(gridExtra)

## Directories ----

options(stringsAsFactors=T)

dataDir <- "C:/Users/jaspersen/Desktop/RPW/Final/" 

saveDir <- "C:/Users/jaspersen/Desktop/RPW/Final/Output/" 

## Importing ----

data <- read.csv(file = paste0(dataDir,"data_anon.csv"), sep=",",header = TRUE)

# Construct some necessary variables ----

data$safeChoice <- 1-data$pickedRisky

data$wealth1000 <- data$goldBefore/1000

data$notGerman <- 1-data$germany

data$notMale <- ifelse(data$sex != "Male",1,0)

data$over25 <- ifelse(data$cAge != "16-25",1,0)

# Table for user demographics and lottery information ----

##### we iterate two times over the following lines to apply different filters on the data
##### Iteration 1: Descriptives of the main analysis
##### Iteration 2: Online Appendix: Descriptives without first three decisions

for(v in 1:2){
  
  ### create three datasets with filters based on wealth and lottery type
  if(v == 1){
    total     <- data[which(data$goldBefore <= 6000),]
    absolute  <- data[which(data$lotType == "Absolute Lotteries" & data$goldBefore <= 6000),]
    relative  <- data[which(data$lotType == "Relative Lotteries" & data$goldBefore <= 6000),]
  }
  else{
    total     <- data[which(data$goldBefore <= 6000 & data$lotCounter > 3),]
    absolute  <- data[which(data$lotType == "Absolute Lotteries" & data$goldBefore <= 6000 & data$lotCounter > 3),]
    relative  <- data[which(data$lotType == "Relative Lotteries" & data$goldBefore <= 6000 & data$lotCounter > 3),]
  }
  
  ### save them in a list to iterate over them
  sets <- list(absolute,relative,total)
  
  ### two lists to store the descriptive information
  demographics <- NULL
  lotteries <- NULL
  
  ### temp variable to capture the balance test pValues
  test <- NULL
  
  
  ############################ Section: Unique users
  
  temp <- NULL
  for(i in 1:length(sets)){
    temp[i] <- format(round(as.numeric(length(unique(sets[[i]]$userid))), 1), nsmall=0, big.mark=",")
    if(i == length(sets)) temp[i] <- paste0(temp[i],"\\\\")
  }
  
  ## empty row for test results
  test <- rbind(test, "")
  
  
  ### save for later use
  demographics <-rbind(demographics,rbind(c("Unique Users",temp)))
  
  ############################ Section: Not German
  
  temp <- NULL
  for(i in 1:length(sets)){
    temp[i] <- paste(format(round(as.numeric(length(unique(sets[[i]]$userid[which(sets[[i]]$germany == 0)]))), 1), nsmall=0, big.mark=","),
                     paste(sep="","(",
                           format(round(length(unique(sets[[i]]$userid[which(sets[[i]]$germany == 0)]))/length(unique(sets[[i]]$userid))*100,1),nsmall = 1, big.mark=","),
                           "\\%",
                           ")"))
    if(i == length(sets)) temp[i] <- paste0(temp[i],"\\\\")
  }
  
  ## Two Proportions Z-Test
  trials <- c(length(unique(absolute$userid)),length(unique(relative$userid)))
  success <- c(length(unique(absolute$userid[which(absolute$notGerman == TRUE)])),length(unique(relative$userid[which(relative$notGerman == TRUE)])))
  test <- rbind(test,  prop.test(success,trials, alternative = "two.sided", correct = TRUE)$p.value)
  
  ### save for later use
  demographics <-rbind(demographics, rbind(c("Not German",temp)))
  
  
  ############################ Section: Age 
  
  names <- c("16-25","26-35","36-45","> 45")
  desc <- c("\\hspace{3mm} 16-25","\\hspace{3mm} 26-35","\\hspace{3mm} 36-45","\\hspace{3mm} $>$ 45") 
  temp <- matrix(nrow = length(names),ncol=length(sets))
  for(i in 1:length(sets)){
    for(m in 1:length(names)){
      
      temp[m,i] <- paste(format(round(as.numeric(length(unique(sets[[i]]$userid[which(sets[[i]]$cAge == names[m])]))), 1), nsmall=0, big.mark=","),
                         paste(sep="","(",
                               round(length(unique((sets[[i]]$userid[which(sets[[i]]$cAge == names[m])])))/length(unique(sets[[i]]$userid))*100,1),
                               "\\%",
                               ")"))
      if(i == length(sets)) temp[m,i] <- paste0(temp[m,i],"\\\\")
    }
  }
  
  ## empty row for test results
  test <- rbind(test, "")
  
  ## Two Proportions Z-Test
  trials <- c(length(unique(absolute$userid)),length(unique(relative$userid)))
  
  for(m in 1:length(names)){
    
    success <- c(length(unique(absolute$userid[which(absolute$cAge == names[m])],)),
                 length(unique(relative$userid[which(relative$cAge == names[m])])))
    
    
    test <- rbind(test,  prop.test(success,trials, alternative = "two.sided", correct = TRUE)$p.value)
  }
  
  ### save for later use
  demographics <- rbind(demographics,rbind(c("Age","","","\\\\"),cbind(desc,temp)))
  
  ############################ Section: Sex
  
  names <- c("Male","Female","Non Binary")
  desc <- c("\\hspace{3mm} Male","\\hspace{3mm} Female","\\hspace{3mm} Non-Binary") 
  temp <- matrix(nrow = length(names),ncol=length(sets))
  for(i in 1:length(sets)){
    for(m in 1:length(names)){
      
      temp[m,i] <- paste(format(round(as.numeric(length(unique(sets[[i]]$userid[which(sets[[i]]$sex == names[m])]))), 1), nsmall=0, big.mark=","),
                         paste(sep="","(",
                               format(round(length(unique(sets[[i]]$userid[which(sets[[i]]$sex == names[m])]))/length(unique(sets[[i]]$userid))*100,1),nsmall=1, big.mark=","),
                               "\\%",
                               ")"))
      if(i == length(sets)) temp[m,i] <- paste0(temp[m,i],"\\\\")
    }
  }
  
  ## empty row for test results
  test <- rbind(test, "")
  
  ## Two Proportions Z-Test
  trials <- c(length(unique(absolute$userid)),length(unique(relative$userid)))
  
  for(m in 1:length(names)){
    
    success <- c(length(unique(absolute$userid[which(absolute$sex == names[m])],)),
                 length(unique(relative$userid[which(relative$sex == names[m])])))
    
    
    test <- rbind(test,  prop.test(success,trials, alternative = "two.sided", correct = TRUE)$p.value)
  }
  
  ### save for later use
  demographics <- rbind(demographics,rbind(c("Sex","","","\\\\"),cbind(desc,temp)))
  
  
  
  ####### closing table 1
  
  ### add test results to first table
  test <- round(as.numeric(test),3)
  for(a in 1:length(test))
  {
    if(!is.na(test[a])){
      
      if(test[a] <= 0.01) test[a] <- paste(test[a],paste("***"),sep = "")
      else if(test[a] <= 0.05) test[a] <- paste(test[a],paste("**"),sep = "")
      else if(test[a] <= 0.1) test[a] <- paste(test[a],paste("*"),sep = "")
    }
  }
  
  ### add results to table
  demographics <- cbind(demographics, test)
  
  ## transform to dataframe
  demographics <- as.data.frame(demographics)
  
  ## reorder
  demographics <- demographics[,c("desc","V2","V3","test","V4")]
  
  ## remove nas
  demographics$test[which(is.na(demographics$test))] <- ""
  
  ### START OF SECOND TABLE
  ## set test to null
  
  test <- NULL
  
  ############################ Section: Game Runs
  
  temp <- matrix(nrow = 2,ncol=length(sets))
  desc <- c("\\hspace{3mm} Mean (SD)","\\hspace{3mm} Median [Min, Max]") 
  for(i in 1:length(sets)){
    
    ### To calculate the average game runs we select the first row of each individual and use their total run count
    firstRow <- sets[[i]] %>% 
      group_by(userid) %>% 
      filter(row_number()==1)
    
    temp[1,i] <- paste(format(round(as.numeric(mean(firstRow$runTotal)), 1), nsmall=1, big.mark=","),
                       paste(sep="","(",
                             round(sd(firstRow$runTotal),1),
                             ")"))
    temp[2,i] <- paste(format(round(as.numeric(median(firstRow$runTotal)), 1), nsmall=0, big.mark=","),
                       paste(sep="","(",
                             round(min(firstRow$runTotal),0),
                             ", ",
                             round(max(firstRow$runTotal),0),
                             ")"))
    
    
    if(i == length(sets)) temp[,i] <- paste0(temp[,i],"\\\\")
  }
  
  ## empty row for test results
  test <- rbind(test, "")
  
  ## T-Test with unequal variances
  firstRowAbsolute <- absolute  %>% 
    group_by(userid) %>% 
    filter(row_number()==1)
  
  firstRowRelative <- relative  %>% 
    group_by(userid) %>% 
    filter(row_number()==1)
  
  test <- rbind(test, t.test(firstRowAbsolute$runTotal,firstRowRelative$runTotal, var.equal = FALSE)$p.value)
  
  ## empty row for test results
  test <- rbind(test, "")
  
  ### save for later use
  lotteries <- rbind(lotteries,rbind(c("Game Runs","","","\\\\"),cbind(desc,temp)))
  
  ############################ Section: Lottery Choices
  
  temp <- matrix(nrow = 2,ncol=length(sets))
  desc <- c("\\hspace{3mm} Mean (SD)","\\hspace{3mm} Median [Min, Max]") 
  for(i in 1:length(sets)){
    
    ### select the number of rows for each individual
    number <- sets[[i]] %>% 
      group_by(userid) %>% 
      dplyr::summarise(count = n())
    
    temp[1,i] <- paste(format(round(as.numeric(mean(number$count)), 1), nsmall=1, big.mark=","),
                       paste(sep="","(",
                             format(round(sd(number$count),1),nsmall=1, big.mark=","),
                             ")"))
    temp[2,i] <- paste(format(round(as.numeric(median(number$count)), 0), nsmall=0, big.mark=","),
                       paste(sep="","(",
                             round(min(number$count),1),
                             ", ",
                             round(max(number$count),1),
                             ")"))
    if(i == length(sets)) temp[,i] <- paste0(temp[,i],"\\\\")
  }
  
  ## empty row for test results
  test <- rbind(test, "")
  
  ## T-Test with unequal variances
  helperAbsolute <- absolute  %>% 
    group_by(userid) %>% 
    dplyr::summarise(count = n())
  
  helperRelative <- relative  %>% 
    group_by(userid) %>% 
    dplyr::summarise(count = n())
  
  test <- rbind(test, t.test(helperAbsolute$count,helperRelative$count, var.equal = FALSE)$p.value)
  
  ## empty row for test results
  test <- rbind(test, "")
  
  ### save for later use
  lotteries <- rbind(lotteries,rbind(c("Lottery Choices","","","\\\\"),cbind(desc,temp)))
  
  ############################ Section: Spending
  
  temp <- matrix(nrow = 2,ncol=length(sets))
  desc <- c("\\hspace{3mm} Mean (SD)","\\hspace{3mm} Median [Min, Max]") 
  for(i in 1:length(sets)){
    temp[1,i] <- paste(format(round(as.numeric(mean(sets[[i]]$cSpending)), 1), nsmall=1, big.mark=","),
                       paste(sep="","(",
                             format(round(sd(sets[[i]]$cSpending),1), nsmall=1, big.mark=","),
                             ")"))
    temp[2,i] <- paste(format(round(as.numeric(median(sets[[i]]$cSpending)), 0), nsmall=0, big.mark=","),
                       paste(sep="","(",
                             format(round(min(sets[[i]]$cSpending),0), nsmall=0, big.mark=","),
                             ", ",
                             format(round(max(sets[[i]]$cSpending),0), nsmall=0, big.mark=","),
                             ")"))
    if(i == length(sets)) temp[,i] <- paste0(temp[,i],"\\\\")
  }
  
  ## empty row for test results
  test <- rbind(test, "")
  
  ## T-Test with unequal variances
  test <- rbind(test, t.test(absolute$cSpending,relative$cSpending, var.equal = FALSE)$p.value)
  
  ## empty row for test results
  test <- rbind(test, "")
  
  ### save for later use
  lotteries <- rbind(lotteries,rbind(c("Spending","","","\\\\"),cbind(desc,temp)))
  
  ############################ Section: Wealth
  
  temp <- matrix(nrow = 2,ncol=length(sets))
  desc <- c("\\hspace{3mm} Mean (SD)","\\hspace{3mm} Median [Min, Max]") 
  for(i in 1:length(sets)){
    temp[1,i] <- paste(format(round(as.numeric(mean(sets[[i]]$goldBefore)), 1), nsmall=1, big.mark=","),
                       paste(sep="","(",
                             format(round(sd(sets[[i]]$goldBefore),1), nsmall=1, big.mark=","),
                             ")"))
    temp[2,i] <- paste(format(round(as.numeric(median(sets[[i]]$goldBefore)), 0), nsmall=0, big.mark=","),
                       paste(sep="","(",
                             format(round(min(sets[[i]]$goldBefore),0), nsmall=0, big.mark=","),
                             ", ",
                             format(round(max(sets[[i]]$goldBefore),0), nsmall=0, big.mark=","),
                             ")"))
    if(i == length(sets)) temp[,i] <- paste0(temp[,i],"\\\\")
  }
  
  ## empty row for test results
  test <- rbind(test, "")
  
  ## T-Test with unequal variances
  test <- rbind(test, t.test(absolute$goldBefore,relative$goldBefore, var.equal = FALSE)$p.value)
  
  ## empty row for test results
  test <- rbind(test, "")
  
  ### save for later use
  lotteries <- rbind(lotteries,rbind(c("Wealth","","","\\\\"),cbind(desc,temp)))
  
  
  ############################ Section: Decision Time
  
  temp <- matrix(nrow = 2,ncol=length(sets))
  desc <- c("\\hspace{3mm} Mean (SD)","\\hspace{3mm} Median [Min, Max]") 
  for(i in 1:length(sets)){
    temp[1,i] <- paste(format(round(as.numeric(mean(sets[[i]]$decisionTime)), 1), nsmall=1, big.mark=","),
                       paste(sep="","(",
                             format(round(sd(sets[[i]]$decisionTime),1), nsmall=1, big.mark=","),
                             ")"))
    temp[2,i] <- paste(format(round(as.numeric(median(sets[[i]]$decisionTime)), 1), nsmall=1, big.mark=","),
                       paste(sep="","(",
                             format(round(min(sets[[i]]$decisionTime),1), nsmall=1, big.mark=","),
                             ", ",
                             format(round(max(sets[[i]]$decisionTime),1), nsmall=1, big.mark=","),
                             ")"))
    if(i == length(sets)) temp[,i] <- paste0(temp[,i],"\\\\")
  }
  
  ## empty row for test results
  test <- rbind(test, "")
  
  ## T-Test with unequal variances
  test <- rbind(test, t.test(absolute$decisionTime,relative$decisionTime, var.equal = FALSE)$p.value)
  
  ## empty row for test results
  test <- rbind(test, "")
  
  ### save for later use
  lotteries <- rbind(lotteries,rbind(c("Decision Time","","","\\\\"),cbind(desc,temp)))
  
  
  ############################ Section: Safe Choices
  
  temp <- matrix(nrow = 2,ncol=length(sets))
  desc <- c("\\hspace{3mm} Mean (SD)","\\hspace{3mm} Median [Min, Max]") 
  for(i in 1:length(sets)){
    temp[1,i] <- paste(format(round(as.numeric(mean(sets[[i]]$safeChoice)), 3), nsmall=3, big.mark=","),
                       paste(sep="","(",
                             format(round(sd(sets[[i]]$safeChoice),3), nsmall=3, big.mark=","),
                             ")"))
    temp[2,i] <- paste(format(round(as.numeric(median(sets[[i]]$safeChoice)), 1), nsmall=1, big.mark=","),
                       paste(sep="","(",
                             format(round(min(sets[[i]]$safeChoice),1), nsmall=1, big.mark=","),
                             ", ",
                             format(round(max(sets[[i]]$safeChoice),1), nsmall=1, big.mark=","),
                             ")"))
    if(i == length(sets)) temp[,i] <- paste0(temp[,i],"\\\\")
  }
  
  ## empty row for test results
  test <- rbind(test, "")
  
  ## T-Test with unequal variances
  test <- rbind(test, t.test(absolute$safeChoice,relative$safeChoice, var.equal = FALSE)$p.value)
  
  ## empty row for test results
  test <- rbind(test, "")
  
  ### save for later use
  lotteries <- rbind(lotteries,rbind(c("Safe Choices","","","\\\\"),cbind(desc,temp)))
  
  
  ############################ Section: Decision at Threshold
  
  temp <- NULL
  for(i in 1:length(sets)){
    temp[i] <- paste(format(round(as.numeric(length(sets[[i]]$userid[which(sets[[i]]$threshold == 1)])), 1), nsmall=0, big.mark=","),
                     paste(sep="","(",
                           round(length(sets[[i]]$userid[which(sets[[i]]$threshold == 1)])/length(sets[[i]]$userid)*100,1),
                           "\\%",
                           ")"))
    if(i == length(sets)) temp[i] <- paste0(temp[i],"\\\\")
  }
  
  
  ## Two Proportions Z-Test
  trials <- c(nrow(absolute),nrow(relative))
  success <- c(nrow(absolute[which(absolute$threshold == 1),]),nrow(relative[which(relative$threshold == 1),]))
  test <- rbind(test,  prop.test(success,trials, alternative = "two.sided", correct = TRUE)$p.value)
  
  ### save for later use
  lotteries <- rbind(lotteries,rbind(c("Decision at Threshold",temp)))
  
  ####### closing table 2
  
  ### add test results to second table
  test <- round(as.numeric(test),3)
  for(a in 1:length(test))
  {
    if(!is.na(test[a])){
      
      if(test[a] <= 0.01) test[a] <- paste(test[a],paste("***"),sep = "")
      else if(test[a] <= 0.05) test[a] <- paste(test[a],paste("**"),sep = "")
      else if(test[a] <= 0.1) test[a] <- paste(test[a],paste("*"),sep = "")
    }
  }
  
  ### add results to table
  lotteries <- cbind(lotteries, test)
  
  ## transform to dataframe
  lotteries <- as.data.frame(lotteries)
  
  ## reorder
  lotteries <- lotteries[,c("desc","V2","V3","test","V4")]
  
  ## remove nas
  lotteries$test[which(is.na(lotteries$test))] <- ""
  
  
  ############################ Section: Export files
  
  if(v == 1){
    write.table(demographics, file = paste0(saveDir,"/Table2_top_panel.txt"), row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)
    write.table(lotteries,file = paste0(saveDir,"/Table2_bottom_panel.txt"), row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)
  }
  else{
    write.table(demographics,file = paste0(saveDir,"/TableA4_top_panel.txt"), row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)
    write.table(lotteries,file = paste0(saveDir,"/TableA4_bottom_panel.txt"), row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)
  }
}

# Set the Colors and font for the Graphics ----

cbp1 <- c("#999999", "#E69F00", "#56B4E9", "#009E73",
          "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

cbp2 <- c("#000000", "#E69F00", "#56B4E9", "#009E73",
          "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

fontFace <- "serif"

# Figure 4 ----

## Preliminaries ----

##### Define function and calculate number of unique lotteries 
lenunq <- function(x){length(unique(x))}
data$TotalUniqLots <- as.numeric(ave(data$lotName, data$userid, FUN = lenunq))

##### Select a crosssection of panel data 
dataSel <- data[which(data$goldBefore <= 6000 & data$lotCounter == 1),]

##### Winsorize upward tail 
dataSel$lotTotal[which(dataSel$lotTotal >= 40)] <- 40

## Figures ----

ggplot() + 
  geom_histogram(aes((x=lotTotal)),data = dataSel, 
                 binwidth=1, alpha=1, position = 'identity', color = cbp2[1], fill =cbp1[1]) +
  scale_y_continuous(
    # Features of the first axis
    name = "Count (in 100s)", limits = c(0,500),labels = c("0.0","1.0","2.0","3.0","4.0","5.0"),
    breaks = c(0,100,200,300,400,500),
    ## NOt necessary right now
    # Add a second axis and specify its features
    # sec.axis = sec_axis(~./coeff, name="Decision time", breaks = c(0,3,6,9,12,15))
  ) +
  xlim(-0.1,40.1) + xlab(label ="Total Number of Lotteries Faced") +
  theme(axis.text=element_text(size=25, color = "grey20"), axis.title=element_text(size=25, color = "grey20"),
        axis.ticks = element_line(color = "grey60"), 
        text = element_text(family = fontFace),
        panel.background = element_rect(fill = "white", colour = "grey60"),
        panel.grid.major = element_line(colour = "grey60"),
        axis.title.y.left  = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
        axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 20)))+
  scale_x_continuous(name="Number of Lotteries Faced",  labels=c("0", "10","20","30","\u2265 40"), breaks = c(0,10,20,30,40)) 

ggsave(path = saveDir, "Figure4(a).png",height = 5, width = 8)  

ggplot() + 
  geom_histogram(aes((x=TotalUniqLots)),data = dataSel, 
                 binwidth=1, alpha=1, position = 'identity', color = cbp2[1], fill =cbp1[1]) +
  scale_y_continuous(
    # Features of the first axis
    name = "Count (in 100s)", limits = c(0,500),labels = c("0.0","1.0","2.0","3.0","4.0","5.0"),
    breaks = c(0,100,200,300,400,500),
    ## NOt necessary right now
    # Add a second axis and specify its features
    # sec.axis = sec_axis(~./coeff, name="Decision time", breaks = c(0,3,6,9,12,15))
  ) +
  xlim(-0.1,16.1) + xlab(label ="Total Number of Lotteries Faced") +
  theme(axis.text=element_text(size=25, color = "grey20"), axis.title=element_text(size=25, color = "grey20"),
        axis.ticks = element_line(color = "grey60"), 
        text = element_text(family = fontFace),
        panel.background = element_rect(fill = "white", colour = "grey60"),
        panel.grid.major = element_line(colour = "grey60"),
        axis.title.y.left  = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
        axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 20))) +
  scale_x_continuous(name="Number of Unique Lotteries Faced",  labels=c("0", "5","10","15"), breaks = c(0,5,10,15)) 

ggsave(path = saveDir, "Figure4(b).png",height = 5, width = 8)  


# Figures 5 and B3 ----

## Create Variables ----

datapan <- pdata.frame(data, index=c("userid","eventCount"))
datapan$LcSpend = lag(data$cSpending,1)
z <- datapan$cSpending
y <- lag(z,1)
datapan$LagcSpending = y
datapan$SpendEvent = datapan$cSpending!=datapan$LagcSpending
datapan$SpendEvent[is.na(datapan$SpendEvent)] <- FALSE

## Figure Main Text ----

dataSel = datapan #[which(datapan$lotTotal <= 50),]
meanValuesSpendEvent <- dataSel %>%
  group_by(eventCount) %>%
  dplyr::summarise(mean_SE= mean(SpendEvent), count = dplyr::n())
meanValuesSpendEvent$eventCount <- as.numeric(meanValuesSpendEvent$eventCount)

ggplot(data = meanValuesSpendEvent, aes(x=eventCount, y=mean_SE)) + geom_bar(stat="identity", color = cbp2[1], fill =cbp1[1]) +
  scale_y_continuous(name = "Share with purchase", limits = c(0,.4),labels = c("0.0","0.1","0.2","0.3","0.4"),
                     breaks = c(0,.1,.2,.3,.4),) + xlim(-0.1,50.1) + xlab(label ="Lottery Faced") +
  theme(axis.text=element_text(size=25, color = "grey20"), axis.title=element_text(size=25, color = "grey20"),
        axis.ticks = element_line(color = "grey60"), 
        text = element_text(family = fontFace),
        panel.background = element_rect(fill = "white", colour = "grey60"),
        panel.grid.major = element_line(colour = "grey60"),
        axis.title.y.left  = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
        axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 20)))

ggsave(path = saveDir, "Figure5.png",height = 4, width = 16)    

## Figures Appendix ----

dataSel = datapan[which(datapan$lotTotal <= 10 & datapan$lotTotal > 5),]
meanValuesSpendEvent <- dataSel %>%
  group_by(eventCount) %>%
  dplyr::summarise(mean_SE= mean(SpendEvent), count = dplyr::n())
meanValuesSpendEvent$eventCount <- as.numeric(meanValuesSpendEvent$eventCount)

ggplot(data = meanValuesSpendEvent, aes(x=eventCount, y=mean_SE)) + geom_bar(stat="identity", color = cbp2[1], fill =cbp1[1]) +
  scale_y_continuous(name = "Share with purchase", limits = c(0,.4),labels = c("0.0","0.1","0.2","0.3","0.4"),
                     breaks = c(0,.1,.2,.3,.4),) + xlim(-0.1,50.1) + xlab(label ="Lottery Faced") +
  theme(axis.text=element_text(size=25, color = "grey20"), axis.title=element_text(size=25, color = "grey20"),
        axis.ticks = element_line(color = "grey60"), 
        text = element_text(family = fontFace),
        panel.background = element_rect(fill = "white", colour = "grey60"),
        panel.grid.major = element_line(colour = "grey60"),
        axis.title.y.left  = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
        axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 20)))

ggsave(path = saveDir, "FigureB3(a).png",height = 4, width = 16)    


dataSel = datapan[which(datapan$lotTotal <= 20 & datapan$lotTotal > 10),]
meanValuesSpendEvent <- dataSel %>%
  group_by(eventCount) %>%
  dplyr::summarise(mean_SE= mean(SpendEvent), count = dplyr::n())
meanValuesSpendEvent$eventCount <- as.numeric(meanValuesSpendEvent$eventCount)

ggplot(data = meanValuesSpendEvent, aes(x=eventCount, y=mean_SE)) + geom_bar(stat="identity", color = cbp2[1], fill =cbp1[1]) +
  scale_y_continuous(name = "Share with purchase", limits = c(0,.4),labels = c("0.0","0.1","0.2","0.3","0.4"),
                     breaks = c(0,.1,.2,.3,.4),) + xlim(-0.1,50.1) + xlab(label ="Lottery Faced") +
  theme(axis.text=element_text(size=25, color = "grey20"), axis.title=element_text(size=25, color = "grey20"),
        axis.ticks = element_line(color = "grey60"), 
        text = element_text(family = fontFace),
        panel.background = element_rect(fill = "white", colour = "grey60"),
        panel.grid.major = element_line(colour = "grey60"),
        axis.title.y.left  = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
        axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 20)))

ggsave(path = saveDir, "FigureB3(b).png",height = 4, width = 16)    


dataSel = datapan[which(datapan$lotTotal <= 30 & datapan$lotTotal > 20),]
meanValuesSpendEvent <- dataSel %>%
  group_by(eventCount) %>%
  dplyr::summarise(mean_SE= mean(SpendEvent), count = dplyr::n())
meanValuesSpendEvent$eventCount <- as.numeric(meanValuesSpendEvent$eventCount)

ggplot(data = meanValuesSpendEvent, aes(x=eventCount, y=mean_SE)) + geom_bar(stat="identity", color = cbp2[1], fill =cbp1[1]) +
  scale_y_continuous(name = "Share with purchase", limits = c(0,.4),labels = c("0.0","0.1","0.2","0.3","0.4"),
                     breaks = c(0,.1,.2,.3,.4),) + xlim(-0.1,50.1) + xlab(label ="Lottery Faced") +
  theme(axis.text=element_text(size=25, color = "grey20"), axis.title=element_text(size=25, color = "grey20"),
        axis.ticks = element_line(color = "grey60"), 
        text = element_text(family = fontFace),
        panel.background = element_rect(fill = "white", colour = "grey60"),
        panel.grid.major = element_line(colour = "grey60"),
        axis.title.y.left  = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
        axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 20)))

ggsave(path = saveDir, "FigureB3(c).png",height = 4, width = 16)    


dataSel = datapan[which(datapan$lotTotal <= 40 & datapan$lotTotal > 30),]
meanValuesSpendEvent <- dataSel %>%
  group_by(eventCount) %>%
  dplyr::summarise(mean_SE= mean(SpendEvent), count = dplyr::n())
meanValuesSpendEvent$eventCount <- as.numeric(meanValuesSpendEvent$eventCount)

ggplot(data = meanValuesSpendEvent, aes(x=eventCount, y=mean_SE)) + geom_bar(stat="identity", color = cbp2[1], fill =cbp1[1]) +
  scale_y_continuous(name = "Share with purchase", limits = c(0,.4),labels = c("0.0","0.1","0.2","0.3","0.4"),
                     breaks = c(0,.1,.2,.3,.4),) + xlim(-0.1,50.1) + xlab(label ="Lottery Faced") +
  theme(axis.text=element_text(size=25, color = "grey20"), axis.title=element_text(size=25, color = "grey20"),
        axis.ticks = element_line(color = "grey60"), 
        text = element_text(family = fontFace),
        panel.background = element_rect(fill = "white", colour = "grey60"),
        panel.grid.major = element_line(colour = "grey60"),
        axis.title.y.left  = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
        axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 20)))

ggsave(path = saveDir, "FigureB3(d).png",height = 4, width = 16)    


dataSel = datapan[which(datapan$lotTotal <= 50 & datapan$lotTotal > 40),]
meanValuesSpendEvent <- dataSel %>%
  group_by(eventCount) %>%
  dplyr::summarise(mean_SE= mean(SpendEvent), count = dplyr::n())
meanValuesSpendEvent$eventCount <- as.numeric(meanValuesSpendEvent$eventCount)

ggplot(data = meanValuesSpendEvent, aes(x=eventCount, y=mean_SE)) + geom_bar(stat="identity", color = cbp2[1], fill =cbp1[1]) +
  scale_y_continuous(name = "Share with purchase", limits = c(0,.4),labels = c("0.0","0.1","0.2","0.3","0.4"),
                     breaks = c(0,.1,.2,.3,.4),) + xlim(-0.1,50.1) + xlab(label ="Lottery Faced") +
  theme(axis.text=element_text(size=25, color = "grey20"), axis.title=element_text(size=25, color = "grey20"),
        axis.ticks = element_line(color = "grey60"), 
        text = element_text(family = fontFace),
        panel.background = element_rect(fill = "white", colour = "grey60"),
        panel.grid.major = element_line(colour = "grey60"),
        axis.title.y.left  = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
        axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 20)))

ggsave(path = saveDir, "FigureB3(e).png",height = 4, width = 16) 


# Figure 6(a) ----

## Preliminaries ----

##### Group by decision time

data$dtGrp <- floor(data$decisionTime*2)/2

##### cap the group variable
data$dtGrp[data$dtGrp >= 10.0] <- 10.0

##### calculate mean propensity for safe choices
meanValuesDecTime <- data[which(data$dtGrp <= 10.0 & data$goldBefore <= 6000),] %>%
  group_by(dtGrp) %>%
  dplyr::summarise(mean_SafeChoice= mean(safeChoice), count = n())

##### coefficient to scale the secondary axis
coeff <- 3000

## Figure ----
ggplot() + 
  geom_histogram(aes((x=dtGrp)),data = data[which(data$dtGrp <= 10.0 & data$goldBefore <= 6000),], 
                 binwidth=.5, alpha=1, position = 'identity', color = cbp2[1], fill =cbp1[1]) + 
  geom_point(aes(x=dtGrp, y = mean_SafeChoice * coeff), 
             data = meanValuesDecTime,  color = cbp2[1], size = 3.5)+
  geom_line(aes(x=dtGrp, y = mean_SafeChoice * coeff), 
            data = meanValuesDecTime, color =cbp2[1], size = 1.25)+
  scale_y_continuous(
    # Features of the first axis
    name = "Count (in 1000s)", limits = c(0,3000),labels = c("0.0","0.6","1.2","1.8","2.4","3.0"),breaks = c(0,600,1200,1800,2400,3000),
    # Add a second axis and specify its features
    sec.axis = sec_axis(~./coeff, name="Average Probability Safe Choice", breaks = c(0,0.2,0.4,0.6,0.8,1))
  ) +
  xlim(-0.25,10.55) + xlab(label ="Decision Time") +
  theme(axis.text=element_text(size=35, color = "grey20"), axis.title=element_text(size=35, color = "grey20"),
        axis.ticks = element_line(color = "grey60"), 
        text = element_text(family = fontFace),
        panel.background = element_rect(fill = "white", colour = "grey60"),
        panel.grid.major = element_line(colour = "grey60"),
        axis.title.y.left  = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
        axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 20)))+
  scale_x_continuous(name="Decision Time",  labels=c("0", "2.5","5.0","7.5","\u2265 10.0"), breaks = c(0,2.5,5,7.5,10.0)) 

### save
ggsave(path = saveDir, "Figure6(a).png", width = 12,height = 8)


# Figure 6(b) ----

## Preliminaries ----

##### Create variables

data$cRiskyChoice <- ave(data$pickedRisky, data$userid, FUN = cumsum)
last_row <- -nrow(data)
excl_last_row <- (data$cRiskyChoice[last_row])
data$lag.cRiskyChoice <- c(NA, excl_last_row)
data$lag.cRiskyChoice[which(!duplicated(data$userid))] <- NA

data$aux <- data$riskySuccess
data$aux[is.na(data$aux)] <- 0
data$cRiskySuccess <- ave(data$aux, data$userid, FUN = cumsum)
last_row <- -nrow(data)
excl_last_row <- (data$cRiskySuccess[last_row])
data$lag.cRiskySuccess <- c(NA, excl_last_row)
data$lag.cRiskySuccess[which(!duplicated(data$userid))] <- NA

data$riskyExpect <- data$lag.cRiskySuccess/data$lag.cRiskyChoice
data$riskyExpect[is.na(data$riskyExpect)] <- 0.5

data$expectGrp <- round(data$riskyExpect*10)/10

### calculate mean propensity for safe choices
meanValuesDecTime <- data[which(data$goldBefore <= 6000),] %>%
  group_by(expectGrp) %>%
  dplyr::summarise(mean_SafeChoice= mean(safeChoice), count = n())

### coefficient to scale the secondary axis
coeff <- 7000

## Figure ----

ggplot() + 
  geom_histogram(aes((x=expectGrp)),data = data[which(data$goldBefore <= 6000),], 
                 binwidth=.1, alpha=1, position = 'identity', color = cbp2[1], fill =cbp1[1]) + 
  geom_point(aes(x=expectGrp, y = mean_SafeChoice * coeff), 
             data = meanValuesDecTime,  color = cbp2[1], size = 3.5)+
  geom_line(aes(x=expectGrp, y = mean_SafeChoice * coeff), 
            data = meanValuesDecTime, color =cbp2[1], size = 1.25)+
  scale_y_continuous(
    # Features of the first axis
    name = "Count (in 1000s)", limits = c(0,7000),labels = c("0.0","1.4","2.8","4.2","5.6","7.0"),breaks = c(0,1400,2800,4200,5600,7000),
    # Add a second axis and specify its features
    sec.axis = sec_axis(~./coeff, name="Average Probability Safe Choice", breaks = c(0,0.2,0.4,0.6,0.8,1))
  )  + xlab(label ="Lottery Expectations") +
  theme(axis.text=element_text(size=35, color = "grey20"), axis.title=element_text(size=35, color = "grey20"),
        axis.ticks = element_line(color = "grey60"),
        text = element_text(family = fontFace),
        panel.background = element_rect(fill = "white", colour = "grey60"),
        panel.grid.major = element_line(colour = "grey60"),
        axis.title.y.left  = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
        axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 20)))+
  scale_x_continuous(name="Lottery Expectations",  labels=c("0.0", "0.2","0.4","0.6","0.8","1.0"), breaks = c(0,0.2,0.4,0.6,0.8,1)) 

ggsave(path = saveDir, "Figure6(b).png", width = 12,height = 8)


# Figure 7 ----

## Preliminaries ----

detach("package:plyr", unload=TRUE)

### we create a new wealth variable and round it in bins of 250
data$wealth <- NA
data$wealth <- round(data$goldBefore/250)*250

### we create two subsets to easily iterate over them
absolute  <- data[which(data$lotType == "Absolute Lotteries" & data$wealth <= 6000 & data$decisionTime >= 3.5),]
relative  <- data[which(data$lotType == "Relative Lotteries" & data$wealth <= 6000 & data$decisionTime >= 3.5),]

### save them in a list to iterate over them
sets <- list(absolute,relative)

## Figures ----

for(i in 1:length(sets)){
  
  ### get the mean values
  meanValues <- sets[[i]] %>%
    group_by(wealth, lotType) %>%
    summarise(mean_SafeChoice= mean(safeChoice), count = n())
  
  
  ### scaling coefficient for the secondary axis
  coeff = 6000
  
  ### create the actual plot
  ggplot() + 
    geom_histogram(aes((x=wealth)),data =sets[[i]], 
                   binwidth=250, alpha=1.0, position = 'dodge', color = cbp2[1], fill =cbp1[1]) + 
    
    stat_smooth(geom = "smooth", method= "lm",aes(ymin = ifelse(..ymin.. < 0, 0, ..ymin..), x=wealth, y = mean_SafeChoice * coeff, weight = count), 
                data = meanValues,fill= cbp2[1], alpha = .25) +
    
    geom_point(aes(x=wealth, y = mean_SafeChoice * coeff), 
               data = meanValues, color =cbp2[1], size = 3)  +
    
    geom_smooth(aes(x=wealth, y = mean_SafeChoice * coeff, weight = count), 
                data = meanValues, color = cbp2[1], fill= cbp2[1], size = 1.25, alpha =0.25,
                method = lm, se = FALSE)  + 
    
    scale_y_continuous(
      # Features of the first axis
      name = "Count (in 1000s)", limits = c(0,3000),labels = c("0.0","0.6","1.2","1.8","2.4","3.0"),breaks = c(0,600,1200,1800,2400,3000),
      # Add a second axis and specify its features
      # sec.axis = sec_axis(~./(coeff), name="Average Probability Safe Choice", breaks = c(0,0.2,0.4,0.6,0.8,1))
      sec.axis = sec_axis(~./(coeff), name="Average Probability Safe Choice", breaks = c(0,0.1,0.2,0.3,0.4,0.5))
    ) + 
    xlim(-250,6250) +
    theme(axis.text=element_text(size=35, color = "grey20"), axis.title=element_text(size=35, color = "grey20"),
          axis.ticks = element_line(color = "grey60"),
          text = element_text(family = fontFace),
          panel.background = element_rect(fill = "white", colour = "grey60"),
          panel.grid.major = element_line(colour = "grey60"),
          axis.title.y.left  = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
          axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 20)))+
    scale_x_continuous(name ="Wealth", labels = c("0","2,000","4,000","6,000"))
  
  ### save
  #if(i == 1) ggsave(path = saveDir,"Hist_Wealth_Absolute.png")
  #else ggsave(path = saveDir,"Hist_Wealth_Relative.png")
  
  if(i == 1) ggsave(path = saveDir,"Figure7(a).png", width = 12,height = 8)
   else ggsave(path = saveDir,"Figure7(b).png", width = 12,height = 8)
}


# Figures B4 and B5 ----

## Preliminaries ----

detach("package:plyr", unload=TRUE)

### we create a new wealth variable and round it in bins of 250
data$wealth <- NA
data$wealth <- round(data$goldBefore/250)*250

cutoffs <- c(1000, 2000, 3000, 4000, 5000, 6000)
panels <- c("(a)","(b)","(c)","(d)","(e)","(f)")

## Figures ----

for(j in 1:length(cutoffs)){

  cut <- cutoffs[j]
  panel <- panels[j]
  
  ### we create two subsets to easily iterate over them
  absolute  <- data[which(data$lotType == "Absolute Lotteries" & data$wealth <= cut & data$decisionTime >= 3.5),]
  relative  <- data[which(data$lotType == "Relative Lotteries" & data$wealth <= cut & data$decisionTime >= 3.5),]
  
  ### save them in a list to iterate over them
  sets <- list(absolute,relative)
  
  
  for(i in 1:length(sets)){
    
    ### get the mean values
    meanValues <- sets[[i]] %>%
      group_by(wealth) %>%
      summarise(mean_SafeChoice= mean(safeChoice), count = n())
    
    
    ### scaling coefficient for the secondary axis
    coeff = 6000
    
    ### create the actual plot
    ggplot() + 
      geom_histogram(aes((x=wealth)),data =sets[[i]], 
                     binwidth=250, alpha=1.0, position = 'dodge', color = cbp2[1], fill =cbp1[1]) + 
      
      stat_smooth(geom = "smooth", method= "lm",aes(ymin = ifelse(..ymin.. < 0, 0, ..ymin..), x=wealth, y = mean_SafeChoice * coeff, weight = count), 
                  data = meanValues,fill= cbp2[1], alpha = .25) +
      
      geom_point(aes(x=wealth, y = mean_SafeChoice * coeff), 
                 data = meanValues, color =cbp2[1], size = 3)  +
      
      geom_smooth(aes(x=wealth, y = mean_SafeChoice * coeff, weight = count), 
                  data = meanValues, color = cbp2[1], fill= cbp2[1], size = 1.25, alpha =0.25,
                  method = lm, se = FALSE)  + 
      
      scale_y_continuous(
        # Features of the first axis
        name = "Count (in 1000s)", limits = c(0,3000),labels = c("0.0","0.6","1.2","1.8","2.4","3.0"),breaks = c(0,600,1200,1800,2400,3000),
        # Add a second axis and specify its features
        # sec.axis = sec_axis(~./(coeff), name="Average Probability Safe Choice", breaks = c(0,0.2,0.4,0.6,0.8,1))
        sec.axis = sec_axis(~./(coeff), name="Average Probability Safe Choice", breaks = c(0,0.1,0.2,0.3,0.4,0.5))
      ) + 
      #xlim(-250,8250) +
      theme(axis.text=element_text(size=35, color = "grey20"), axis.title=element_text(size=35, color = "grey20"),
            axis.ticks = element_line(color = "grey60"),
            text = element_text(family = fontFace),
            panel.background = element_rect(fill = "white", colour = "grey60"),
            panel.grid.major = element_line(colour = "grey60"),
            axis.title.y.left  = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
            axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 20)))+
      scale_x_continuous(name ="Wealth", labels = c("0","2,000","4,000","6,000"), limits = c(-250,6250))
    
    ### save
    #if(i == 1) ggsave(path = saveDir,"Hist_Wealth_Absolute.png")
    #else ggsave(path = saveDir,"Hist_Wealth_Relative.png")
    
    if(i == 1) ggsave(path = saveDir,paste("FigureB4",panel,".png",sep=""), width = 12,height = 8)
    else ggsave(path = saveDir,paste("FigureB5",panel,".png",sep=""), width = 12,height = 8)
  }
}

# Figures A1 and A2 ----

## Preliminaries ----

##### we create a new wealth variable and round it in bins of 250
data$wealth <- NA
data$wealth <- round(data$goldBefore/250)*250

##### we create two subsets to easily iterate over them
absolute  <- data[which(data$lotType == "Absolute Lotteries" & data$wealth <= 6000 & data$decisionTime >= 3.5),]
relative  <- data[which(data$lotType == "Relative Lotteries" & data$wealth <= 6000 & data$decisionTime >= 3.5),]

##### we revalue the age variable to make saving easier
library(plyr)
absolute$cAge <- revalue(absolute$cAge, c("> 45"="G45"))
relative$cAge <- revalue(relative$cAge, c("> 45"="G45"))

detach("package:plyr", unload=TRUE)

##### save them in a list to iterate over them
sets <- list(absolute,relative)

##### the variables we iterate over
vars <- c("sex","germany","cAge")

## Figures ----

### loop 1: absolute vs. relative
for(i in 1:length(sets)){
  j = 1
  # I don't know why R changes order here, but whatever
  if(i == 1) {
    panels <- c("(a)","(b)","(c)","(d)","(e)","(f)","(i)","(g)","(h)")
  } else {
    panels <- c("(a)","(b)","(c)","(e)","(d)","(f)","(i)","(g)","(h)")
  }
  
  ### loop 2: select the type of variable (age, sex, germany)
  for(v in 1:length(vars)){
    
    ### store the names of all outcomes
    factorNames <-  unique(sets[[i]][vars[v]])
    
    ### we calculate the mean values for the dots for the current variable
    dotValues <- sets[[i]] %>%
      group_by(wealth, lotType, sets[[i]][vars[v]]) %>%
      summarise(mean_SafeChoice= mean(safeChoice), count = n())
    
    ### loop 3: Here we iterate over all factor names and create the graphics
    for(z in 1:nrow(factorNames)){
      
      ### we create the histograms from this
      dataHist <- sets[[i]][which(sets[[i]][vars[v]] == as.character(factorNames[z,1])),]
      
      ### we create the dots from this
      dataDots = dotValues[which(dotValues[vars[v]] == as.character(factorNames[z,1])),]

      ### scaling coefficient
      coeff = 2500 #2500
      
      ### create the plot
      ggplot() + 
        geom_histogram(aes((x=wealth)),data = dataHist, 
                       binwidth=250, alpha=1.0, position = 'identity', color = cbp2[1], fill =cbp1[1]) +
        
        stat_smooth(geom = "smooth", method= "lm",aes(ymin = ifelse(..ymin.. < 0, 0, ..ymin..), x=wealth, y = mean_SafeChoice * coeff, weight = count), 
                    data = dataDots,fill= cbp2[1], alpha = .25)+
        
        geom_point(aes(x=wealth, y = mean_SafeChoice * coeff), 
                   data = dataDots, color =cbp2[1], size = 3)  +
        
        geom_smooth(aes(x=wealth, y = mean_SafeChoice * coeff, weight = count), 
                    data = dataDots, color = cbp2[1], fill= cbp2[1], size = 1.25, alpha =0.25,
                    method = lm, se = FALSE)  +
        scale_y_continuous(
          # Features of the first axis
          name = "Count (in 1000s)",limits = c(0,2500),labels = c("0.0","0.5","1.0","1.5","2.0","2.5"),
          # Add a second axis and specify its features
          sec.axis = sec_axis(~./coeff, name="Average Probability Safe Choice", breaks = c(0,0.2,0.4,0.6,0.8,1))
        ) + 
        theme(axis.text=element_text(size=30, color = "grey20"), axis.title=element_text(size=30, color = "grey20"),
              axis.ticks = element_line(color = "grey60"),
              text = element_text(family = fontFace),
              panel.background = element_rect(fill = "white", colour = "grey60"),
              panel.grid.major = element_line(colour = "grey60"),
              axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
              axis.title.y.right = element_text(margin = margin(t = 0, r = 0, b = 0, l = 20))) +
        scale_x_continuous(name ="Wealth", labels = c("0","2,000","4,000","6,000"), limits = c(-250,6250))
      
      ### save the plots
      ggsave(path = saveDir, filename = paste0(if(i == 1) "FigureA1"
                                               else "FigureA2",panels[j],".png"))
      j = j + 1
    }
  }
}

