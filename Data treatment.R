## packages for the project
source("libraries.R")

# import the bibfile
bibdf <- bib2df("METARET.bib")

## clean names
bibdf <- bibdf %>% 
  janitor::clean_names() %>% 
  rename(bibkey = bibtexkey)

## keep the authors, title, journal, year, DOI
bibs <- bibdf %>% select(bibkey, author, title, year, journal, doi_2)
df <- read.csv("DATA/df_mod.csv", sep = ",")
df <- merge(x=df, y=bibs, by="bibkey", all.x=TRUE) 

## Filter the variables we need for our study 
df_test = df %>% filter(task %in% c('HL', 'EG', 'BART', 'BRET', 'IG'), r <= 2.5) %>%
  select(bibkey, choice, task, soep, doall, r, gender, age, country) %>% drop_na()

## Found an error in the data frame
df_test$task[df_test$task=="BART" & df_test$bibkey == "Crosetto2016"]<-"BRET"

## check how many rows are there
nrow(df_test)

df_test%>%select(country)%>%group_by(country) %>% summarise(n=n())
## What"s a correlation between two questionnaires? It"s quite low though...
cor(df_test$r, df_test$soep)

##########################################
## Try to count the y (valeurs ciblées) ##
##########################################

## https://stats.stackexchange.com/questions/281162/scale-a-number-between-a-range

df_test$id = 1:nrow(df_test)

## SOEP variable 
df_test$y_r_SoepScale = (df_test$r - min(df_test$r))/(max(df_test$r) - min(df_test$r)) * (10 - 0) + 0

df_test$y_r_SoepScale = df_test$y_r_SoepScale - 2.542214

cor(df_test$r, df_test$soep)

df_test %>% 
  select(y_r_SoepScale, soep, id, task) %>%
  pivot_longer(-c(id,task)) %>% 
  ggplot(aes(x = value, fill = name)) + geom_density(alpha = 0.3) + 
  geom_vline(xintercept = 5)

df_test = df_test %>% filter( 
  y_r_SoepScale <= (1-(2.542214)/10) * max(y_r_SoepScale))

df_test$y_gap_Soep = df_test$y_r_SoepScale - df_test$soep

df_test %>% 
  select(y_gap_Soep, id)  %>%
  ggplot(aes(x = id, y = y_gap_Soep)) + geom_point()


## Dospert variable 
df_test$y_r_DospertScale = (df_test$r - min(df_test$r))/(max(df_test$r) - min(df_test$r)) * (7 - 1) + 1

df_test$y_r_DospertScale = df_test$y_r_DospertScale - .83352

cor(df_test$y_r_DospertScale, df_test$doall)

pldf_test %>% 
  select(y_r_DospertScale, y_r_SoepScale, id, country) %>%
  pivot_longer(-c(id,country)) %>% 
  ggplot(aes(x = value, fill = name)) + geom_density(alpha = 0.3) + 
  geom_vline(xintercept = 4)

plot + facet_wrap( ~ country)

df_test = df_test %>% filter( 
                   y_r_DospertScale <= (1-(.83352)/6) * max(y_r_DospertScale))

df_test$y_gap_Dospert = df_test$y_r_DospertScale - df_test$doall

df_test %>% 
  select(y_gap_Dospert, id)  %>%
  ggplot(aes(x = id, y = y_gap_Dospert)) + geom_point()


##################################
## Add some characteristics ##
##################################

## 1. Check if task is visual. Normally it should help to make results better

df_test$is_visual = with(df_test,
                    ifelse(task == 'BRET' | task == 'BART', 1, 0))

## 2. Check if the list is a price list
df_test$is_price_list = with(df_test,
                        ifelse(task == 'BRET' | task == 'BART' | task == 'IG' , 0, 1))

## 3. Variable dimensions (Probabilities, Outcomes)
df_test$probabilities_change = with(df_test,
                            ifelse(task == 'BRET' | task == 'BART' | task == 'HL', 1, 0))

