#### Holzmeister, F. & Stefan, M. (2019). The risk elicitation puzzle revisited: Across-methods (In)consistency?

#### cleaning data to be used for the meta-nalaysis

#### libraries
library(tidyverse)
library(haven)
library(broom)
library(readxl)


#### getting the data
df <- read_dta("Data/Nielsen_2019/original_dataset.dta")

## some subjects have made no choice apparently (0 everywhere)
df %>% 
  filter(!(box1 == 0 & box2 == 0 & box3 == 0 & box4 ==0)) %>% 
  mutate(treatment = as.factor(treatment)) %>% 
  mutate(box1 = box1*4) %>% 
  ggplot(aes(box1, color = treatment, fill = treatment))+
  geom_histogram(alpha =0.5, position = position_dodge())

# Writing to file
df %>% write_csv("Data/Nielsen_2019/formatted_dataset.csv")
