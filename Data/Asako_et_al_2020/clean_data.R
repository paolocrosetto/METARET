#### Asako, Y., Funaki, Y., Ueda, K. & Uto, N. (2020). (A)symmetric information
#### bubbles: Experimental evidence. Journal of Economic Dynamics and Control, 110.
#### Data: Mendeley Data "Data for (A)symmetric Information Bubbles Experimental
#### Evidence" (profile.dta, analysis1.do)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Riding-bubble asset markets with Waseda University students, Tokyo. The
## folders loaded by analysis1.do date the sessions 20 November 2015 to 26 May
## 2016. After the markets the questionnaire measured "attitudes toward risk
## (developed by Holt and Laury, 2002)"; the list of Appendix B keeps the Holt
## and Laury ratios with payoffs in hundreds of yen and is not paid -- the CRRA
## bounds are scale-free, so the shared standard-HL block of generate_r.R
## applies (as for the hypothetical lists of Aschenwald and Alfonso).
##
## profile.dta is one row per subject (300, IDs unique) with the number of
## safe choices only, so multiple switchers cannot be told apart. The 6 with 10
## safe choices chose A even in the last row, where B is the better payoff for
## sure: they are kept for the download only, with inconsistent = 1
## (Data/inconsistent_rows.R). choice = number of B choices = 10 - safe choices.
## gender: the variable is labelled "GENDER 0:men", so 1 = women already.
df <- read_csv("Data/Asako_et_al_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 300, all(df$n_safe %in% 0:10), all(df$gender_code %in% 0:1))
stopifnot(sum(df$n_safe <= 9) == 294)

df <- df %>%
  transmute(subject,
            task = "HL",
            choice = 10 - n_safe,
            inconsistent = as.numeric(n_safe == 10),
            gender = gender_code,
            age,
            bibkey = "Asako2020",
            paper = "Asako et al. 2020")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

## Waseda University, Tokyo; the map shows only the country
df$country = 'Japan'
df$city = 'Tokyo'
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Asako_et_al_2020/formatted_dataset.csv")
