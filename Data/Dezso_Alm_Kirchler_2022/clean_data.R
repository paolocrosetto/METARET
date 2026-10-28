#### Dezső, L., Alm, J. & Kirchler, E. (2022).
#### Inequitable wages and tax evasion.
#### Journal of Behavioral and Experimental Economics, 96, 101811.
#### https://doi.org/10.1016/j.socec.2021.101811
#### Data: https://github.com/leberkase/InequitableWagesTaxEvasion
#### (the whole repository is in raw_repository/)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## inequityTaxEvasionDataset.csv, the oTree export: one row per participant.
## test == 1 rows are test sessions; the authors' analysis.Rmd drops them and
## participant.id_in_session == 1, the Type B subject of each six-person
## session. Type B subjects are dropped there because they did not do the tax
## task, but the EG task came before the roles were drawn ("4. Eliciting risk
## preferences via EG task. 5. Assigning types"), so all 276 enrolled
## subjects are kept. Survey answers are in Hungarian, read as latin1.
df <- read_csv("Data/Dezso_Alm_Kirchler_2022/original_dataset.csv",
               show_col_types = FALSE, locale = locale(encoding = "latin1")) %>%
  filter(test == 0)
stopifnot(nrow(df) == 276, !any(is.na(df$scl.1.player.lottery_choice)))

## The EG task, six 50/50 gambles in HUF (Table 1): 2000/2000, 1700/2700,
## 1400/3400, 1100/4100, 800/4800, 100/5500. choice = gamble chosen, 1 the
## safest. Bounds in generate_r.R.
## male comes from the survey item gender ("Férfi" = man); on this site gender
## is 1 for women. The survey asked the year of birth; the dates of the
## sessions are not given, but the preregistration (AsPredicted #36099) is from
## 2020, so age = 2020 - birth year (it may be off by one). Three subjects
## entered 1900 and are set to missing.
df <- df %>%
  transmute(subject = row_number(),
            age = if_else(survey.1.player.birth_year > 1900,
                          2020 - survey.1.player.birth_year, NA_real_),
            gender = 1 - male,
            task = "EG",
            choice = scl.1.player.lottery_choice)

#### adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Dezso2022",
         paper = "Dezso, Alm and Kirchler 2022")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## "conducted at the lab facilities of Corvinus University of Budapest,
## Hungary" (the first author is at the University of Vienna).
df$country = 'Hungary'
df$city = 'Budapest'
df$lattitude = '47.4862'
df$longitude = '19.0583'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Dezso_Alm_Kirchler_2022/formatted_dataset.csv")
