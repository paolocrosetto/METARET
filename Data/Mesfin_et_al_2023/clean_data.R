#### Mesfin, H., Cecchi, F., Nillesen, E. & Tirivayi, N. (2023). Overconfidence,
#### trust, and information-seeking among smallholder farmers: Experimental evidence
#### from Ethiopia. Economic Development and Cultural Change, 72(1), 79-122.
#### https://doi.org/10.1086/719464
#### Data: https://doi.org/10.7910/DVN/60CB0O (Infoseeking_unpooled.tab)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab-in-the-field experiment with 760 smallholder farmers in 10 villages (40
## gots) of Ethiopia. original_dataset.csv keeps one row per farmer: village
## number, the amount invested, sex and age; respondent ids and survey uuids are
## dropped and subjects are row numbers.
## Risk task (paper, section II): Gneezy-Potters investment of the 30 ETB show-up
## fee in a lottery that doubles the invested amount with probability 1/2 and
## halves it otherwise. choice = ETB invested (lotto_buy, "How much would you like
## to invest in the lottery?"). Note: the authors' variable 'Risk' ("Risk loving",
## mean 0.718 in their Table 1) equals 1 - lotto_buy / 30 for every farmer, i.e. the
## share NOT invested; the direct answer is used here.
## sex: 1 = male, so gender = 1 - sex.
df <- read_csv("Data/Mesfin_et_al_2023/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "IG",
            choice = invest_etb,
            age,
            gender = 1 - male,
            country = "Ethiopia")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Mesfin2023",
         paper = "Mesfin et al. 2023")

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
df %>% write_csv("Data/Mesfin_et_al_2023/formatted_dataset.csv")
