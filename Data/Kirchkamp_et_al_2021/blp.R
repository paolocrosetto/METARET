## ----init,include=FALSE,cache=FALSE-------------------------------------------
 opts_chunk[["set"]](fig.path='figure/small-', cache.path='cache/small-', 
     fig.align='center', dev='tikz', external=FALSE, fig.width=4.5, 
     fig.height=3, fig.show='hold', size="footnotesize",echo=FALSE,warning=FALSE, 
     error=TRUE, message=TRUE, tidy=FALSE,cache=TRUE,autodep=TRUE, par=TRUE, comment=NA, keep.blank.line=FALSE)
 knit_hooks[["set"]](par=function(before, options, envir){
 if (before) { options(width=80) }
 if (before && options[["fig.show"]]!='none') par(mar=c(4,4,1,.1),cex.main=1,font.main=1,cex.lab=.95,cex.axis=.9,mgp=c(2,.7,0),tcl=-.3)
 }, crop=hook_pdfcrop)
options(tikzMetricsDictionary="tikz.metrics")
options(scipen=9)

## ----libs,echo=FALSE,include=FALSE,cache=FALSE--------------------------------
readData<-TRUE ## set this to TRUE if you have (all) the raw data
                ## we include the raw data for some of the studies
                ## but we don't have permission to include it for all the studies
                ## below we provide all the commands one needs to prepare the data
                ## with these commands you can replicate the preparation of our data
                ## (if you get the raw data from the authors of the studies)
slow<-TRUE      ## set this to TRUE to calculate posteriors (this may take an hour or more)
if(length(list.files("mcmc","*.Rdata")) < 15) ## if you don't have these files you must calculate posteriors
    slow<-TRUE 
bootSize<-1000
library(xtable)
options(xtable.floating=FALSE)
options(xtable.sanitize.text.function=function(x) x)
library(haven)
library(runjags)
library(coda)
library(lattice)
library(latticeExtra)
library(plyr)
library(lme4)
library(stargazer)
library(binom)
library(boot)
library(zTree)
options(zTree.silent=TRUE)
library(readxl)
library(magrittr)
library(dplyr)
##
if(Sys.info()[["sysname"]]=='FreeBSD')
    runjags.options(jagspath='/usr/local/bin/mcmc-jags')
jagsVer<-testjags(silent=TRUE)
##
rjver<-sessionInfo()[["otherPkgs"]][["runjags"]][["Version"]]
lme4ver<-sessionInfo()[["otherPkgs"]][["lme4"]][["Version"]]
mTheme<-standard.theme("pdf", color=FALSE)
lattice.options(default.theme=mTheme)
##
runjags.options(silent.jags=FALSE,silent.runjags=FALSE,method="parallel",
                modules="glm",predraw.plots=FALSE)
initJags<-list()
initJags[[1]]<-list(.RNG.seed=1,.RNG.name="base::Mersenne-Twister")
initJags[[2]]<-list(.RNG.seed=2,.RNG.name="base::Super-Duper")
initJags[[3]]<-list(.RNG.seed=3,.RNG.name="base::Wichmann-Hill")
initJags[[4]]<-list(.RNG.seed=4,.RNG.name="lecuyer::RngStream")
##
odds <- function(x,mu=0) {
    o<-mean(x>mu)
    class(o)<-"odds"
    o
}
string.odds <- function (o) {
    if(o==1) return("40000:0");
    if(o==0) return("0:40000");
    or<-c(o/(1-o),1)
    paste(signif(or/min(or),3),collapse=":")
}
print.odds <- function (o) {
    cat(string.odds(o),"\n")
    o
}
int.odds <- function(o,stem="x is",text=c("larger","smaller"),Jeff=FALSE) {
    or<-o/(1-o)
    eType<-cut(abs(log10(or)),c(0,.5,1,1.5,2,Inf),c("only anecdotal","moderate","strong","very strong","decisive"))
    if(!Jeff) {
        eType<-cut(abs(log(or)),c(0,1,3,5,Inf),c("only anecdotal","positive","strong","very strong"))
    }
    paste("“",eType,"” evidence that ",stem," ",text[ifelse(or>1,1,2)],sep="")
}

## ----typeBLPconversion--------------------------------------------------------
## BLP should be rendered more nicely
typeT1 <- function(type) 
    factor(ifelse(grepl("online",type),type,
                       ifelse(type=="BLP","\\labBLP","\\labStd")))
typeT0 <- function(type,order=NULL) {
    x<-factor(ifelse(type=="BLP","\\labBLP",type))
    if(!is.null(order))
        x<-reorder(x,-grepl(order,x))
    x
}


