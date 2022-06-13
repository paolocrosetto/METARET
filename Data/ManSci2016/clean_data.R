#### Crosetto and Filippin, "A Reconsideration of Gender Differences in Risk Attitudes", ManSci 2016

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)


#### getting the data
df <- read_csv("Data/ManSci2016/original_dataset.csv")

## getting only the data from HL replications:
df <- df %>% 
  filter(safe == 0) %>%    # dropping the papers using a safe option -- i.e. a different task
  filter(ID >= 0) %>%      # keeping only published papers (this needs updating)
  filter(incons_subj == 0) # dropping inconsistent subjects
  
## selecting the needed variables
## we select only:
## 1. the result of the task
## 2. any treatment or differences in the task
## 3. answers to questionnaires
df <- df %>% 
  select(subject, female, age, treatment, totsafe, 
         texbibkey, bibdisplay)

# rename totsafe as 'choice';
df <- df %>% 
  rename(choice = totsafe,
         paper = bibdisplay,
         gender = female) 

# assign HL as task
df <- df %>% 
  mutate(task = "HL")

# cleaning the "treatment" variable as it is not needed <- a HACK CHANGE THIS LATER
df <- df %>% 
  mutate(treatment = " ")

# cleaning the bibkey from latex tags -- could be done more elegantly with reg exp
df <- df %>% 
  separate(texbibkey, into = c("drop","keep"), sep = "\\{") %>% 
  select(-drop) %>% 
  separate(keep, into = c("bibkey", "drop"), sep = "\\}") %>% 
  select(-drop)

# since this is a meta analysis paper that groups different papers we need a metabibkey
df <- df %>% 
  mutate(metabibkey = "Meta2016")

## some choices are coded as 'half choice' -- the subject has made e.g. 1.5 choices -> DROP THEM
df <- df %>% 
  filter(choice != 1.5 & choice != 4.5 & choice != 5.5 & choice != 6.5 & choice != 7.5 )

# change to make choice in HL be the number of safe choices
df <- df %>% 
  mutate(choice = 10-choice)

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(metabibkey, task, choice), get_r))


# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

df$country = NaN
list = df %>% select(bibkey) %>% unique()
for (i in 1:nrow(df)){
  if (df$bibkey[i] == 'Holt2002' | df$bibkey[i] == 'Shafran2010' | 
      df$bibkey[i] =='Harrison2005' |
      df$bibkey[i] == 'Bellemare2010'|
      df$bibkey[i] == "Lange2007"|
      df$bibkey[i] == "Lange2007a"|
      df$bibkey[i] == "Chen2013" |
      df$bibkey[i] == 'Lusk2005' |
      df$bibkey[i] == 'Harrison2007b'|
      df$bibkey[i] == 'jamison2008' |
      df$bibkey[i] == 'Ryvkin2011' |
      df$bibkey[i] == 'Eckel2006'|
      df$bibkey[i] == 'Barrera2012' |
      df$bibkey[i] == 'Dickinson2009' |
      df$bibkey[i] == 'Deck2012a' |
      df$bibkey[i] == 'Grijalva2011' |## mixed Mexican + USA
      df$bibkey[i] == 'Fiore2009'|
      df$bibkey[i] == "Slonim2010"){ 
    df$country[i] = 'United States'
  }
  else if (df$bibkey[i] == 'Levy-Garboua2012' | 
      df$bibkey[i] == 'Jacquemet2008'| 
      df$bibkey[i] == 'Rosaz2012'|
      df$bibkey[i] == 'Rosaz2012a' |
      df$bibkey[i] == 'Masclet2009')
  {
    df$country[i] = 'France'
  }
  else if (df$bibkey[i] == 'Szrek2012')
  {
    df$country[i] = 'South Africa'
  }
  else if (df$bibkey[i] == 'Nieken2012' |
      df$bibkey[i] == 'Gloeckner2012' |
      df$bibkey[i] == 'Pogrebna2011' |
      df$bibkey[i] == 'Bauernschuster2010' |
      df$bibkey[i] == 'Duersch2012'|
      df$bibkey[i] == 'Fiedler2012'|
      df$bibkey[i] == 'Mueller2012'|
      df$bibkey[i] == "Gloeckner2012a")
  {
    df$country[i] = 'Germany'
  }
  else if (df$bibkey[i] == 'Drichoutis2012')
  {
    df$country[i] = 'Greece'
  }
  else if (df$bibkey[i] == 'Schram2011' |
      df$bibkey[i] == 'Sloof2010')
  {
    df$country[i] = 'Netherlands'
  }
  else if (df$bibkey[i] == 'Wakolbinger2009')
  {
    df$country[i] = 'Austria'
  }
  else if (df$bibkey[i] == 'Chakravarty2011')
  {
    df$country[i] = 'India'
  }
  else if (df$bibkey[i] == 'harrison2012b')
  {
    df$country[i] = 'Colombia'
  }
  else if (df$bibkey[i] == 'Dave2010')
  {
    df$country[i] = 'Canada'
  }
  else if (df$bibkey[i] == 'Ponti2009' |
      df$bibkey[i] == 'Cobo-Reyes2012'|
      df$bibkey[i] == 'Casari2009')
  {
    df$country[i] = 'Spain'
  }
  else if (df$bibkey[i] == 'Carlsson2009')
  {
    df$country[i] = 'China'
  }
  else if (df$bibkey[i] == 'Abdellaoui2011')
  {
    df$country[i] = 'Morocco'
  }
  else if (df$bibkey[i] == 'Yechiam2012')
  {
    df$country[i] = 'Israel'
  }
  else if (df$bibkey[i] == 'Andersen2010' | df$bibkey[i] == 'Harrison2008')
  {
    df$country[i] = 'Denmark'
  }
  ## Branas2011 used Caucasians for the research... 
  else{
    df$country[i] = ''
  }
}
df %>% select(country) %>% unique()

# Writing to file
df %>% write_csv("Data/ManSci2016/formatted_dataset.csv")
