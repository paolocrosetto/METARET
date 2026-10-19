# Preliminaries ----

## Packages ----

if(is.na(any(installed.packages() == "lfe"))){
  install.packages("lfe")}
library(lfe)

if(is.na(any(installed.packages() == "modelsummary"))){
  install.packages("modelsummary")}
library(modelsummary)

if(is.na(any(installed.packages() == "fixest"))){
  install.packages("fixest")}
library(fixest)

if(is.na(any(installed.packages() == "stargazer"))){
  install.packages("stargazer")}
library(stargazer)

if(is.na(any(installed.packages() == "plm"))){
  install.packages("plm")}
library(plm)

if(is.na(any(installed.packages() == "plyr"))){
  install.packages("plyr")}
library(plyr)

if(is.na(any(installed.packages() == "tidyverse"))){
  install.packages("tidyverse")}
library(tidyverse)

if(is.na(any(installed.packages() == "hrbrthemes"))){
  install.packages("hrbrthemes")}
library(hrbrthemes)

if(is.na(any(installed.packages() == "alpaca"))){
  install.packages("alpaca")}
library(alpaca)

if(is.na(any(installed.packages() == "sandwich"))){
  install.packages("sandwich")}
library(sandwich)

if(is.na(any(installed.packages() == "clubSandwich"))){
  install.packages("clubSandwich")}
library(clubSandwich)

if(is.na(any(installed.packages() == "boot"))){
  install.packages("boot")}
library(boot)

if(is.na(any(installed.packages() == "car"))){
  install.packages("car")}
library(car)

if(is.na(any(installed.packages() == "plotrix"))){
  install.packages("plotrix")}
library(plotrix)

## Directories ----

options(stringsAsFactors=FALSE)

dataDir <- "C:/Users/jaspersen/Desktop/RPW/Final/" 

saveDir <- "C:/Users/Jaspersen/Desktop/RPW/Final/Output" 

## Importing ----

data <- read.csv(file = paste0(dataDir,"data_anon.csv"), sep=",",header = TRUE)

# Construct some necessary variables ----

data$safeChoice <- 1-data$pickedRisky

data$wealth1000 <- data$goldBefore/1000

data$notGerman <- 1-data$germany

data$notMale <- ifelse(data$sex != "Male",1,0)

data$over25 <- ifelse(data$cAge != "16-25",1,0)

# Individual numbers reported in the text ----

data_temp <- data[which(data$goldBefore <= 6000),]
data_temp$run_max <- ave(data_temp$runCounter, data_temp$userid, FUN = max)
data_temp$lot_max <- ave(data_temp$lotCounter, data_temp$userid, FUN = max)
data_temp <- data_temp[which(data_temp$lotCounter == 1),]
data_temp$success <- data_temp$lot_max/data_temp$run_max
temp_list <- sapply(data_temp$success, mean)
in_p8_1 <- mean(temp_list) # Mean number of successfull runs (p8)
in_p8_2 <- median(temp_list) # Median number of successfull runs (p8)
data_temp <- data[which(data$goldBefore <= 6000 & data$decisionTime<2.5),]
in_p11_1 <- mean(data_temp$safeChoice) # share of safe choices with decision time < 2.5s
data_temp <- data[which(data$goldBefore <= 6000 & data$decisionTime>=2.5 & data$decisionTime<3) ,]
in_p11_2 <- mean(data_temp$safeChoice) # share of safe choices with 2.5s <= decision time < 3s
data_temp <- data[which(data$goldBefore <= 6000 & data$decisionTime>=3 & data$decisionTime<3.5) ,]
in_p11_3 <- mean(data_temp$safeChoice) # share of safe choices with 3s <= decision time < 3.5s
data_temp <- data[which(data$goldBefore <= 6000 & data$decisionTime>=3.5) ,]
in_p11_4 <- mean(data_temp$safeChoice) # share of safe choices with decision time >= 3.5s
in_p14_1 <- 0.034*0.952 # marginal effect of 1SD shift in wealth population 2SLS LPM, absolute treatment
# calculated as the coefficient in Table 3, column (1) multiplied by the SD in 1000s reported in Table 2
in_p14_2 <- 0.045*0.919 # marginal effect of 1SD shift in wealth population 2SLS LPM, relative treatment
# calculated as the coefficient in Table 3, column (3) multiplied by the SD in 1000s reported in Table 2
in_p17_1 <- 0.041*0.952 # marginal effect of 1SD shift in wealth individual 2SLS LPM, absolute treatment
# calculated as the coefficient in Table 4, column (1) multiplied by the SD in 1000s reported in Table 2
in_p17_2 <- 0.037*0.919 # marginal effect of 1SD shift in wealth individual 2SLS LPM, relative treatment
# calculated as the coefficient in Table 4, column (3) multiplied by the SD in 1000s reported in Table 2
data_temp <- data[which(data$lotType == "Absolute Lotteries"),]
sd_here = sd(data_temp$wealth1000)
in_p18_1 <- 0.029*sd_here # marginal effect of 1SD shift in wealth individual 2SLS LPM, absolute treatment
# calculated as the coefficient in Table 4, column (1) multiplied by the SD in 1000s reported in Table 2
data_temp <- data[which(data$lotType == "Relative Lotteries"),]
sd_here = sd(data_temp$wealth1000)
in_p18_2 <- 0.005*sd_here # marginal effect of 1SD shift in wealth individual 2SLS LPM, relative treatment
# calculated as the coefficient in Table 4, column (3) multiplied by the SD in 1000s reported in Table 2
data_temp <- data[which(data$goldBefore <= 6000),]
data_temp$dt_mean <- ave(data_temp$decisionTime, data_temp$userid, FUN = mean)
data_temp$wealth_mean <- ave(data_temp$wealth1000, data_temp$userid, FUN = mean)
data_temp <- data_temp[which(data_temp$lotCounter == 1),]
in_p18_3 <- cor(data_temp$dt_mean,data_temp$wealth_mean) # Correlation Wealth and Decision Time between subjects
data_temp <- data[which(data$goldBefore <= 6000),]
in_p18_4 <- cor(data_temp$decisionTime,data_temp$wealth1000) # Correlation Wealth and Decision Time within and between subjects