## ----literature---------------------------------------------------------------
Literature<-read.csv(sep=";",text='type;ref;ltype;exp
DOV;\\citet{dursch2012sick};HL;2011 
BHO;\\citet{brunner2014premium};HL;2011
RTV;\\citet{roth2016role};HL  aggr.;Feb, Mar 2012
DRR;\\citet{duersch2017intertemporal};HL aggr.;Sep 2012, Jan 2013
PRS;\\citet{proto2019teach};HL;Apr, Nov 2018
AOW;\\citet{apesteguia2018copy};EG // 4 choices;Jan, May, Jun, Jul, Aug 2017
LMK;\\citet{koenig2019active};EG // 11 choices [0..15€];Oct, Nov 2017
S;\\citet{schmidt2019focal};EG // 8 choices [0..10.5€];Jan, Feb 2018
BLP;\\currentPaper;EG+HL;Nov, Dec 2018
onlineBLP;\\currentPaper;EG+HL;Sep 2020
onlineStd;\\currentPaper;EG+HL;Sep 2020')


## ----prepareDataPreparation---------------------------------------------------
EG.payoffs<-list()
EG.payoffs[["S"]]<-cbind(low=seq(4,.5,-.5),high=c(seq(4,10,1),10.5))
EG.payoffs[["BLP"]]      <-cbind(low=c(38,28,16,0),high=c(38,52,72,84)) ## prize: 5€ ##BLP.prizes<-c(40,32,77,2)
EG.payoffs[["onlineBLP"]]<-cbind(low=c(38,28,16,0),high=c(38,52,72,84)) ## prize: 5€ ##BLP.prizes<-c(40,32,77,2)
EG.payoffs[["onlineStd"]]<-cbind(low=c(38,28,16,0),high=c(38,52,72,84)) ## prize: 5€ ##BLP.prizes<-c(40,32,77,2)
EG.payoffs[["LMK"]]<-cbind(low=c(seq(6,1.2,-.6),.9,0),high=seq(6,15,.9))
EG.payoffs[["AOW"]]<-cbind(low=c(7.2,6.4,4,.8),high=c(8,15,18.6,20.8))
##
## for all EG procedures: interpret choice as preference:
EG.payoffs.all<-rbind.fill(lapply(names(EG.payoffs), 
                                  function(x) within(data.frame(EG.payoffs[[x]]),{
                                      type<-x
                                      expPay<-low+high
                                      choice<-1:length(low)
                                      maxPay<-max(expPay)
                                      neutral<-maxPay==expPay # risk neutral maximises expected payoffs
                                      averse<-median(high[neutral])>high # seem to interpret these lotteries reasonably
                                      pref<-ifelse(neutral,"neutral",ifelse(averse,"averse","riskSeeking"))
                                      })))[,c("low","high","pref","type","choice")]
##
HL.payoffs<-as.matrix(data.frame(highProb=1:10/10,low1=1.6,high1=2,low2=.1,high2=3.85))
switch2cchoice<-function(s) 1:10>=s ## s is the first switch to the risky lottery
choice2ind<-function(c) {
    if (is.na(c)) 
    { c(1,NA,NA,NA,NA) }
    else 
    { if(c) 1:5 else c(1,4,5,2,3) } 
    }
choice2lott <- function (choices) {
    xx<-within(adply(data.frame(i=1:10,c=choices),1,function(x) HL.payoffs[x$i,choice2ind(x$c)]),{
        i<-NULL
        c<-NULL})
    names(xx)[2:5]<-c("low","high","prefLow","prefHigh")
    subset(xx,!is.na(low))
    }
switch2lott <- function(s) ## s is the first switch to the risky lottery
    choice2lott(switch2cchoice(s))              
##
wide2lott <- function(df) {
    hl.names<-grep("^hl_",names(df),value=TRUE)
    x<-adply(df,1,function(x) choice2lott(unlist(x[1,hl.names])))
    x[,grep("^hl_",names(x),invert=TRUE)]
}
##
cleanWideHL <- function(df,code=c(0,1),type="unknownType",id="sid") {
    if(! id %in% names(df))
        stop("data contains no 'id' variable")
    df[["sid"]]<-paste(type,df[[id]],sep="-")
    df[["type"]]<-type
    df<-df[,grep("hl_|sid|session|gender|type|e_g",names(df),value=TRUE)]
    hl.names<-grep("hl_",names(df),value=TRUE)
    if(sum(! is.na(df[,hl.names]) & ! (unlist(df[,hl.names]) %in% code))>0)
        stop("data contains values other than those specified by 'code'")
    df[,hl.names]<-df[,hl.names]==code[2] ## code for risky choice
    df<-adply(df,1,function(risky) {
        minRisk <- min(c(which(risky[1,hl.names]==TRUE),length(hl.names)+1))
        maxSafe <- max(c(0,which(risky[1,hl.names]==FALSE)))
        undecided <- sum(is.na(risky[1,hl.names]))
        consistent<- maxSafe < minRisk &  undecided==0 & risky[1,"hl_10"]
        hlSwitch <- sum(! risky[1,hl.names],na.rm=TRUE)+1+undecided/2
        c(hlSwitch=hlSwitch,consistent=consistent)})
    df
}
#--------------------
## functions for EG:
egChoice2pairs<-function(x,pay=EG.payoffs) {
    xx<-data.frame(pay[-x$choice,])
    xx$prefLow<-pay[x$choice,1]
    xx$prefHigh<-pay[x$choice,2]
    xx$highProb<-.5
    xx
}
##
eg2lott <- function(df,pay) 
    adply(df,1,function(x) egChoice2pairs(x,pay=pay))[c("type","sid","low","high","prefLow","prefHigh","highProb")]
##

## ----initLists----------------------------------------------------------------
HL<-list()
HLS<-list()
EG<-list()
Lott<-list()

## ----DOV,eval=readData--------------------------------------------------------
# --------------------    
## DOV,Dürsch et al. (2012),HL
HL[["DOV"]]<-cleanWideHL(read.csv("data/DOV/dov.csv"),type="DOV",code=1:0)
Lott[["DOV"]]<-wide2lott(HL[["DOV"]])

## ----BHO.data,eval=readData---------------------------------------------------
## BHO,Brunner et al. (2014),HL ( 1 codes safe, 0 codes risky)
## we removed names and matriculation numbers from the original data
## xx<-read.csv("data/dataBHO.txt",sep="\t")
## write.table(xx[,grep("^d[1-9]|Session|ID",names(xx))],file="data/dataBHOanon.txt",sep="\t",row.names=FALSE,quote=FALSE)
xx<-read.csv("data/dataBHOanon.txt",sep="\t") 
## from the original data it is obvious that some participants participated twice
## this is, of course, not visible in the anonymised data. We remove the duplicates here:
xx<-subset(xx,! paste(Session,ID,sep="-") %in% c("5-19","5-30","5-15","5-24","6-29","6-30"))
##
bhoChoices<-grep("^d[0-9]*$",names(xx),value=TRUE)
for(n in bhoChoices)
    xx[,n]<-as.numeric(as.character(xx[,n]))
xx<-xx[apply(is.na(xx[,bhoChoices]),1,sum)<10,] ## drop empty sheets
names(xx)<-gsub("^d([0-9]*)$","hl_\\1",names(xx))
HL[["BHO"]]<-cleanWideHL(within(xx,sid<-sprintf("%d-%d",Session,ID)),type="BHO",code=1:0)
## remove empty sheets:
Lott[["BHO"]]<-wide2lott(HL[["BHO"]])

## ----RTV,eval=readData,include=FALSE------------------------------------------
## RTV,Roth et al. (2016) ,HL (only consistent, only switch)
sheets<-excel_sheets("data/RTV_bysession.xlsx")
RTV.combined<-rbind.fill(lapply(sheets[grep("session",sheets)],function(s) 
    within(read_xlsx("data/RTV_bysession.xlsx",s),{
           session<-s
           type<-"RTV"
           consistent<-1})))
HLS[["RTV"]]<-within(RTV.combined,{
    sid<-paste(date,session,ifelse(is.na(Subject),Subject...5,Subject),sep="-")
    hlSwitch<-A_1_HL})[,c("type","sid","hlSwitch","consistent")]
Lott[["RTV"]]<-adply(HLS[["RTV"]],1,function(x) switch2lott(x$hlSwitch))
## Prices for lotteries are reported in the paper - Hurrah!!! (2.00/1.60-3.85,0.10€)

## ----DRR,eval=readData--------------------------------------------------------
## DRR,Dürsch et al. (2017),HL // (only switch) 10 choices aggr. why more? 
## missing platznummer for 35 observations
## missing switch for “consistent” observations
DRR.raw<-within(read_dta("data/DRR.dta"),{
    missingID<-sum(is.na(platznummer))
    platznummer[is.na(platznummer)]<-(1:missingID)+1000
    sid<-paste("DRR",session,platznummer,sep="-")
    type<-"DRR"})[,c("type","sid","hl1","hl1_inconsistent")]
ni<-sum(is.na(DRR.raw[["hl1_inconsistent"]]))
hlNA<-with(subset(DRR.raw,hl1_inconsistent==0),sum(is.na(hl1)))
if(hlNA>0) warning("There are ",hlNA," observations in DRR marked ``consistent'' where hl1 is missing. We drop them.")
if(ni>0) warning("There are ",ni," observations in DRR where ``inconsistent'' is missing.
We just treat them as consistent as far as possible.")
DRR.raw<-within(DRR.raw,hl1_inconsistent[is.na(hl1_inconsistent)]<-0) ## ... we just treat them as consistent
DRR.raw<-subset(DRR.raw,!is.na(hl1) | hl1_inconsistent) 
HLS[["DRR"]]<-within(DRR.raw,{
    hlSwitch <- hl1
    consistent <- 1 - hl1_inconsistent
    hl1_inconsistent <- NULL
    hl1 <- NULL})
Lott[["DRR"]]<-adply(subset(HLS[["DRR"]],consistent==1),
                1,function(x) switch2lott(x$hlSwitch))

## ----PRS,eval=readData--------------------------------------------------------
## Proto et al. (2019), H+L (safe=1, risky=2)
prs.fn<-dir("data/PRS/","*.xls",full.names=TRUE)
PRS.t<-zTreeTables(prs.fn,table="subjects",ignore.errors=TRUE)
PRS.1<-subset(PRS.t$subjects,!is.na(lottery1))[,c("Date","Treatment","Period","Subject",grep("^lottery",names(PRS.t$subjects),value=TRUE))]
names(PRS.1)<-sub("^lottery","hl_",names(PRS.1))
PRS.2<-within(PRS.1,sid<-paste(Date,Subject,sep="-"))
PRS.3<-PRS.2[,grep("hl_|sid|type",names(PRS.2),value=TRUE)]
HL[["PRS"]]<-cleanWideHL(PRS.3,type="PRS",code=1:2)
Lott[["PRS"]]<-wide2lott(HL[["PRS"]])

## ----AOW,eval=readData--------------------------------------------------------
## Apesteguia et al. (2018), E+G
aow.fn<-dir("data/AOW/","*.xls",full.names=TRUE)
AOW.t<-zTreeTables(aow.fn,table="subjects",ignore.errors=TRUE)
##   *** File data/AOW//170118_1042.xls contains empty cells in globals, subjects, [82,83]. This is not a z-Tree file *** 
EG[["AOW"]]<-within(subset(AOW.t$subjects,Treatment==1 & Period==1)[,c("Date","Subject","profitP1")],{
       sid<-paste("AOW",Date,Subject,sep="-")
       choice<-profitP1
       type<-"AOW"})[,c("type","sid","choice")]
Lott[["AOW"]]<-eg2lott(EG[["AOW"]],EG.payoffs[["AOW"]])

## ----S.data,eval=readData,include=FALSE---------------------------------------
S<-read_xlsx("data/S.xlsx")[,1]
names(S)<-"choice"
EG[["S"]]<-within(S,{
          sid<-paste("S",1:nrow(S),sep="-")
          type<-"S"
          })
Lott[["S"]]<-eg2lott(EG[["S"]],EG.payoffs[["S"]])

## ----BLP.data,eval=readData---------------------------------------------------
## (safe=1, risky=0)
blp.xlsx<-read_excel("data/blp.xlsx")
HL[["BLP"]]<-cleanWideHL(blp.xlsx,code=1:0,type="BLP",id="id")
Lott[["BLP.HL"]]<-wide2lott(HL[["BLP"]])
EG[["BLP"]]<-within(HL[["BLP"]],{
    choice<-e_g
    type<-"BLP"})[,c("type","sid","choice")]
Lott[["BLP"]]<-eg2lott(EG[["BLP"]],pay=EG.payoffs[["BLP"]])

## ----LMK.data,eval=readData---------------------------------------------------
LMK.xlsx<-subset(read_xlsx("data/LMK/All_apps_-_wide_(accessed_2017-11-10).xlsx"),
                 !session.is_demo)[,c("participant.code","risktaking_lastpart.1.player.eg_choice","risktaking_lastpart.1.player.eg_payoff")]
names(LMK.xlsx)<-gsub("risktaking_lastpart.1.player.eg_|.code","",names(LMK.xlsx))
EG[["LMK"]]<-within(LMK.xlsx,{
    type<-"LMK"
    sid<-paste(type,participant,sep="-")})[,c("type","sid","choice")]
Lott[["LMK"]]<-eg2lott(EG[["LMK"]],EG.payoffs[["LMK"]])

## ----BLP.online.data,eval=readData--------------------------------------------
BLPraw<-subset(read.csv("data/blpOnline.csv"),!is.na(eg))
##remove personal data:
##write.csv(file="data/blpOnline.csv",BLPraw[,-grep("pseudo|iban|name|email|plz|city",names(BLPraw))])
names(BLPraw)<-gsub("hl","hl_",names(BLPraw))
##
onlineNames<-c("onlineStd","onlineBLP")
for (b in 0:1) {
    nn <- onlineNames[b+1]
    EG[[ nn ]]<-within(subset(BLPraw,blp==b),{
        type <- onlineNames[b+1]
        sid <- sprintf("%s-%03d",type,i)
        choice <- eg})[,c("type","sid","choice")]
    Lott[[ nn ]] <- eg2lott(EG[[ nn ]],pay=EG.payoffs[[ nn ]])
    ##
    HL[[ nn ]] <- cleanWideHL(subset(BLPraw, blp==b), type=nn, code=0:1, id="i")
    Lott[[ paste0(nn,".HL") ]] <- wide2lott(HL[[ nn ]])
}

## ----createDirs---------------------------------------------------------------
if(!file.exists("mcmc"))
    dir.create("mcmc")
if(!file.exists("data"))
    dir.create("data")

## ----saveData,eval=readData,cache=FALSE---------------------------------------
save(file="data/data.Rdata",HL,HLS,EG,Lott)

## ----prepare------------------------------------------------------------------
load("data/data.Rdata")
HL.df<-rbind.fill(HL)
HLS.df<-rbind.fill(HLS)
HL.all<-rbind.fill(HL.df,HLS.df)
EG.df<-rbind.fill(EG)


## ----textResults,cache=FALSE--------------------------------------------------
text.binomCI <- function (x) {
    z<-binom.confint(sum(x),length(x),methods="exact")
    list(mean=sprintf("%.2f\\%%",z[["mean"]]*100),
              ci95=sprintf("$CI_{95}$=[%.2f,\\penalty0 %.2f]",z[["lower"]]*100,z[["upper"]]*100))
}
##
nPartCompareLab <- sum(sapply(HL,nrow) + sapply(EG,nrow)) - sum(sapply(c("BLP","onlineBLP","onlineStd"),function(e) nrow(EG[[e]])+nrow(HL[[e]])))
#  
nsession<-length(unique(HL[["BLP"]][["session"]]))
nsessionOnline<-length(unique(HL[["onlineBLP"]][["session"]]))
inconsistentPart<-sum(HL[["BLP"]][["consistent"]]==0)
inconsistentOnline<-sum(HL[["onlineBLP"]][["consistent"]]==0)

##
egRN<-text.binomCI(EG[["BLP"]][["choice"]]==3)
egOnlineRN<-text.binomCI(EG[["onlineBLP"]][["choice"]]==3)
##
hlRN<-text.binomCI(subset(HL[["BLP"]],consistent==1)[["hlSwitch"]]==5)
hlOnlineRN<-text.binomCI(subset(HL[["onlineBLP"]],consistent==1)[["hlSwitch"]]==5)
##
text.corCI <- function(data) {
    xx<-subset(data,consistent==1)[,c("choice","hlSwitch")]
    set.seed(123)
    xx.b<-boot(xx,function(x,i) cor(x[i,])[1,2],bootSize)
    paste("$",round(cor(xx)[1,2],3),"$ (confidence interval $CI_{95}=[",paste(round(boot.ci(xx.b,type="basic")[["basic"]][4:5],3),collapse="\\penalty0 ,"),"])$")
}
##
bothTasks <- merge(EG[["onlineBLP"]],HL[["onlineBLP"]])
egHlcorCI <- text.corCI(bothTasks)
bothRN <- text.binomCI(with(subset(bothTasks,consistent==1),choice==3 & hlSwitch==5))
##
bothLabTasks <- merge(EG[["BLP"]],HL[["BLP"]])
egHllabcorCI <- text.corCI(bothLabTasks)
bothlabRN    <- text.binomCI(with(subset(bothLabTasks,consistent==1),choice==3 & hlSwitch==5))
##
ks.blp.test <- function(data,var="hlSwitch") 
    with(data,ks.test(data[grepl("BLP",type),var],data[!grepl("BLP",type),var]))[["p.value"]]
##
##ks.blp.test(subset(HL.df,consistent==1 & grepl("online",type)))
##ks.blp.test(subset(HL.df,consistent==1 & !grepl("online",type)))


## ----EGtable,results="asis"---------------------------------------------------
print(xtable(rename(within(data.frame(cbind(Lottery=1:4,EG.payoffs[["BLP"]])),`Exp. value`<-(low+high)/2),c("low"="Tokens if coin shows Tails","high"="Tokens if coin shows Heads")),digits=0,align=c("c","c","c","c","c")),include.rownames=FALSE)


## ----holtLauryLotteriesBLP,results='asis'-------------------------------------
lRange <- function(i) ifelse(i<2,i,paste(1,i,sep="-"))
uRange <- function(i) ifelse(i>9,i,paste(i,10,sep="-"))
q<-sapply(1:10,function(i) cat(sprintf("\\AA{%d}{%s}{%s}{%.1f}",i,lRange(i),uRange(i+1),i*(4-7.7)+(10-i)*(3.2-.2))))


## ----summaryHL,results='asis',message=FALSE-----------------------------------
HL.all %$%
   table(type,consistent,useNA="ifany") %>%
   cbind %>%
   data.frame %>%
   tibble::rownames_to_column(var="type") %>%
   mutate(`Risk Task`="HL") %>%
   left_join(Literature) %>%
   rename(inconsistent=X0,consistent=X1) -> xx.hl
##
EG.df %$%
   table(type) %>%
   cbind %>%
   data.frame %>%
   tibble::rownames_to_column(var="type") %>%
   mutate(`Risk Task`="EG") %>%
   left_join(Literature) %>%
   rename(consistent=".") -> xx.eg
##
rbind.fill(xx.hl,xx.eg) %>%
    rename(Reference=ref,Comments=ltype,`Time of exp.`=exp) %>%
    select(Reference,"Time of exp.",type,"Risk Task",consistent,inconsistent) %>%
    arrange(sprintf("%02d-%02d-%s",`Risk Task`=="EG",!grepl("currentPaper",Reference),type)) %>%
    mutate(type=ifelse(type=="BLP","\\BLP",type)) %>%
    rename(Acronym=type,
           `\\begin{tabular}{c}Risk\\\\task\\end{tabular}`=`Risk Task`,
           `\\begin{tabular}{c}Cons.\\\\obs.\\end{tabular}`=consistent,
           `\\begin{tabular}{c}Incons.\\\\obs\\end{tabular}`=inconsistent) -> xx
##
xx %$%
    grepl("currentPaper",Reference) %>% 
    (function(x) which(diff(x)!=0)) %>%
    c(-1,0,.,nrow(xx)) -> hline
##
xx %>%
  xtable(align=c("l","p{18ex}","p{18ex}","c","c","c","c")) %>%
  print(include.rownames=FALSE,hline.after=hline)


## ----prefStatistics,results='asis',message=FALSE------------------------------
types<-c("BLP","onlineBLP","onlineStd") ## we are only interested in "our" experiments
rbind.fill(EG) %>% 
    left_join(EG.payoffs.all) %>% 
    mutate(type=ifelse(type %in% types,type,"\\labStd")) %$% 
    table(type,pref) %>%
    data.frame %>%
    mutate(`Risk Task`="EG") -> EGtab
##
rbind.fill(HL) %>%
    mutate(type=ifelse(type %in% types,type,"\\labStd"),
           pref=cut(hlSwitch,c(-Inf,4,5,Inf),lab=c("riskSeeking","neutral","averse"))) -> HL.imed
HL.imed %$%
    table(type,pref) %>%
    data.frame %>%
    mutate(`Risk Task`="HL (all)") -> HL1tab
##
HL.imed %>%
    filter(consistent==1) %$%
    table(type,pref) %>%
    data.frame %>%
    mutate(`Risk Task`="HL (cons.)") -> HL2tab
##
rbind.fill(EGtab,HL1tab,HL2tab) %>%
#    mutate(type=factor(ifelse(type=="BLP","\\labBLP",as.character(type)))) %>%
    mutate(type=factor(ifelse(type=="BLP","\\labBLP",as.character(type)),
                       levels=c("onlineBLP","onlineStd","\\labBLP","\\labStd"))) %>%
    group_by(type,`Risk Task`) %>%
    mutate(relF=100*Freq/sum(Freq)) %>%
    tidyr::pivot_wider(id_cols=c("Risk Task","type"),names_from=pref,values_from=c("Freq","relF")) -> xx
xx[["Sum"]]<-apply(xx[,grep("^Freq",names(xx))],1,sum)
xx %>%
    arrange(`Risk Task`,`type`) %>%
    rename(Treatment=type) %>%
    rename_with(function(s) sub("Freq_","\\\\",s)) %>%
    rename_with(function(s) sub("relF_(.*)","\\\\\\1[\\\\%]",s)) %>%
    relocate(Sum,.after="Treatment") %>%
    xtable(.) %>%
    print(.,include.rownames=FALSE)


## ----riskNeutral,fig.height=3.5,fig.width=5-----------------------------------
eg.xx<-within(with(merge(rbind.fill(EG),EG.payoffs.all),aggregate(cbind(riskNeutral=pref=="neutral") ~ type,FUN=mean)),{
           EGHL<-"EG"
           type<-sub("online","onlineEG",type)
})
cx<-subset(HL.all,consistent==1)
hl.xx<-within(aggregate(cbind(riskNeutral=hlSwitch==5) ~ type,FUN=mean,data=cx),{
           EGHL<-"HL"})
xx<-rbind.fill(eg.xx,hl.xx)
xx<-within(xx,{
           online <- grepl("online",type)
           riskNeutralPercent<-riskNeutral*100
           })
xlim<-extendrange(xx$riskNeutralPercent,f=.3)
# generate four plots:
xx$type<-gsub("online|EG","\\\\,\\\\,",xx$type)
pp<-dlply(xx, ~ online + EGHL,function(x) {
    x$type<-with(x,reorder(type,riskNeutral + 10000*grepl("BLP",type) + 1000000*online + 10000*(EGHL=="EG")))
    stripText<-paste0(x[1,"EGHL"],"-",c("lab/other","online")[x[1,"online"]+1])
    dotplot(type ~ riskNeutralPercent | factor(stripText),xlab="",
            data=x,xlim=xlim,strip=TRUE,
            panel=function(x,y,...){
                panel.dotplot(x,y,...)
                labs <- sprintf("%.2f",x)
                panel.text(x,y,labs,adj=c(-.1,.5))
            })
    })
## draw the four plots:
yD<-.7;yd<-.5
plot(pp[[1]],position=c(0,0,.5,yD),more=TRUE)
plot(pp[[2]],position=c(.5,0,1,yD),more=TRUE)
plot(pp[[3]],position=c(0,yd,.5,1),more=TRUE)
plot(pp[[4]],position=c(.5,yd,1,1),more=FALSE)


## ----figure3,fig.height=3.5,fig.width=5---------------------------------------
#
hlBreaks<-0:10+1/2
HL.all %>%
    subset(consistent==1) %>% 
    mutate(type=typeT1(type)) %>%
    group_by(type) %>%
    mutate(typeL = paste0(type[1],", $n=",length(type),"$")) %>% 
    ungroup %>%
    mutate(typeL=reorder(X=100*grepl("BLP",type)-1*grepl("online",type),typeL)) %>%
    histogram(~hlSwitch | typeL,data=.,
              breaks=hlBreaks,xlab="Switching point ($p_k$)") + 
    layer(panel.refline(v=5,col="red"))


## ----figure3all,fig.height=3.5,fig.width=6------------------------------------
histogram(~hlSwitch | typeT0(type,"labBLP|online"),as.table=TRUE,data=subset(HL.all,consistent==1),breaks=hlBreaks,xlab="Switching point") + layer(panel.refline(v=5,col="red"))


## ----figure3eg,fig.height=3,fig.width=6---------------------------------------
xx<-subset(rbind.fill(EG),grepl("online",type))
p1<-with(xx,histogram(~choice | type,as.table=TRUE,breaks=0:(max(choice))+1/2,xlab="Choice",layout=c(1,2)) + layer(panel.refline(v=3,col="red")) )
##
xx2<-subset(rbind.fill(EG),!grepl("online",type))
p2 <-with(xx2,histogram( ~ choice | typeT0(type,"labBLP"),
                        as.table=TRUE,breaks=0:(max(choice))+1/2,xlab="Choice",layout=c(2,2))) + layer(panel.refline(v=3,col="red"),packets=1:2) +  layer(panel.refline(v=c(10,11),col="red"),packets=c(3)) + layer(panel.refline(v=c(7,8),col="red"),packets=c(4))
plot(p1,position=c(0,0,.4,1),more=TRUE)
plot(p2,position=c(.4,0,1,1),more=FALSE)


## ----jagsIni,cache=TRUE-------------------------------------------------------
runjags.options(silent.jags=FALSE,silent.runjags=FALSE,method="parallel",
                modules="glm",predraw.plots=FALSE)
initJags<-list()
initJags[[1]]<-list(.RNG.seed=1,.RNG.name="base::Mersenne-Twister")
initJags[[2]]<-list(.RNG.seed=2,.RNG.name="base::Super-Duper")
initJags[[3]]<-list(.RNG.seed=3,.RNG.name="base::Wichmann-Hill")
initJags[[4]]<-list(.RNG.seed=4,.RNG.name="lecuyer::RngStream")


## ----critR,fig.width=6,fig.height=2-------------------------------------------
tol<-.Machine$double.eps^.9
uDiff<-function(r,x,pH=c(.5,.5)) (1-pH[1])*(x[1,1]^(1-r)-1)/(1-r)+pH[1]*(x[1,2]^(1-r)-1)/(1-r)- ((1-pH[2])*(x[2,1]    ^(1-r)-1)/(1-r)+pH[2]*(x[2,2]^(1-r)-1)/(1-r))
type2r<-function(type) {
    n<-nrow(EG.payoffs[[type]])
    xx<-data.frame(type=ifelse(type=="BLP"," EG",type),i=(2:n),r=sapply(1:(n-1),function(i) uniroot(uDiff,c(-10,10),x=EG.payoffs[[type]][c(i,i+1),],tol=tol)[["root"]]))
    within(xx,rM<-(r+c(r[-1],NA))/2)
}
EGnames<-names(EG.payoffs)
critR<-rbind.fill(lapply(EGnames[!grepl("online",EGnames)],type2r))
##
xx<-data.frame(type=" HL",i=1:9,r=sapply(seq(.1,.9,.1),function(p)
   uniroot(uDiff,c(-10,100),x=t(matrix(HL.payoffs[1,c("low1","high1","low2","high2")],c(2,2))),
     pH=c(p,p),tol=tol)[["root"]]))
critALL<-rbind.fill(critR,within(xx,rM<-c(r-.1)))
u<-unique(critALL$type)
critALL$type<-factor(critALL$type,levels=u[order(paste0(ifelse(grepl("BLP|online",u),"AA","XX"),u),decreasing=TRUE)])
rM.na<-which(is.na(critALL$rM))
critALL<-within(critALL,rM[rM.na]<-1.5*r[rM.na]-.5*r[rM.na-1])
##
dotplot(type ~ r,data=critALL,xlab="$r$") + layer(panel.refline(v=0)) + layer(with(critALL,panel.text(rM,type,i,cex=.5)))


## ----critValuesForR-----------------------------------------------------------
## for the random utility model we need the critical value for r where decision makers are indifferent
## we also need the sign of the slope, so that either the interval to the left or to the right of the critical
## value counts
##
crra <- function (x,r) (x^(1-r)-1)/(1-r)
crra2 <- function (xvec,pH,r) (1-pH)*crra(xvec[1],r)+pH*crra(xvec[2],r) ## 2 prizes
crraDiff <- function (r,xvec,pH) crra2(xvec[1:2],pH,r) - crra2(xvec[3:4],pH,r) ## compare 2 prizes
## next determine whether interval for r is open upwards or downards, i.e. whether crra is increasing or decreasing
crraSlope <- function (r,xvec,pH,del=.1) (crraDiff(r=r+del,xvec=xvec,pH=pH)-crraDiff(r=r-del,xvec=xvec,pH=pH))/(2*del)<0
tol<-.Machine$double.eps^.9
lotts<-aggregate(sid ~ highProb + low + high + prefLow + prefHigh,data=rbind.fill(Lott),FUN=length)
critRR<-adply(subset(lotts,highProb<1),1,summarise,
      rI=try(uniroot(crraDiff,c(-10,10),xvec=c(low,high,prefLow,prefHigh),pH=highProb,tol=tol))[["root"]],
      rHigher=ifelse(crraSlope(r=rI,xvec=c(low,high,prefLow,prefHigh),pH=highProb),1,0))
critRR[["sid"]]<-NULL

## ----genJagsModels------------------------------------------------------------
## we use three models for JAGS.
## they all follow a similar structure, so we use the same skeleton here.
## we also prepare the CRRA utility function (or one and two prizes) as a string
genU <- function(x) paste("(",x,"[i]^(1-r[sid[i]])-1)/(1-r[sid[i]])",sep="")
genU2 <- function(x1,x2) paste("(1-highProb[i])*",genU(x1),"+highProb[i]*",genU(x2),sep="")
##
##  approach with tauL[k], tauR[p] ~ dgamma(m^2/d^2,m/d^2) does not perform too well with LMK and S.
##  tau ~ dexp(.01) is slightly faster and has lower psrf for LMK and S.
##
genModel <- function(robust=FALSE,randomPref=FALSE) {
    m <- "model {
    %likelihood%
    %df%
    for (k in 1:max(sid)) {
       tauL[k] ~ dexp(.01)
       sdL[k] <- 1/sqrt(tauL[k])     
       r[k] ~ %dr%
    }
    for (p in 1:max(pop)) {
       muR[p] ~ dnorm(muRP[1],muRP[2])
       tauR[p] ~ dexp(.01)
       sdR[p]<-1/sqrt(tauR[p])
    }
    for (p in 2:max(pop)) {
       dist[p-1]  <- abs(muR[1])-abs(muR[p])
       distR[p-1] <- dist[p-1]/sdR[1]
       pLen[p-1]  <- sum(pop==p) ## how many pops do we have?
       avrank[p-1]<- (sum(inprod(rank((r)^2),pop==p))-(pLen[p-1]^2+pLen[p-1])/2)/(pLen[p-1]*length(pop)-pLen[p-1]^2)
    }
}"
    param<-list(df="",dr="dnorm(muR[pop[k]],tauR[pop[k]])")
    param[["likelihood"]]<-paste("for (i in 1:length(low)) {
        choice[i] ~ dbern(p[i])
        Upref[i] <- ",genU2("prefLow","prefHigh"),"
        Usucc[i] <- ",genU2("low","high"),"
        logit(p[i]) <-  (Upref[i] - Usucc[i]) / sdL[sid[i]] ## Eq. (2)
    }",sep="")
    if (robust) {
        param[["df"]]<-"df ~ dexp(1/30)"
        param[["dr"]]<-"dt(muR[pop[k]],tauR[pop[k]],df)"
    }
    if(randomPref) 
        param[["likelihood"]]<-"for (i in 1:length(rI)) {
       myRR[i] ~ dnorm(r[sid[i]],tauL[sid[i]])
       rHigher[i] ~ dinterval(myRR[i],rI[i])
    }"
    for(var in names(param)) m<-gsub(paste("%",var,"%",sep=""),param[var],m)
    m
}
small.mod <- genModel()
robust.mod <- genModel(robust=TRUE)
rpref.mod <- genModel(randomPref=TRUE)

