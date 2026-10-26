#### Roig, A., Thouvarecq, R. & Riviere, J. (2025). Economic and physical
#### risk-taking in 7- to 9-year-olds: The link with a novelty-driven exploratory
#### strategy. Journal of Behavioral and Experimental Economics, 117, 102397.
#### https://doi.org/10.1016/j.socec.2025.102397
#### Data: https://osf.io/yu3a4 (Bart_data.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 60 children from schools around Rouen, France: 20 each aged 7, 8 and 9, half
## of them girls. BART with 20 balloons, one point per successful pump, points
## paid in chocolate chips. The paper says the explosion point of each balloon
## was drawn in advance and pumps range from 0 to 116, i.e. the usual uniform
## balloon with N = 116; the observed bursts fit this (a child averaging 24
## pumps lost 5 of 20 balloons). The Python program in the OSF materials uses an
## increasing hazard press/116 instead, which would burst nearly every balloon at
## these pump counts, so it is not the version that produced the data.
## original_dataset.csv keeps age, sex, burst and cashed-out balloons and the
## adjusted score from Bart_data.csv; the children's names are dropped and
## subjects are row numbers. choice = adjusted average pumps (mean over the
## balloons that did not burst; every child cashed out at least 7).
## female: 1 = girl, 0 = boy.
df <- read_csv("Data/Roig_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "BART",
            choice = adj_pumps,
            age,
            gender = female,
            country = "France")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Roig2025",
         paper = "Roig et al. 2025")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Roig_et_al_2025/formatted_dataset.csv")
