
### playing around with the correlation plots
library(tidyverse)
library(broom)
library(hrbrthemes)
library(viridis)

## getting data from all the "formatted_dataset.csv" files in each subdirectory of /Data
df <- list.files(recursive = T, pattern = "^formatted_dataset") %>% 
  map_dfr(read_csv)

df = df %>% filter(task != 'quest_only' | is.na(task) == TRUE) %>% 
  full_join(df %>% filter(task == 'quest_only') %>% 
              mutate(soep = choice,
                     choice = NA)) 


data=df %>% mutate(subject = paste0(bibkey, '_', subject)) %>% 
  select(bibkey, paper, task, subject, age, gender, choice, r, starts_with('soep'),
                starts_with('do'), 'BIS', 'BSSS', 'AuditS', 'CDCrisk', country, city,
         longitude, lattitude)

data %>% filter(task == 'EG')

## save the df to the shiny director for deployment
data %>% write_csv("METARET_APP/DATA/df_mod.csv")