## ----lott2sum-----------------------------------------------------------------
### where is onlineBLP in LOtt ???
LottAll.df<-within(rbind.fill(Lott),EGHL<-factor(ifelse(is.na(consistent),"EG","HL")))
### here is a mistake, EG.online goes missing ^^^
LottEG.df<-subset(LottAll.df,EGHL=="EG")
LottHL.df<-subset(LottAll.df,EGHL=="HL")
##
LottConsist<-lapply(Lott,function(x) {
   if("consistent" %in% names(x)) return(subset(x,consistent==1))
   x
})
##
lott2sData <- function(Ln,pops="XXX",muRPrior=c(0,.1),randomPref=FALSE) {
    if (randomPref)
        Ln<-join(Ln,critRR,type="inner") ## add critical values to lotteries

   L.data <- as.list(within(Ln,{
         type<-as.numeric(factor(type));
         sid<-as.numeric(factor(sid));
         choice<-1;
   }))
   L.data[["muRP"]]<-muRPrior;
   ## L.data[["pop"]]<-aggregate(cbind(pop=(ifelse(type==pops,2,1))) ~ sid,data=Ln,FUN=mean)[["pop"]]
   L.data[["pop"]]<-aggregate(cbind(pop=(1+grepl(pops,type))) ~ sid,data=Ln,FUN=mean)[["pop"]]
   return(L.data)
}
##
lott2sum <- function(L,robust=FALSE,randomPref=FALSE,muRPrior=c(0,.1),save=FALSE,varname=NULL)  {
    if(is.null(varname)) {
        varname<-paste("jags",
                       ifelse(muRPrior[1]!=0,".1",""),
                       ifelse(identical(L,LottConsist),".Consist",""),
                       ifelse(robust,".rob",""),
                       ifelse(randomPref,".RP",""),
                       ".sum",
                       sep="")
    }
    filename<-paste0("mcmc/",varname,".Rdata")
    if(file.exists(filename))  { ## nothing to do
        load(filename)
        return(invisible(eval(parse(text=varname))))
    }
   jags.sum<-list()
   for(n in names(L)) {
      sData<-lott2sData(L[[n]],muRPrior=muRPrior,randomPref=randomPref)
      model <- genModel(robust=robust,randomPref=randomPref)
      ##sData<-lott2sData(head(Lott[["S"]],100))
      rj <- run.jags(model=model,data=sData,monitor=c("muR",'sdR'),
                     n.chains=4,inits=initJags)
      jags.sum[[n]]<-rj[["summary"]]
      jags.sum[[n]][["statistics"]]<-cbind(jags.sum[[n]][["statistics"]],
                                           seff=rj[["mcse"]][["sseff"]],
                                           psrf=rj[["psrf"]][["psrf"]][,1])
   }
   if(!save)
       return(invisible(jags.sum))
   eval(parse(text=paste(varname,"<-jags.sum")))
   eval(parse(text=paste0('save(',varname,',file="',filename,'")')))
   invisible(jags.sum)
}
##
lott2sumT <- function(...) {
    ## creates variables, saves them
    lott2sum(save=TRUE,...)
}
##
lott2jagsT <- function(dat="HL",online=NULL,robust=FALSE,randomPref=FALSE,muRPrior=c(0,.1),consist=FALSE,varname=NULL) {
    dat.df <- dat ## need this only for fake data
    if(dat=="HL") {
        if(consist)
            dat.df<-subset(LottHL.df,consistent==1)
        else
            dat.df<-LottHL.df
    }
    if(dat=="EG") 
        dat.df <- LottEG.df
    ##
    onl<-FALSE
    if(!is.null(online)) {
        dat.df <-subset(dat.df,xor(! online,grepl("online",type)))
        onl<-online
    }
    ##
    model <- genModel(robust=robust,randomPref=randomPref)
    sData <- lott2sData(dat.df,"BLP",muRPrior=muRPrior,randomPref=randomPref)
    if(is.null(varname)) {
        varname<-paste(dat,
                       ifelse(muRPrior[1]!=0,".1",""),
                       ifelse(onl,".online",""),
                       ifelse(consist,".Consist",""),
                       ifelse(robust,".rob",""),
                       ifelse(randomPref,".RP",""),
                       ".jags",
                       sep="")
    }
    filename<-paste0("mcmc/",varname,".Rdata")
    if(file.exists(filename))  { ## nothing to do
        load(filename)
        return(invisible(eval(parse(text=varname))))
    }
    monitor<-c("muR",'sdR',"dist","distR","avrank")
    if(robust)
        monitor<-c(monitor,"df")
    jags<-run.jags(model=model,data=sData,monitor=monitor,n.chains=4,inits=initJags)
    eval(parse(text=paste(varname,"<- jags")))
    eval(parse(text=paste0('save(',varname,',file="',filename,'")')))
    return(invisible(jags))
}