# Main Results (Sec. 4) ----

## TSLS Pooled Linear Probability ----

### Construct Variables ----

#data$lagWealth <- ave(data$wealth1000, data$userid, FUN = lag)
#data$lagWealth[is.na(data$lagWealth)] <- 0

last_row <- -nrow(data)
excl_last_row <- (data$wealth1000[last_row])
data$lagWealth <- c(NA, excl_last_row)
data$lagWealth[which(!duplicated(data$userid))] <- NA
data$lagWealth[is.na(data$lagWealth)] <- 0

data$NongerW1000 = data$notGerman * data$wealth1000
data$OldW1000 = data$over25 * data$wealth1000
data$NonmaleW1000 = data$notMale * data$wealth1000

data$NongerLW = data$notGerman * data$lagWealth
data$Gr25LW = data$over25 * data$lagWealth
data$NonmaleLW = data$notMale * data$lagWealth

data$dtThreshold <- ifelse(data$decisionTime < 3.5,1,0)

data$safeRight <- data$riskyLeft

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

### Estimations ----

sets <- list(data[which(data$lotType == "Absolute Lotteries" & data$goldBefore <= 6000),],
             data[which(data$lotType == "Relative Lotteries" & data$goldBefore <= 6000),],
             data[which(data$goldBefore <= 6000),])

fmlas <- c(as.formula("safeChoice ~ notMale + over25 + notGerman + dtThreshold + threshold + safeRight + riskyExpect | lotName | (wealth1000 ~ lagWealth) | userid"),
           as.formula("safeChoice ~ notMale + over25 + notGerman + dtThreshold + threshold + safeRight + riskyExpect | lotName | (wealth1000|NonmaleW1000|OldW1000|NongerW1000 ~ lagWealth+NonmaleLW+Gr25LW+NongerLW) | userid"))

TSLS_abs1 <- felm(formula = fmlas[[1]],data = sets[[1]])
TSLS_abs2 <- felm(formula = fmlas[[2]],data = sets[[1]])
TSLS_rel1 <- felm(formula = fmlas[[1]],data = sets[[2]])
TSLS_rel2 <- felm(formula = fmlas[[2]],data = sets[[2]])

### PostEst Statistics ----

