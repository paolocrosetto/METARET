
### playing around with the correlation plots
library(tidyverse)
library(broom)
library(hrbrthemes)
library(viridis)

## getting data from all the "formatted_dataset.csv" files in each subdirectory of /Data
df <- list.files(recursive = T, pattern = "^formatted_dataset") %>% 
  map_dfr(read_csv)


df = df %>% filter(task != 'quest_only') %>% 
  full_join(df %>% filter(task == 'quest_only') %>% 
              mutate(soep = choice,
                     choice = NA)) 


data=df %>% mutate(subject = paste0(bibkey, '_', subject))


## save the df to the shiny director for deployment
data %>% write_csv("METARET_APP/DATA/df_mod.csv")