## ----jagsSummaries,cache=FALSE,include=FALSE----------------------------------
lott2sumT(Lott)

## ----jagsSummaries.1,cache=FALSE,include=FALSE--------------------------------
lott2sumT(Lott,muRPrior=c(.5,.1))

## ----jagsSummaries.rob,cache=FALSE,include=FALSE------------------------------
lott2sumT(Lott,robust=TRUE)

## ----jagsSummaries.ranPref,cache=FALSE,include=FALSE--------------------------
lott2sumT(Lott,randomPref=TRUE)




## ----jagsConsistSummaries,cache=FALSE,include=FALSE---------------------------
lott2sumT(LottConsist)

## ----jagsSummaries.1.Consist,cache=FALSE,include=FALSE------------------------
lott2sumT(LottConsist,muRPrior=c(.5,.1))

## ----jagsSummaries.Consist.rob,cache=FALSE,include=FALSE----------------------
lott2sumT(LottConsist,robust=TRUE)

## ----jagsSummaries.Consist.ranPref,cache=FALSE,include=FALSE------------------
lott2sumT(LottConsist,randomPref=TRUE)


## ----jSum2seg-----------------------------------------------------------------
jSum2seg <- function (j,j.consist=NULL,title=NULL,EGHL=NULL,ONLINE=NULL) {
    j2sum <- function(j,consist=FALSE) 
        within(rbind.fill(lapply(names(j),function(n) {
            xx<-data.frame(j[[n]][["quantiles"]])
            xx[["var"]]<-factor(rownames(xx))
            xx[["type"]]<-factor(n)
            xx[["online"]]<-grepl("online",n)
            xx[["eghl"]]<-ifelse(n %in% names(EG.payoffs),"EG",ifelse(consist,"HL-consist","HL"))
            if(!is.null(ONLINE))
                xx<-subset(xx,online==ONLINE)
            xx
        })),type<-reorder(type,grepl("BLP",type)*1000+(eghl!="EG")*10000+ifelse(var=="muR",X50.,0)))
    #
    jags.sum.df<-j2sum(j)
    if(!is.null(EGHL))
        jags.sum.df<-subset(jags.sum.df,eghl==EGHL)
    if(!is.null(j.consist))
        jags.sum.df<-rbind.fill(jags.sum.df,subset(j2sum(j.consist,consist=TRUE),eghl!="EG"))
    jags.sum.df<-within(jags.sum.df,eghl<-factor(eghl,levels=c("EG","HL-consist","HL")))
    if(!is.null(title))
        jags.sum.df[["eghl"]]<-factor(title[1])
    ##
    xlim<-extendrange(c(0,range(jags.sum.df[,1:5])))
    #if(HL) jags.sum.df<-subset(jags.sum.df,EGHL=="HL")
    jags.sum.df <- within(jags.sum.df,{
        levels(var)<-gsub("sdR","$\\\\sigma_r$",gsub("muR","$\\\\mu_r$",levels(var)))
        levels(type)<-gsub("\\.HL$"," ",levels(type))
        strip<-factor(paste0(eghl," - ",var))
    })
    rows<-length(unique(jags.sum.df[["strip"]]))/2
    ##
    segplot(type ~ X2.5. + X97.5. |   strip,xlim=xlim, layout=c(2,rows),
            scales=list(relation=list(y="free"),rot=0),
            data = jags.sum.df,
            draw.bands = FALSE, centers = X50., 
            segments.fun = panel.arrows, ends = "both", 
            angle = 90, length = 1, unit = "mm") + layer(panel.refline(v=0,col="red"))
}


