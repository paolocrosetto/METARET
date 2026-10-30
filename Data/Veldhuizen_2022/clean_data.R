#####  Roel van Veldhuizen
## GENDER DIFFERENCES IN TOURNAMENT CHOICES: RISK PREFERENCES, OVERCONFIDENCE OR COMPETITIVENESS?

#### libraries
library(tidyverse)
library(haven)
library(broom)

df <- read_dta("Data/Veldhuizen_2022/Veldhuizen2022.dta")

df = df %>% select(age, eckel, dohmen1, dohmen3,
                   holtlauryswitch,
                   holtlaury, realpp, female) %>% 
  rename(EG = eckel,
         HL = holtlaury,
         gender = female,
         subject = realpp,
         soep = dohmen1,
         soep_financial = dohmen3
         ) %>% 
  pivot_longer(-c(age, soep, soep_financial,
                 holtlauryswitch,
                  subject, gender), names_to = 'task', values_to = 'choice')


## Inconsistent HL answers (29.10.2026): the 29 subjects who switch more than
## once (holtlauryswitch > 1; dropped before) and the 16 who never switch and
## take A in every row (holtlaury, the number of risky choices, is 0), so also
## in row 10, where B pays more for sure (counted before). They keep their HL
## row for the download only, with inconsistent = 1 (Data/inconsistent_rows.R);
## the file has no row-by-row answers, so the multiple switchers get no choice.
df <- df %>%
  mutate(inconsistent = as.numeric(task == "HL" & (holtlauryswitch > 1 | choice == 0)),
         choice = if_else(task == "HL" & holtlauryswitch > 1, NA_real_, choice))
stopifnot(sum(df$inconsistent) == 45)

df = df %>% filter(!is.na(choice) | inconsistent == 1) %>%
  drop_na(-choice) %>% select(-holtlauryswitch)

## one subject arrives with age 3. 16-17 shows up too and is plausible for a
## university pool, 3 is not, so anything under 15 is recorded as missing.
## Placed after drop_na() on purpose: before it, blanking the age threw the
## whole subject out, and their task data is perfectly good.
df <- df %>% mutate(age = if_else(age < 15, NA_real_, as.numeric(age)))

df$country = 'Germany'
df$city = 'Berlin'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$latitude = ''
df$longitude = ''

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Veldhuizen2022",
         paper = "Veldhuizen 2022")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Veldhuizen_2022/formatted_dataset.csv")