numPlayers <- NULL
numPlayers <- c(format(length(unique(TSLS_abs1[["clustervar"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_abs2[["clustervar"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_rel1[["clustervar"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_rel2[["clustervar"]]$userid)),nsmall = 0, big.mark=","))

fstats <- NULL
fmla_fstat <- c(as.formula("wealth1000 ~ lagWealth + notMale + over25 + notGerman + dtThreshold + threshold + safeRight + riskyExpect | lotName | 0 | userid"))
aux <- felm(formula = fmla_fstat[[1]], data = sets[[1]])
fstats[1] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- felm(formula = fmla_fstat[[1]], data = sets[[2]])
fstats[3] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")

aux <- condfstat(TSLS_abs2,type="default",quantiles=NULL,bN=1000)
fstats[2] = format(aux[1], digits=4,nsmall = 0, big.mark=",")
aux <- condfstat(TSLS_rel2,type="default",quantiles=NULL,bN=1000)
fstats[4] = format(aux[1], digits=4,nsmall = 0, big.mark=",")

### Output Main Paper ----

covLabels <- c("Wealth (in 1000s)","Not Male $\\times$ Wealth (in 1000s)","Age $>$25 $\\times$ Wealth (in 1000s)", 
               "Not German $\\times$ Wealth (in 1000s)","Not Male", "Age $>$25", "Not German", "Dec.Time $<$3.5s","Threshold","Safe on Right","Lottery Expectations")
order_ <- c(8,9,10,11,1,2,3,4,5,6,7)

tab <- stargazer(TSLS_abs1,TSLS_abs2,TSLS_rel1,TSLS_rel2, title ="Regression Results", 
                 column.labels = c("Absolute Treatment", "Relative Treatment"), column.separate = c(2,2),
                 add.lines = list(c("Control variables","YES","YES","YES","YES"),
                                  c("Individual fixed effects","NO","NO","NO","NO"),
                                  c("Lottery fixed effects","YES","YES","YES","YES"),
                                  c("Clustered st. err.","YES","YES","YES","YES"),
                                  c("Number of players", numPlayers[1],numPlayers[2],numPlayers[3],numPlayers[4]),
                                  c("1st Stage F-statistic on Wealth", fstats[1], fstats[2], fstats[3], fstats[4])),
                 order= order_,
                 covariate.labels = covLabels,
                 summary = FALSE, align = FALSE, no.space = TRUE,  keep.stat = c("adj.rsq","n"), single.row = FALSE, multicolumn = TRUE, 
                 model.names = FALSE, dep.var.caption="Dependent variable: safe choice", dep.var.labels.include = FALSE, type="latex", 
                 omit = c("lotName"))
#omit = c("notMale","over25","notGerman","dtThreshold" ,"threshold","safeRight","riskyExpect","lotName")

write.table(tab[15:(length(tab)-5)], file = paste0(saveDir,"/Table3.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)


## TSLS Panel Linear Probability ----

### Estimations ----

sets <- list(data[which(data$lotType == "Absolute Lotteries" & data$goldBefore <= 6000),],
             data[which(data$lotType == "Relative Lotteries" & data$goldBefore <= 6000),],
             data[which(data$goldBefore <= 6000),])

fmlas <- c(as.formula("safeChoice ~ dtThreshold + threshold + safeRight + riskyExpect | userid + lotName | (wealth1000 ~ lagWealth) | userid"),
           as.formula("safeChoice ~ dtThreshold + threshold + safeRight + riskyExpect | userid + lotName | (wealth1000|NonmaleW1000|OldW1000|NongerW1000 ~ lagWealth+NonmaleLW+Gr25LW+NongerLW) | userid"))

TSLS_abs1 <- felm(formula = fmlas[[1]],data = sets[[1]])
TSLS_abs2 <- felm(formula = fmlas[[2]],data = sets[[1]])
TSLS_rel1 <- felm(formula = fmlas[[1]],data = sets[[2]])
TSLS_rel2 <- felm(formula = fmlas[[2]],data = sets[[2]])

### PostEst Statistics ----

numPlayers <- NULL
numPlayers <- c(format(length(unique(TSLS_abs1[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_abs2[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_rel1[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_rel2[["fe"]]$userid)),nsmall = 0, big.mark=","))

fstats <- NULL
fmla_fstat <- c(as.formula("wealth1000 ~ lagWealth + dtThreshold + threshold + safeRight + riskyExpect | userid + lotName | 0 | userid"))
aux <- felm(formula = fmla_fstat[[1]], data = sets[[1]])
fstats[1] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- felm(formula = fmla_fstat[[1]], data = sets[[2]])
fstats[3] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")

aux <- condfstat(TSLS_abs2,type="default",quantiles=NULL,bN=1000)
fstats[2] = format(aux[1], digits=4,nsmall = 0, big.mark=",")
aux <- condfstat(TSLS_rel2,type="default",quantiles=NULL,bN=1000)
fstats[4] = format(aux[1], digits=4,nsmall = 0, big.mark=",")

### Output Main Paper ----

covLabels <- c("Wealth (in 1000s)","Not Male $\\times$ Wealth (in 1000s)","Age $>$25 $\\times$ Wealth (in 1000s)", 
               "Not German $\\times$ Wealth (in 1000s)")
order_ <- c(5,6,7,8)

tab <- stargazer(TSLS_abs1,TSLS_abs2,TSLS_rel1,TSLS_rel2, title ="Regression Results", 
                 column.labels = c("Absolute Treatment", "Relative Treatment"), column.separate = c(2,2),
                 add.lines = list(c("Control variables","YES","YES","YES","YES"),
                                  c("Individual fixed effects","YES","YES","YES","YES"),
                                  c("Lottery fixed effects","YES","YES","YES","YES"),
                                  c("Clustered st. err.","YES","YES","YES","YES"),
                                  c("Number of players", numPlayers[1],numPlayers[2],numPlayers[3],numPlayers[4]),
                                  c("1st Stage F-statistic on Wealth", fstats[1], fstats[2], fstats[3], fstats[4])),
                 order= order_,
                 covariate.labels = covLabels,
                 summary = FALSE, align = FALSE, no.space = TRUE,  keep.stat = c("adj.rsq","n"), single.row = FALSE, multicolumn = TRUE, 
                 model.names = FALSE, dep.var.caption="Dependent variable: safe choice", dep.var.labels.include = FALSE, type="latex", 
                 omit = c("dtThreshold" ,"threshold","safeRight","riskyExpect","lotName"))


write.table(tab[15:(length(tab)-5)], file = paste0(saveDir,"/Table4.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)

### Output Appendix ----

covLabels <- c("Wealth (in 1000s)","Not Male $\\times$ Wealth (in 1000s)","Age $>$25 $\\times$ Wealth (in 1000s)", 
               "Not German $\\times$ Wealth (in 1000s)","Dec.Time $<$3.5s","Threshold","Safe on Right","Lottery Expectations")
order_ <- c(5,6,7,8,1,2,3,4)

tab <- stargazer(TSLS_abs1,TSLS_abs2,TSLS_rel1,TSLS_rel2, title ="Regression Results", 
                 column.labels = c("Absolute Treatment", "Relative Treatment"), column.separate = c(2,2),
                 add.lines = list(c("Control variables","YES","YES","YES","YES"),
                                  c("Individual fixed effects","YES","YES","YES","YES"),
                                  c("Lottery fixed effects","YES","YES","YES","YES"),
                                  c("Clustered st. err.","YES","YES","YES","YES"),
                                  c("Number of players", numPlayers[1],numPlayers[2],numPlayers[3],numPlayers[4]),
                                  c("1st Stage F-statistic on Wealth", fstats[1], fstats[2], fstats[3], fstats[4])),
                 order= order_,
                 covariate.labels = covLabels,
                 summary = FALSE, align = FALSE, no.space = TRUE,  keep.stat = c("adj.rsq","n"), single.row = FALSE, multicolumn = TRUE, 
                 model.names = FALSE, dep.var.caption="Dependent variable: safe choice", dep.var.labels.include = FALSE, type="latex", 
                 omit = c("lotName"))


write.table(tab[15:(length(tab)-5)], file = paste0(saveDir,"/TableC1.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)

# Robustness (sec. 5) ----

## Alternative Specifications ----

### Construct Variables

data$altWealth <- data$goldBefore + data$cSpending
data$altWealth1000 <- data$altWealth/1000
data$decisionTimeSq <- data$decisionTime * data$decisionTime

### Pooled LagIV ----

#### Estimations ----

sets <- list(data[which(data$lotType == "Absolute Lotteries" & data$goldBefore <= 6000),],
             data[which(data$lotType == "Relative Lotteries" & data$goldBefore <= 6000),],
             data[which(data$lotType == "Absolute Lotteries"),],
             data[which(data$lotType == "Relative Lotteries"),])

fmlas <- c(as.formula("safeChoice ~ notMale + over25 + notGerman + dtThreshold + threshold + safeRight + riskyExpect | lotName | (wealth1000 ~ lagWealth) | userid"),
           as.formula("safeChoice ~ notMale + over25 + notGerman + decisionTime + decisionTimeSq + threshold + safeRight + riskyExpect | lotName | (wealth1000 ~ lagWealth) | userid"),
           as.formula("safeChoice ~ notMale + over25 + notGerman + dtThreshold + threshold + safeRight + riskyExpect | lotName | (altWealth1000 ~ lagWealth) | userid"))

TSLS_abs1 <- felm(formula = fmlas[[1]],data = sets[[3]])
TSLS_abs2 <- felm(formula = fmlas[[2]],data = sets[[1]])
TSLS_abs3 <- felm(formula = fmlas[[3]],data = sets[[1]])
TSLS_rel1 <- felm(formula = fmlas[[1]],data = sets[[4]])
TSLS_rel2 <- felm(formula = fmlas[[2]],data = sets[[2]])
TSLS_rel3 <- felm(formula = fmlas[[3]],data = sets[[2]])

#### PostEst Statistics ----

numPlayers <- NULL
numPlayers <- c(format(length(unique(TSLS_abs1[["clustervar"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_abs2[["clustervar"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_abs3[["clustervar"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_rel1[["clustervar"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_rel2[["clustervar"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_rel3[["clustervar"]]$userid)),nsmall = 0, big.mark=","))

fstats <- NULL
fmla_fstat <- c(as.formula("wealth1000 ~ lagWealth + notMale + over25 + notGerman + dtThreshold + threshold + safeRight + riskyExpect | lotName | 0 | userid"),
                as.formula("wealth1000 ~ lagWealth + notMale + over25 + notGerman + decisionTime + decisionTimeSq + threshold + safeRight + riskyExpect | lotName | 0 | userid"),
                as.formula("altWealth1000 ~ lagWealth + notMale + over25 + notGerman + dtThreshold + threshold + safeRight + riskyExpect | lotName | 0 | userid"))
aux <- felm(formula = fmla_fstat[[1]], data = sets[[3]])
fstats[1] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- felm(formula = fmla_fstat[[2]], data = sets[[1]])
fstats[2] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- felm(formula = fmla_fstat[[3]], data = sets[[1]])
fstats[3] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- felm(formula = fmla_fstat[[1]], data = sets[[4]])
fstats[4] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- felm(formula = fmla_fstat[[2]], data = sets[[2]])
fstats[5] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- felm(formula = fmla_fstat[[3]], data = sets[[2]])
fstats[6] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")

#### Output Main Paper ----

covLabels <- c("Wealth (in 1000s)", "Altern.\ Wealth (in 1000s)")

tab <- stargazer(TSLS_abs1,TSLS_abs2,TSLS_abs3,TSLS_rel1,TSLS_rel2,TSLS_rel3, title ="Regression Results", 
                 column.labels = c("Absolute Treatment", "Relative Treatment"), column.separate = c(3,3),
                 add.lines = list(c("Control Variables","YES","YES","YES","YES","YES","YES"),
                                  c("Lottery fixed effects","YES","YES","YES","YES","YES","YES"),
                                  c("Clustered st. err.","YES","YES","YES","YES","YES","YES"),
                                  c("Number of players", numPlayers[1],numPlayers[2],numPlayers[3],numPlayers[4],numPlayers[5],numPlayers[6])),
                 covariate.labels = covLabels,
                 summary = FALSE, align = FALSE, no.space = TRUE,  keep.stat = c("n"), single.row = FALSE, multicolumn = TRUE, 
                 model.names = FALSE, dep.var.caption="Dependent variable: safe choice", dep.var.labels.include = FALSE, type="latex", 
                 omit = c("notMale", "over25", "notGerman", "decisionTime", "decisionTimeSq", "dtThreshold" ,"threshold","safeRight","riskyExpect","lotName"))

write.table(tab[15:(length(tab)-11)], file = paste0(saveDir,"/Table5_top_panel.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)

write.table(tab[20:(length(tab)-5)], file = paste0(saveDir,"/Table5_bottom_panel.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)

#### Output Appendix ----

covLabels <- c("Wealth (in 1000s)","Altern. Wealth (in 1000s)", "Not Male","Age $>$25","Not German",
               "Dec.Time $<$3.5s", "Decision Time", "(Decision Time)$^2$", "Threshold", "Safe on Right","Lottery Expectations")
order_ <- c(10,11,1,2,3,4,5,6,7,8,9)

tab <- stargazer(TSLS_abs1,TSLS_abs2,TSLS_abs3,TSLS_rel1,TSLS_rel2,TSLS_rel3, title ="Regression Results", 
                 column.labels = c("Absolute Treatment", "Relative Treatment"), column.separate = c(3,3),
                 add.lines = list(c("Individual fixed effects","NO","NO","NO","NO","NO","NO"),
                                  c("Lottery fixed effects","YES","YES","YES","YES","YES","YES"),
                                  c("Clustered st. err.","YES","YES","YES","YES","YES","YES"),
                                  c("Number of players", numPlayers[1],numPlayers[2],numPlayers[3],numPlayers[4],numPlayers[5],numPlayers[6]),
                                  c("1st Stage F-statistic on Wealth", fstats[1], fstats[2], fstats[3], fstats[4], fstats[5], fstats[6])),
                 covariate.labels = covLabels,
                 order= order_,
                 summary = FALSE, align = FALSE, no.space = TRUE,  keep.stat = c("adj.rsq","n"), single.row = FALSE, multicolumn = TRUE, 
                 model.names = FALSE, dep.var.caption="Dependent variable: safe choice", dep.var.labels.include = FALSE, type="latex", 
                 omit = c("lotName"))

write.table(tab[15:(length(tab)-5)], file = paste0(saveDir,"/TableC2.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)


### Panel LagIV ----

#### Estimations ----

sets <- list(data[which(data$lotType == "Absolute Lotteries" & data$goldBefore <= 6000),],
             data[which(data$lotType == "Relative Lotteries" & data$goldBefore <= 6000),],
             data[which(data$lotType == "Absolute Lotteries"),],
             data[which(data$lotType == "Relative Lotteries"),])

fmlas <- c(as.formula("safeChoice ~ dtThreshold + threshold + safeRight + riskyExpect | lotName + userid | (wealth1000 ~ lagWealth) | userid"),
           as.formula("safeChoice ~ decisionTime + decisionTimeSq + threshold + safeRight + riskyExpect | lotName + userid | (wealth1000 ~ lagWealth) | userid"),
           as.formula("safeChoice ~ dtThreshold + threshold + safeRight + riskyExpect | lotName + userid | (altWealth1000 ~ lagWealth) | userid"))

TSLS_abs1 <- felm(formula = fmlas[[1]],data = sets[[3]])
TSLS_abs2 <- felm(formula = fmlas[[2]],data = sets[[1]])
TSLS_abs3 <- felm(formula = fmlas[[3]],data = sets[[1]])
TSLS_rel1 <- felm(formula = fmlas[[1]],data = sets[[4]])
TSLS_rel2 <- felm(formula = fmlas[[2]],data = sets[[2]])
TSLS_rel3 <- felm(formula = fmlas[[3]],data = sets[[2]])

#### PostEst Statistics ----

numPlayers <- NULL
numPlayers <- c(format(length(unique(TSLS_abs1[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_abs2[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_abs3[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_rel1[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_rel2[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_rel3[["fe"]]$userid)),nsmall = 0, big.mark=","))

fstats <- NULL
fmla_fstat <- c(as.formula("wealth1000 ~ lagWealth + dtThreshold + threshold + safeRight + riskyExpect | lotName + userid | 0 | userid"),
                as.formula("wealth1000 ~ lagWealth + decisionTime + decisionTimeSq + threshold + safeRight + riskyExpect | lotName + userid | 0 | userid"),
                as.formula("altWealth1000 ~ lagWealth + dtThreshold + threshold + safeRight + riskyExpect | lotName + userid | 0 | userid"))
aux <- felm(formula = fmla_fstat[[1]], data = sets[[3]])
fstats[1] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- felm(formula = fmla_fstat[[2]], data = sets[[1]])
fstats[2] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- felm(formula = fmla_fstat[[3]], data = sets[[1]])
fstats[3] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- felm(formula = fmla_fstat[[1]], data = sets[[4]])
fstats[4] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- felm(formula = fmla_fstat[[2]], data = sets[[2]])
fstats[5] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- felm(formula = fmla_fstat[[3]], data = sets[[2]])
fstats[6] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")

#### Output Main Paper ----

covLabels <- c("Wealth (in 1000s)", "Altern.\ Wealth (in 1000s)")

tab <- stargazer(TSLS_abs1,TSLS_abs2,TSLS_abs3,TSLS_rel1,TSLS_rel2,TSLS_rel3, title ="Regression Results", 
                 column.labels = c("Absolute Treatment", "Relative Treatment"), column.separate = c(3,3),
                 add.lines = list(c("Individual fixed effects","NO","NO","NO","NO","NO","NO"),
                                  c("Lottery fixed effects","YES","YES","YES","YES","YES","YES"),
                                  c("Clustered st. err.","YES","YES","YES","YES","YES","YES"),
                                  c("Number of players", numPlayers[1],numPlayers[2],numPlayers[3],numPlayers[4],numPlayers[5],numPlayers[6]),
                                  c("1st Stage F-statistic on Wealth", fstats[1], fstats[2], fstats[3], fstats[4], fstats[5], fstats[6])),
                 covariate.labels = covLabels,
                 summary = FALSE, align = FALSE, no.space = TRUE,  keep.stat = c("adj.rsq","n"), single.row = FALSE, multicolumn = TRUE, 
                 model.names = FALSE, dep.var.caption="Dependent variable: safe choice", dep.var.labels.include = FALSE, type="latex", 
                 omit = c("decisionTime", "decisionTimeSq", "dtThreshold" ,"threshold","safeRight","riskyExpect"))

write.table(tab[15:(length(tab)-13)], file = paste0(saveDir,"/Table5_middle_panel.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)

#### Output Appendix ----

covLabels <- c("Wealth (in 1000s)","Altern. Wealth (in 1000s)", "Dec.Time $<$3.5s", 
               "Decision Time", "(Decision Time)$^2$", "Threshold", "Safe on Right","Lottery Expectations")
order_ <- c(7,8,1,2,3,4,5,6)

tab <- stargazer(TSLS_abs1,TSLS_abs2,TSLS_abs3,TSLS_rel1,TSLS_rel2,TSLS_rel3, title ="Regression Results", 
                 column.labels = c("Absolute Treatment", "Relative Treatment"), column.separate = c(3,3),
                 add.lines = list(c("Individual fixed effects","NO","NO","NO","NO","NO","NO"),
                                  c("Lottery fixed effects","YES","YES","YES","YES","YES","YES"),
                                  c("Clustered st. err.","YES","YES","YES","YES","YES","YES"),
                                  c("Number of players", numPlayers[1],numPlayers[2],numPlayers[3],numPlayers[4],numPlayers[5],numPlayers[6]),
                                  c("1st Stage F-statistic on Wealth", fstats[1], fstats[2], fstats[3], fstats[4], fstats[5], fstats[6])),
                 covariate.labels = covLabels,
                 order= order_,
                 summary = FALSE, align = FALSE, no.space = TRUE,  keep.stat = c("adj.rsq","n"), single.row = FALSE, multicolumn = TRUE, 
                 model.names = FALSE, dep.var.caption="Dependent variable: safe choice", dep.var.labels.include = FALSE, type="latex", 
                 omit = c("lotName"))

write.table(tab[15:(length(tab)-5)], file = paste0(saveDir,"/TableC3.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)


## Boredom ----

### Time trend analysis ----

#### Construct Variable

data$eventCountNum <- as.numeric(as.character(data$eventCount))

#### Estimation ----

sets <- list(data[which(data$lotType == "Absolute Lotteries" & data$goldBefore <= 6000),],
             data[which(data$lotType == "Relative Lotteries" & data$goldBefore <= 6000),],
             data[which(data$goldBefore <= 6000),])

fmlas <- c(as.formula("safeChoice ~ dtThreshold + threshold + safeRight + riskyExpect + eventCountNum | userid + lotName | (wealth1000 ~ lagWealth) | userid"),
           as.formula("safeChoice ~ dtThreshold + threshold + safeRight + riskyExpect + eventCountNum | userid + lotName | (wealth1000|NonmaleW1000|OldW1000|NongerW1000 ~ lagWealth+NonmaleLW+Gr25LW+NongerLW) | userid"))

TSLS_abs1 <- felm(formula = fmlas[[1]],data = sets[[1]])
TSLS_abs2 <- felm(formula = fmlas[[2]],data = sets[[1]])
TSLS_rel1 <- felm(formula = fmlas[[1]],data = sets[[2]])
TSLS_rel2 <- felm(formula = fmlas[[2]],data = sets[[2]])

#### PostEst Statistics ----

numPlayers <- NULL
numPlayers <- c(format(length(unique(TSLS_abs1[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_abs2[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_rel1[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_rel2[["fe"]]$userid)),nsmall = 0, big.mark=","))

fstats <- NULL
fmla_fstat <- c(as.formula("wealth1000 ~ lagWealth + dtThreshold + threshold + safeRight + riskyExpect + eventCountNum | userid + lotName | 0 | userid"))
aux <- felm(formula = fmla_fstat[[1]], data = sets[[1]])
fstats[1] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- felm(formula = fmla_fstat[[1]], data = sets[[2]])
fstats[3] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- condfstat(TSLS_abs2,type="default",quantiles=NULL,bN=1000)
fstats[2] = format(aux[1], digits=4,nsmall = 0, big.mark=",")
aux <- condfstat(TSLS_rel2,type="default",quantiles=NULL,bN=1000)
fstats[4] = format(aux[1], digits=4,nsmall = 0, big.mark=",")

#### Output Main Paper ----

covLabels <- c("Wealth (in 1000s)","Not Male $\\times$ Wealth (in 1000s)","Age $>$25 $\\times$ Wealth (in 1000s)", 
               "Not German $\\times$ Wealth (in 1000s)","Time Trend")

tab <- stargazer(TSLS_abs1,TSLS_abs2,TSLS_rel1,TSLS_rel2, title ="Regression Results", 
                 column.labels = c("Absolute Treatment", "Relative Treatment"), column.separate = c(2,2),
                 add.lines = list(c("Control variables","YES","YES","YES","YES"),
                                  c("Individual fixed effects","YES","YES","YES","YES"),
                                  c("Lottery fixed effects","YES","YES","YES","YES"),
                                  c("Clustered st. err.","YES","YES","YES","YES"),
                                  c("Number of players", numPlayers[1],numPlayers[2],numPlayers[3],numPlayers[4]),
                                  c("1st Stage F-statistic on Wealth", fstats[1], fstats[2], fstats[3], fstats[4])),
                 order= c(6,7,8,9,5),
                 covariate.labels = covLabels,
                 summary = FALSE, align = FALSE, no.space = TRUE,  keep.stat = c("adj.rsq","n"), single.row = FALSE, multicolumn = TRUE, 
                 model.names = FALSE, dep.var.caption="Dependent variable: safe choice", dep.var.labels.include = FALSE, type="latex", 
                 omit = c("dtThreshold" ,"threshold","safeRight","riskyExpect"))

write.table(tab[15:(length(tab)-5)], file = paste0(saveDir,"/Table6.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)

#### Output Appendix ----

covLabels <- c("Wealth (in 1000s)","Not Male $\\times$ Wealth (in 1000s)","Age $>$25 $\\times$ Wealth (in 1000s)", 
               "Not German $\\times$ Wealth (in 1000s)","Time Trend","Dec.Time $<$3.5s","Threshold", "Safe on Right","Lottery Expectations")

tab <- stargazer(TSLS_abs1,TSLS_abs2,TSLS_rel1,TSLS_rel2, title ="Regression Results", 
                 column.labels = c("Absolute Treatment", "Relative Treatment"), column.separate = c(2,2),
                 add.lines = list(c("Control variables","YES","YES","YES","YES"),
                                  c("Individual fixed effects","YES","YES","YES","YES"),
                                  c("Lottery fixed effects","YES","YES","YES","YES"),
                                  c("Clustered st. err.","YES","YES","YES","YES"),
                                  c("Number of players", numPlayers[1],numPlayers[2],numPlayers[3],numPlayers[4]),
                                  c("1st Stage F-statistic on Wealth", fstats[1], fstats[2], fstats[3], fstats[4])),
                 order= c(6,7,8,9,5,1,2,3,4),
                 covariate.labels = covLabels,
                 summary = FALSE, align = FALSE, no.space = TRUE,  keep.stat = c("adj.rsq","n"), single.row = FALSE, multicolumn = TRUE, 
                 model.names = FALSE, dep.var.caption="Dependent variable: safe choice", dep.var.labels.include = FALSE, type="latex")

write.table(tab[15:(length(tab)-5)], file = paste0(saveDir,"/TableC4.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)

### Remove first period ----

#### Estimation for table ----

sets <- list(data[which(data$lotType == "Absolute Lotteries" & data$goldBefore <= 6000 & data$eventCountNum >= 2),],
             data[which(data$lotType == "Relative Lotteries" & data$goldBefore <= 6000 & data$eventCountNum >= 2),])

fmlas <- c(as.formula("safeChoice ~ dtThreshold + threshold + safeRight + riskyExpect | userid + lotName | (wealth1000 ~ lagWealth) | userid"),
           as.formula("safeChoice ~ dtThreshold + threshold + safeRight + riskyExpect | userid + lotName | (wealth1000|NonmaleW1000|OldW1000|NongerW1000 ~ lagWealth+NonmaleLW+Gr25LW+NongerLW) | userid"))

TSLS_abs1 <- felm(formula = fmlas[[1]],data = sets[[1]])
TSLS_abs2 <- felm(formula = fmlas[[2]],data = sets[[1]])
TSLS_rel1 <- felm(formula = fmlas[[1]],data = sets[[2]])
TSLS_rel2 <- felm(formula = fmlas[[2]],data = sets[[2]])

#### PostEst Statistics ----

numPlayers <- NULL
numPlayers <- c(format(length(unique(TSLS_abs1[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_abs2[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_rel1[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(TSLS_rel2[["fe"]]$userid)),nsmall = 0, big.mark=","))

fstats <- NULL
fmla_fstat <- c(as.formula("wealth1000 ~ lagWealth + dtThreshold + threshold + safeRight + riskyExpect | userid + lotName | 0 | userid"))
aux <- felm(formula = fmla_fstat[[1]], data = sets[[1]])
fstats[1] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- felm(formula = fmla_fstat[[1]], data = sets[[2]])
fstats[3] = format((aux[["ctval"]][["lagWealth"]])^2,digits=4,nsmall = 0, big.mark=",")
aux <- condfstat(TSLS_abs2,type="default",quantiles=NULL,bN=1000)
fstats[2] = format(aux[1], digits=4,nsmall = 0, big.mark=",")
aux <- condfstat(TSLS_rel2,type="default",quantiles=NULL,bN=1000)
fstats[4] = format(aux[1], digits=4,nsmall = 0, big.mark=",")

#### Output Main Paper ----

covLabels <- c("Wealth (in 1000s)","Not Male $\\times$ Wealth (in 1000s)","Age $>$25 $\\times$ Wealth (in 1000s)", 
               "Not German $\\times$ Wealth (in 1000s)")

tab <- stargazer(TSLS_abs1,TSLS_abs2,TSLS_rel1,TSLS_rel2, title ="Regression Results", 
                 column.labels = c("Absolute Treatment", "Relative Treatment"), column.separate = c(2,2),
                 add.lines = list(c("Control variables","YES","YES","YES","YES"),
                                  c("Individual fixed effects","YES","YES","YES","YES"),
                                  c("Lottery fixed effects","YES","YES","YES","YES"),
                                  c("Clustered st. err.","YES","YES","YES","YES"),
                                  c("Number of players", numPlayers[1],numPlayers[2],numPlayers[3],numPlayers[4]),
                                  c("1st Stage F-statistic on Wealth", fstats[1], fstats[2], fstats[3], fstats[4])),
                 covariate.labels = covLabels,
                 summary = FALSE, align = FALSE, no.space = TRUE,  keep.stat = c("adj.rsq","n"), single.row = FALSE, multicolumn = TRUE, 
                 model.names = FALSE, dep.var.caption="Dependent variable: safe choice", dep.var.labels.include = FALSE, type="latex", 
                 omit = c("dtThreshold" ,"threshold","safeRight","riskyExpect"))

write.table(tab[15:(length(tab)-5)], file = paste0(saveDir,"/Table7.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)

#### Output Appendix ----

covLabels <- c("Wealth (in 1000s)","Not Male $\\times$ Wealth (in 1000s)","Age $>$25 $\\times$ Wealth (in 1000s)", 
               "Not German $\\times$ Wealth (in 1000s)","Dec.Time $<$3.5s","Threshold", "Safe on Right","Lottery Expectations")
order_ <- c(5,6,7,8,1,2,3,4) 

tab <- stargazer(TSLS_abs1,TSLS_abs2,TSLS_rel1,TSLS_rel2, title ="Regression Results", 
                 column.labels = c("Absolute Treatment", "Relative Treatment"), column.separate = c(2,2),
                 add.lines = list(c("Control variables","YES","YES","YES","YES"),
                                  c("Individual fixed effects","YES","YES","YES","YES"),
                                  c("Lottery fixed effects","YES","YES","YES","YES"),
                                  c("Clustered st. err.","YES","YES","YES","YES"),
                                  c("Number of players", numPlayers[1],numPlayers[2],numPlayers[3],numPlayers[4]),
                                  c("1st Stage F-statistic on Wealth", fstats[1], fstats[2], fstats[3], fstats[4])),
                 covariate.labels = covLabels,
                 order = order_,
                 summary = FALSE, align = FALSE, no.space = TRUE,  keep.stat = c("adj.rsq","n"), single.row = FALSE, multicolumn = TRUE, 
                 model.names = FALSE, dep.var.caption="Dependent variable: safe choice", dep.var.labels.include = FALSE, type="latex")

write.table(tab[15:(length(tab)-5)], file = paste0(saveDir,"/TableC5.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)



# Appendix ----

## Pool OLS LPM det. dems. ---- 

### Redefine variables ----

data$cAge <- factor(data$cAge, levels = c("16-25","26-35","36-45","> 45"),ordered=FALSE)
data$cAge <- relevel(data$cAge, ref = "16-25")

### Estimations ----

fmlas <- c(as.formula("safeChoice ~  wealth1000 + sex + cAge + notGerman + dtThreshold + threshold +  safeRight + riskyExpect | lotName | 0 | userid"),
           as.formula("safeChoice ~  wealth1000 + sex * wealth1000 + cAge * wealth1000 + notGerman * wealth1000 + dtThreshold + threshold +  safeRight + riskyExpect | lotName | 0 | userid"))

sets <- list(data[which(data$lotType == "Absolute Lotteries" & data$goldBefore <= 6000),],
             data[which(data$lotType == "Relative Lotteries" & data$goldBefore <= 6000),]) 

abs1 <- felm(formula = fmlas[[1]],data = sets[[1]])
abs2 <- felm(formula = fmlas[[2]],data = sets[[1]])
rel1 <- felm(formula = fmlas[[1]],data = sets[[2]])
rel2 <- felm(formula = fmlas[[2]],data = sets[[2]])

### PostEst Statistics ----

numPlayers <- c(format(length(unique(abs1[["clustervar"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(abs2[["clustervar"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(rel1[["clustervar"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(rel2[["clustervar"]]$userid)),nsmall = 0, big.mark=","))

### Output ----

order_ <- c("wealth1000","sex : wealth1000", "cAge : wealth1000","notGerman : wealth1000","sex","cAge","notGerman" ,"dtThreshold" ,"threshold","safeRight","riskyExpect","lotName")

covLabels <- c("Wealth (in 1000s)","Female $\\times$  Wealth (in 1000s)","Non-binary$\\times$  Wealth (in 1000s)","Age 26-35 $\\times$  Wealth (in 1000s)", 
               "Age 36-45 $\\times$  Wealth (in 1000s)","Age $>$45 $\\times$  Wealth (in 1000s)","Not German $\\times$  Wealth (in 1000s)", 
               "Female","Non-binary","Age 26-35","Age 36-45","Age $>$45","Dec.Time $<$3.5s","Not German", "Threshold", "Safe on Right","Lottery Expectations","Constant")

tab <- stargazer(abs1,abs2,rel1,rel2, title ="Regression Results", 
                 column.labels = c("Absolute Treatment", "Relative Treatment"), column.separate = c(2,2),
                 add.lines = list(c("Individual fixed effects","NO","NO","NO","NO"),
                                  c("Lottery fixed effects","YES","YES","YES","YES"),
                                  c("Clustered st. err.","YES","YES","YES","YES"),
                                  c("Number of players", numPlayers[1],numPlayers[2],numPlayers[3],numPlayers[4])),
                 order= order_,
                 covariate.labels = covLabels,
                 summary = FALSE, align = FALSE, no.space = TRUE,  keep.stat = c("adj.rsq","n"), single.row = FALSE, multicolumn = TRUE, 
                 model.names = FALSE, dep.var.caption="Dependent variable: safe choice", dep.var.labels.include = FALSE, type="latex")

write.table(tab[15:(length(tab)-5)], file = paste0(saveDir,"/TableA1.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)


## Panel OLS LPM det. dems. ----

### Estimations ----

fmlas <- c(as.formula("safeChoice ~ wealth1000 + dtThreshold + threshold + safeRight + riskyExpect | userid + lotName | 0 | userid"),
           as.formula("safeChoice ~ wealth1000 + sex : wealth1000 + cAge : wealth1000 + notGerman : wealth1000 + dtThreshold + threshold + safeRight + riskyExpect | userid + lotName | 0 | userid"))

sets <- list(data[which(data$lotType == "Absolute Lotteries" & data$goldBefore <= 6000) ,],
             data[which(data$lotType == "Relative Lotteries" & data$goldBefore <= 6000),]) 

abs1 <- felm(formula = fmlas[[1]],data = sets[[1]])
abs2 <- felm(formula = fmlas[[2]],data = sets[[1]])
rel1 <- felm(formula = fmlas[[1]],data = sets[[2]])
rel2 <- felm(formula = fmlas[[2]],data = sets[[2]])

### PosEst Statistics ----

numPlayers <- c(format(length(unique(abs1[["clustervar"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(abs2[["clustervar"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(rel1[["clustervar"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(rel2[["clustervar"]]$userid)),nsmall = 0, big.mark=","))

### Output ----

order_ <- c("wealth1000","sex : wealth1000", "cAge : wealth1000","notGerman : wealth1000","dtThreshold" ,"threshold","safeRight","riskyExpect","lotName")

covLabels <- c("Wealth (in 1000s)","Female $\\times$  Wealth (in 1000s)","Non-binary$\\times$  Wealth (in 1000s)","Age 26-35 $\\times$  Wealth (in 1000s)", 
               "Age 36-45 $\\times$  Wealth (in 1000s)","Age $>$45 $\\times$  Wealth (in 1000s)","Not German $\\times$  Wealth (in 1000s)", 
               "Dec.Time $<$3.5s", "Threshold", "Safe on Right","Lottery Expectations","Constant")

tab <- stargazer(abs1,abs2,rel1,rel2, title ="Regression Results", 
                 column.labels = c("Absolute Treatment", "Relative Treatment"), column.separate = c(2,2),
                 add.lines = list(c("Individual fixed effects","YES","YES","YES","YES"),
                                  c("Lottery fixed effects","YES","YES","YES","YES"),
                                  c("Clustered st. err.","YES","YES","YES","YES"),
                                  c("Number of players", numPlayers[1],numPlayers[2],numPlayers[3],numPlayers[4])),
                 order= order_,
                 covariate.labels = covLabels,
                 summary = FALSE, align = FALSE, no.space = TRUE,  keep.stat = c("adj.rsq","n"), single.row = FALSE, multicolumn = TRUE, 
                 model.names = FALSE, dep.var.caption="Dependent variable: safe choice", dep.var.labels.include = FALSE, type="latex")

write.table(tab[15:(length(tab)-5)], file = paste0(saveDir,"/TableA2.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)

## Without first three periods ----

### Estimations ----
fmlas <- c(as.formula("safeChoice ~ wealth1000 + dtThreshold + threshold + safeRight + riskyExpect | userid + lotName | 0 | userid"),
           as.formula("safeChoice ~ altWealth1000 + dtThreshold + threshold + safeRight + riskyExpect | userid + lotName | 0 | userid"))

sets <- list(data[which(data$lotType == "Absolute Lotteries" & data$goldBefore <= 6000 & data$eventCountNum > 3),],
             data[which(data$lotType == "Relative Lotteries" & data$goldBefore <= 6000 & data$eventCountNum > 3),]) 

abs1 <- felm(formula = fmlas[[1]],data = sets[[1]])
abs2 <- felm(formula = fmlas[[2]],data = sets[[1]])
rel1 <- felm(formula = fmlas[[1]],data = sets[[2]])
rel2 <- felm(formula = fmlas[[2]],data = sets[[2]])

### PostEst Statistics ----

numPlayers <- c(format(length(unique(abs1[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(abs2[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(rel1[["fe"]]$userid)),nsmall = 0, big.mark=","),
                format(length(unique(rel2[["fe"]]$userid)),nsmall = 0, big.mark=","))

### Output ----

order_ <- c("wealth1000","altWealth1000", "dtThreshold","threshold","safeRight","riskyExpect")
covLabels <- c("Wealth (in 1000s)", "Alt. Wealth (in 1000s)", "Dec.Time $<$3.5s", "Threshold", "Safe on Right","Lottery Expectations")

tab <- stargazer(abs1,abs2,rel1,rel2, title ="Regression Results", 
                 column.labels = c("Absolute Treatment", "Relative Treatment"), column.separate = c(2,2),
                 add.lines = list(c("Control variables","YES","YES","YES","YES"),
                                  c("Individual fixed effects","YES","YES","YES","YES"),
                                  c("Lottery fixed effects","YES","YES","YES","YES"),
                                  c("Clustered st. err.","YES","YES","YES","YES"),
                                  c("Number of players", numPlayers[1],numPlayers[2],numPlayers[3],numPlayers[4])),
                 order= order_,
                 covariate.labels = covLabels,
                 summary = FALSE, align = FALSE, no.space = TRUE,  keep.stat = c("adj.rsq","n"), single.row = FALSE, multicolumn = TRUE, 
                 model.names = FALSE, dep.var.caption="Dependent variable: safe choice", dep.var.labels.include = FALSE, type="latex")

write.table(tab[15:(length(tab)-5)], file = paste0(saveDir,"/TableA5.txt"), 
            row.names = FALSE, col.names = FALSE, sep = "&", quote = FALSE)