## ----jagsPerExp.online,fig.width=5.5,fig.height=3-----------------------------
load("mcmc/jags.sum.Rdata")
load("mcmc/jags.Consist.sum.Rdata")
jSum2seg(jags.sum,jags.Consist.sum,ONLINE=TRUE)


## ----BLP.EG,cache=FALSE,include=FALSE-----------------------------------------
lott2jagsT("EG",online=TRUE)
lott2jagsT("EG",online=FALSE)

## ----BLP.EG.1,cache=FALSE,include=FALSE---------------------------------------
lott2jagsT("EG",muRPrior=c(.5,.1),online=TRUE)
lott2jagsT("EG",muRPrior=c(.5,.1),online=FALSE)

## ----BLP.EG.rob,cache=FALSE,include=FALSE-------------------------------------
lott2jagsT("EG",robust=TRUE,online=TRUE)
lott2jagsT("EG",robust=TRUE,online=FALSE)

## ----BLP.EG.RP,cache=FALSE,include=FALSE--------------------------------------
lott2jagsT("EG",randomPref=TRUE,online=TRUE)
lott2jagsT("EG",randomPref=TRUE,online=FALSE)


## ----BLP.HL,cache=FALSE,include=FALSE-----------------------------------------
lott2jagsT("HL",online=TRUE)
lott2jagsT("HL",online=FALSE)

