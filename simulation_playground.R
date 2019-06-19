#### simulation of correlation strength

### just to see what is going on here

library(tidyverse)
library(broom)
library(hrbrthemes)
library(magrittr)

theme_set(theme_ipsum_rc()+
            theme(legend.position = "bottom")+
            theme(strip.text.x = element_text(hjust = 0.5))+
            theme(panel.spacing.x = unit(0.2, "lines")))

## getting data from all the "formatted_dataset.csv" files in each subdirectory of /Data
df <- list.files(recursive = T, pattern = "^formatted_dataset") %>% 
  map_dfr(read_csv)

## filter
df <- df %>% 
  filter(treatment == "5x5")

## estimate of the raw variable
cor.test(df$choice, df$soep)$estimate

## what if I shrink the numbers -- nothing changes
df <- df %>% 
  mutate(choice4 = choice/4) 

cor.test(df$choice4, df$soep)$estimate

## adding some uniform noise:
## function
spreadout <- function(var){
  out <- numeric(length = length(var))
  for (i in seq_along(var)) {
    #addme <- sample(c(0,1,2,3), size = 1)
    addme <- runif(1)*4
    out[i] <- var[i]+addme
  }
  out
}

asd <- numeric(length = 50000)
for (i in seq_along(asd)) {
  soep <- df$soep
  ch <- df$choice
  chR <- spreadout(ch)
  asd[i] <- cor(chR, soep)
}
asd %>% as_tibble() %>% 
  mutate(bias = value - cor(df$choice, df$soep)) %>% 
  mutate(bmean = mean(value)) %>% 
  ggplot(aes(value))+geom_density()+
  geom_vline(xintercept = cor(df$choice, df$soep), color = "red")+
  geom_vline(aes(xintercept = bmean), col = "green")+
  coord_cartesian(xlim=c(0.3,0.4))+
  labs(title = paste(length(asd), "repetitions of random expansion of the choice variable"), 
       subtitle = paste("The bias is: ", round(asd - mean(cor(df$choice, df$soep)),4), sep =""))