df_test$outcomes_change = with(df_test,
                               ifelse(task == 'HL', 0, 1))

## 4. Number of choices 

df_test$n_choices = with(df_test,
           ifelse(task == 'BRET' & bibkey == "Crosetto2013", 100, 
                  ifelse(task == 'BRET' & bibkey == "Crosetto2016", 100, 
                         ifelse(task == 'EG' & bibkey == "Crosetto2016", 5,
                                ifelse(task == 'HL' & bibkey == "Crosetto2016", 10,
                                       ifelse(task == 'IG' & bibkey == "Crosetto2016", 40,
                                              ifelse(task == 'BART' & bibkey == "Frey2017", 128,
                                                     ifelse(task == 'HL' & bibkey == "Frey2017", 10, 0))))))))


## 5. Neutral to risk payments

df_test$stakes = with(df_test,
                         ## 
             ifelse(task == 'BRET' & bibkey == "Crosetto2013", 0.1 * 100/2 * 0.5, 
                    
                    ifelse(task == 'BRET' & bibkey == "Crosetto2016", 0.2 * 100/2 * 0.5, 
                           
                          ### Lottery 5 is chosen
                           ifelse(task == 'EG' & bibkey == "Crosetto2016", 0.5 * 12,
                                  
                                  ## lottery 5 is the switching point
                                  ifelse(task == 'HL' & bibkey == "Crosetto2016", 0.5 * 4 + 0.5 * 3.2,
                                         
                                         ## 2.5 times 4
                                         ifelse(task == 'IG' & bibkey == "Crosetto2016", 4 * 2.5 * 0.5,
                                                
                                                ## Frey 0.005 for each pump, Risk neutral = 64 pumps
                                                ifelse(task == 'BART' & bibkey == "Frey2017", 128 / 2 * 0.005,
                                                     
                                                        ## €0.05 for each point , Risk neutral = 5 choice
                                                       ifelse(task == 'HL' & bibkey == "Frey2017", (0.5 * 80 + 0.5 * 70) *  0.05 , 0))))))))


## 6. Are there safe options in tasks? 

## Here it's the same with probabilities_change
## df_test$safe_option = with(df_test,
##                              ifelse(task == 'BRET' | task == 'BART' | task == 'HL', 0, 1))

## 7. value of safe option

df_test$value_safe_option = with(df_test,
                 ifelse(task == 'EG' | task == 'IG', 4, 0))

df_test$value_safe_option_to_stakes = df_test$value_safe_option / df_test$stakes

unique(df_test$value_safe_option)
## 8. Country

df_test %>% group_by(country) %>% summarise(n=n())
## there are 2 countries... 
df_test$germany = with(df_test,
                    ifelse(country == 'Germany', 1, 0))


df_test %>% filter(task == 'BART') %>% count()
##################################
## Simple models trials  ##
##################################


library(caret)
library(glmnet)

df_model =  df_test %>% 
  select(-c(bibkey, task, choice, r, id, soep, doall, y_r_DospertScale, 
            y_r_SoepScale,  country, y_gap_Dospert, value_safe_option,
            outcomes_change, value_safe_option_to_stakes)) %>%
  drop_na() 

nrow(df_model)

simple.fit = lm(y_gap_Soep~., data=df_model, )
summary(simple.fit)
coeftest(simple.fit, vcov. = vcovHC)

library(skedastic) # тест Уайта, тест Бройша-Пагана
library(lmtest) # тест Бройша-Пагана
library(sandwich)
white_lm(simple.fit)

set.seed(42)
cv_5 = trainControl(method = "cv", number = 5)

hit_elnet = train(
  y_gap_Dospert ~ ., data = df_model,
  method = "glmnet",
  trControl = cv_5
)
hit_elnet
plot(varImp(hit_elnet, scale = F))

coef(hit_elnet$finalModel, s = hit_elnet$bestTune$lambda)