## ----BLP.HL.1,cache=FALSE,include=FALSE---------------------------------------
lott2jagsT("HL",muRPrior=c(.5,.1),online=TRUE)
lott2jagsT("HL",muRPrior=c(.5,.1),online=FALSE)

## ----BLP.HL.rob,cache=FALSE,include=FALSE-------------------------------------
lott2jagsT("HL",robust=TRUE,online=TRUE)
lott2jagsT("HL",robust=TRUE,online=FALSE)

## ----BLP.HL.RP,cache=FALSE,include=FALSE--------------------------------------
lott2jagsT("HL",randomPref=TRUE,online=TRUE)
lott2jagsT("HL",randomPref=TRUE,online=FALSE)

## ----BLP.HL.consist,cache=FALSE,include=FALSE---------------------------------
lott2jagsT("HL",consist=TRUE,online=TRUE)
lott2jagsT("HL",consist=TRUE,online=FALSE)

## ----BLP.HL.1.consist,cache=FALSE,include=FALSE-------------------------------
lott2jagsT("HL",consist=TRUE,muRPrior=c(.5,.1),online=TRUE)
lott2jagsT("HL",consist=TRUE,muRPrior=c(.5,.1),online=FALSE)

## ----BLP.HL.consist.rob,cache=FALSE,include=FALSE-----------------------------
lott2jagsT("HL",consist=TRUE,robust=TRUE,online=TRUE)
lott2jagsT("HL",consist=TRUE,robust=TRUE,online=FALSE)

