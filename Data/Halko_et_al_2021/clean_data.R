#### Halko, M.-L., Lappalainen, O. & Sääksvuori, L. (2021).
#### Do non-choice data reveal economic preferences? Evidence from biometric data
#### and compensation-scheme choice.
#### Journal of Economic Behavior and Organization, 188, 87-104.
#### https://doi.org/10.1016/j.jebo.2021.04.009
#### Data: Mendeley Data, "Data for: Do non-choice data reveal economic
#### preferences? ...", https://doi.org/10.17632/5h9mdnjfkw.1 (CC BY 4.0), one
#### file, Halko_et_al_Data_in_Brief.xlsx. original_dataset.csv keeps only the
#### session and id, birth year, age, sex, the Holt-Laury columns and the general
#### risk question; the heart-rate (HRV) measurements and the other tasks are not
#### copied.

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "We conducted the experimental sessions in the PCRC Experimental Laboratory
## at Turku University, Finland. There were 160 participants (72 male and 88
## female)", eight sessions of 20 over two days each.
df <- read_csv("Data/Halko_et_al_2021/original_dataset.csv", show_col_types = FALSE)
stopifnot(nrow(df) == 160)

## Holt and Laury (2002), incentivized: one row paid. The payments in the file
## are the original table in euros (A 2.00/1.60, B 3.85/0.10). The columns,
## read from the payments: HLChoice is the row drawn for payment, HLDice the
## ten-sided die, HLPay the payout, and HLSwitch the first row in which B was
## chosen (in every row checked, the payout is A's below HLSwitch and B's from
## it on). HLSwitch is missing for the 20 who switched more than once; as on the
## rest of the site they are left out. choice = number of B choices = 11 -
## HLSwitch.
## General risk question: "willingness to take risk on a scale from 0 to 10"
## (Dohmen et al. 2011), the site's SOEP item.
## Gender: 1 female ("Female: a dummy variable with female = 1").
df <- df %>%
  filter(!is.na(HLSwitch)) %>%
  transmute(subject = row_number(),
            age = Age,
            gender = Gender,
            task = "HL",
            choice = 11 - HLSwitch,
            soep = GeneralRisk)
stopifnot(nrow(df) == 140, all(df$choice %in% 0:10))

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Halko2021",
         paper = "Halko, Lappalainen and Sääksvuori 2021")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## PCRC laboratory, Turku School of Economics, University of Turku.
df$country = 'Finland'
df$city = 'Turku'
df$lattitude = '60.4561'
df$longitude = '22.2849'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, soep, everything())

# Writing to file
df %>% write_csv("Data/Halko_et_al_2021/formatted_dataset.csv")
