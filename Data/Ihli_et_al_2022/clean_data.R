#### Ihli, H., Seegers, R., Winter, E., Chiputwa, B. & Gassner, A. (2022).
#### Preferences for tree fruit market attributes among smallholder farmers in
#### Eastern Rwanda. Agricultural Economics, 53, 5-21.
#### https://doi.org/10.1111/agec.12673
#### Data: supporting information agec12673-sup-0002 (IHLI-DCE_data.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Household survey, discrete choice experiment and incentivized games with
## 252 smallholder farmers in Bugesera district, Eastern Province, Rwanda,
## March 2020 (sectors Juru, Nyamata and Rweru). The risk game "was designed
## following Eckel and Grossman (2002, 2008) and Dave et al. (2010).
## Participants were presented with an array of six lotteries and asked to
## choose one", each a 50/50 draw (Table 2, in RWF): 2800/2800, 2400/3600,
## 2000/4400, 1600/5200, 1200/6000, 200/7000. One of the three games was paid.
## Cuts in the Ihli2022 block of generate_r.R.
##
## The file is the DCE in long format, 24 rows per farmer; `risk` is the
## lottery chosen (1 to 6) and is constant within farmer. The package carries
## no age or gender, so both are NA.
df <- read_csv("Data/Ihli_et_al_2022/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 252, all(df$lottery %in% 1:6))

df <- df %>%
  transmute(subject,
            task = "EG",
            choice = lottery,
            gender = NA_real_,
            age = NA_real_,
            bibkey = "Ihli2022",
            paper = "Ihli et al. 2022")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## Bugesera district (Nyamata is the district seat)
df$country = 'Rwanda'
df$city = 'Nyamata'
df$lattitude = '-2.1500'
df$longitude = '30.0900'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Ihli_et_al_2022/formatted_dataset.csv")