## ----BLP.HL.consist.RP,cache=FALSE,include=FALSE------------------------------
lott2jagsT("HL",consist=TRUE,randomPref=TRUE,online=TRUE)
lott2jagsT("HL",consist=TRUE,randomPref=TRUE,online=FALSE)

## ----BLP.EG.load,cache=FALSE--------------------------------------------------
for(fn in list.files("mcmc",".*jags.Rdata",full.names=TRUE)) {
    load(fn)
    obname<-gsub("mcmc/|.Rdata","",fn)
    cmd<-paste(gsub(".jags",".mc.df",obname),"<-data.frame(suppressWarnings(as.mcmc(",obname,")))")
    eval(parse(text=cmd))
}


## ----medCI,cache=FALSE--------------------------------------------------------
medCI <- function(j,var,text=var) {
   zm<- j$summary$statistics[var,"Mean"]
   z<- j$summary$quantiles[var,]
   paste("posterior mean of $",text,sprintf("=%.5f$ (credible interval $\\text{CI}_{95}=[%.5f, %.5f]$)\\footnote{Effective sample size=%.0f, potential scale reduction factor=%.5f.}",zm,z["2.5%"],z["97.5%"],j[["mcse"]][["sseff"]][var],j[["psrf"]][["psrf"]][var,1]))
}
medCIT <- function(j,j.df,var,hyp=">0",var2=NULL) { ## table version
   zm<- j$summary$statistics[var,"Mean"]
   z<- j$summary$quantiles[var,]
   df="$\\infty$"
   if("df" %in% rownames(j$summary$quantiles))
      df=signif(j$summary$quantiles["df","50%"],3)
   t<-sprintf("$%.5f$ & ",zm);
   if(!is.null(var2))
       t<-paste(t,sprintf("$%.5f$ & ",j$summary$statistics[var2,"Mean"]))
   paste(t,sprintf("$[%.5f, %.5f]$ & $%s$ & $%.0f$ & $%.5f$ & %s",
           z["2.5%"],z["97.5%"],
           string.odds(odds(eval(parse(text=paste("j.df[[var]]",hyp))))),
           j[["mcse"]][["sseff"]][var],
           j[["psrf"]][["psrf"]][var,1],df))
}


## ----pVal,include=FALSE-------------------------------------------------------
qualText<-c("only anecdotal","positive","strong","very strong") ## <- KassRaftery
qualOdds<-exp(c(0,1,3,5,Inf))
##qualText<-c("only anecdotal","moderate","strong","very strong","decisive") ## <- Jeff.
##qualOdds<-10^(c(0,.5,1,1.5,2,Inf))
qualOddsT<-sub("Inf","\\infty",signif(qualOdds,3),fixed=TRUE)
oddsText<-paste("odds${}\\in [",qualOddsT[1:4],":1,",qualOddsT[2:5],":1]$:",qualText,"evidence")


## ----jSum2seg2----------------------------------------------------------------
jSum2seg2 <- function (allMod,EGHL="HL") {
    j2sum <- function(j,mod) 
        within(rbind.fill(lapply(names(j),function(n) {
            xx<-data.frame(j[[n]][["quantiles"]])
            xx[["var"]]<-factor(rownames(xx))
            xx[["type"]]<-factor(n)
            xx[["eghl"]]<-ifelse(n %in% names(EG.payoffs),"EG","HL")
            xx[["mod"]]<-factor(mod)
            xx
        })),type<-reorder(type,(type %in% c("BLP","BLP.HL"))*1000+(eghl!="EG")*10000+ifelse(var=="muR",X50.,0)))

    ## ,type<-reorder(type,(type %in% c("BLP","BLP.HL"))*1000+(eghl!="EG")*10000+ifelse(var=="muR",X50.,0))
    #
    jags.sum.df<-subset(rbind.fill(lapply(names(allMod),function(m) j2sum(allMod[[m]],mod=m))),eghl==EGHL)
    xlim<-extendrange(c(0,range(jags.sum.df[,1:5])))
    #if(HL) jags.sum.df<-subset(jags.sum.df,EGHL=="HL")
    levels(jags.sum.df$var)<-gsub("sdR","$\\\\sigma_r$",gsub("muR","$\\\\mu_r$",levels(jags.sum.df$var)))
    levels(jags.sum.df$type)<-gsub("^BLP","\\\\labBLP ",levels(jags.sum.df$type))
    levels(jags.sum.df$type)<-gsub("\\.HL$","",levels(jags.sum.df$type))
    segplot( type ~ X2.5. + X97.5. |   var + mod,xlim=xlim,as.table=TRUE,
            scales=list(relation=list(y="free"),rot=0),
            data = jags.sum.df,
            draw.bands = FALSE, centers = X50., 
            segments.fun = panel.arrows, ends = "both", 
            angle = 90, length = 1, unit = "mm") + layer(panel.refline(v=0,col="red"))
}


## ----jagsPerExp.HL,fig.width=5.5,fig.height=6.5-------------------------------
load("mcmc/jags.sum.Rdata")
load("mcmc/jags.1.sum.Rdata")
load("mcmc/jags.rob.sum.Rdata")
load("mcmc/jags.RP.sum.Rdata")
allMod<-list(`\\normal`=jags.sum,
     `\\normalii`=jags.1.sum,
     `\\robust`=jags.rob.sum,
     `\\randomPref`=jags.RP.sum)
jSum2seg2(allMod,EGHL="HL")


## ----jagsPerExp.HL.Consist,fig.width=5.5,fig.height=6.5-----------------------
load("mcmc/jags.Consist.sum.Rdata")
load("mcmc/jags.1.Consist.sum.Rdata")
load("mcmc/jags.Consist.rob.sum.Rdata")
load("mcmc/jags.Consist.RP.sum.Rdata")
allMod<-list(`\\normal`=jags.Consist.sum,
     `\\normalii`=jags.1.Consist.sum,
     `\\robust`=jags.Consist.rob.sum,
     `\\randomPref`=jags.Consist.RP.sum)
jSum2seg2(allMod,EGHL="HL")


## ----j2effTab-----------------------------------------------------------------
j2effTab<-function(j,EGHL="HL") {
    j2conf <- function(su,mod) {
        cc<-t(sapply(su,function(x) 
            c(t(x[["statistics"]][c("muR","sdR"),c("seff","psrf")]))))
        within(data.frame(cc),{
            approach<-paste(rownames(cc),mod)
            eghl<-ifelse(rownames(cc) %in% names(EG.payoffs),"EG","HL")
        })
    }
    cCo<-subset(rbind.fill(lapply(names(j),function(mod) j2conf(j[[mod]],mod))),eghl==EGHL)
    rownames(cCo)<-sub("\\.HL","",sub("^BLP","\\\\labBLP",cCo$approach))
    cCo$eghl<-NULL
    cCo$approach<-NULL
    colnames(cCo)<-c("effss","psrf","effss","psrf")
    print(xtable(cCo,digits=c(0,0,5,0,5)),hline.after=c(0,nrow(cCo)),add.to.row=list(pos=list(-1),command=("\\hline & \\multicolumn{2}{c}{$\\mu_r$} & \\multicolumn{2}{c}{$\\sigma_r$}\\\\")))
}


## ----seffPsrf.HL,results='asis'-----------------------------------------------
allMod<-list(`\\normal`=jags.sum,
     `\\normalii`=jags.1.sum,
     `\\robust`=jags.rob.sum,
     `\\randomPref`=jags.RP.sum)

j2effTab(allMod,EGHL="HL")


## ----seffPsrf.HL.consist,results='asis'---------------------------------------
allMod<-list(`\\normal`=jags.Consist.sum,
     `\\normalii`=jags.1.Consist.sum,
     `\\robust`=jags.Consist.rob.sum,
     `\\randomPref`=jags.Consist.RP.sum)
j2effTab(allMod,EGHL="HL")


## ----jagsPerExp.EG.Consist,fig.width=5.5,fig.height=5.7-----------------------
allMod<-list(`\\normal`=jags.sum,
     `\\normalii`=jags.1.sum,
     `\\robust`=jags.rob.sum,
     `\\randomPref`=jags.RP.sum)
jSum2seg2(allMod,EGHL="EG")


## ----seffPsrf.EG,results='asis'-----------------------------------------------
allMod<-list(`\\normal`=jags.sum,
     `\\normalii`=jags.1.sum,
     `\\robust`=jags.rob.sum,
     `\\randomPref`=jags.RP.sum)

j2effTab(allMod,EGHL="EG")


## ----EG.payoff.table,results='asis'-------------------------------------------
q<-by(EG.payoffs.all,EG.payoffs.all$type,function(x) {
    cat("\\TA{",x$type[1],"}")
    adply(x,1,function(x) cat(sprintf("\\%s{%g}{%g}",ifelse(x$pref=="neutral","TN","TT"),x$low,x$high)))
    cat("\\\\\\hline\n")
    })


## ----holtLauryLotteries,results='asis'----------------------------------------
xx<-data.frame(t(sapply(1:10,function(i) c(sprintf("In %d out of 10 cases you earn 40 tokens / 2€,\\endgraf in %d out of 10 cases you earn 32 tokens 1.6€",i,10-i),
sprintf("In %d out of 10 cases you earn 77 tokens/ 3.85€,\\endgraf in %d out of 10 cases you earn 2 tokens / 0.1€",i,10-i)))))
names(xx)<-c("Lottery A","Lottery B")
print(xtable(xx,align=c("c","p{.45\\linewidth}","p{.45\\linewidth}")),include.rownames=FALSE,hline.after=seq(-1,10))


## ----tokenTableEG,results='asis'----------------------------------------------
xx<-cbind(Lottery=1:nrow(EG.payoffs[["BLP"]]),(EG.payoffs[["BLP"]]),"\\square")
colnames(xx)[2]<-"\\begin{tabular}{c}Tokens if coin\\\\shows Heads\\end{tabular}"
colnames(xx)[3]<-"\\begin{tabular}{c}Tokens if coin\\\\shows Tails\\end{tabular}"
colnames(xx)[4]<-"\\begin{tabular}{c}Please choose exactly\\\\one lottery\\end{tabular}"
print(xtable(xx,align=c("c","c","c","c","c")),include.rownames=FALSE)


## ----hlLotTable,results='asis'------------------------------------------------
mRange <- function(x) {
  if(min(x)==max(x)) return(x);
  sprintf("%g-%g",min(x),max(x))
}
mPack <- function(x,pay) {
cat("\\begin{tabular}{@{}c@{}}\\HLL{",pay[1],"}{",mRange(1:x),"}\n")
if(x<10)
cat("\\\\\\HLL{",pay[2],"}{",mRange((x+1):10),"}\n")
cat("\\end{tabular}\n")
}
q<-lapply(1:10, function(x) {
   mPack(x,c(40,32))
   cat("& A or B &")
   mPack(x,c(77,2))
   cat("\\\\\\hline")
})


## ----saveAll------------------------------------------------------------------
save.image("all.Rdata")

