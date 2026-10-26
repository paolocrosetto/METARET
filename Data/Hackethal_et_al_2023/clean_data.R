#### Hackethal, A., Kirchler, M., Laudenbach, C., Razen, M. & Weber, A. (2023).
#### On the role of monetary incentives in risk preference elicitation experiments.
#### Journal of Risk and Uncertainty, 66, 189-213. https://doi.org/10.1007/s11166-022-09377-w
#### Data: https://osf.io/rj7np/

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## all_samples_base.dta from OSF, one row per subject:
## sample 1 = students (Innsbruck), 2 = private investors (German bank),
## 3 = professional investors. Half of each sample was paid for one task
## (INCENTIVES), the other half got a flat fee (FLAT); both are kept, since the
## paper finds no difference in choices.
df <- read_dta("Data/Hackethal_et_al_2023/original_dataset.dta")

## Every subject did several tasks (within-subject). Investors saw the tasks in
## euros (Table 1 of the paper); students saw all amounts divided by 4 and their
## answers are in the variables without the "inv" prefix. With CRRA x^r utility
## the bounds do not depend on the scale, so one rule covers both versions.
##  - HL: A = 24 / 19.20, B = 46.20 / 1.20 (the standard Holt-Laury list x 12).
##        HL_choice1-10: 1 = A, 2 = B. choice = number of B choices.
##  - EG: six 50/50 gambles 21/21, 27/18, 33/15, 39/12, 45/9, 51/6. choice = rank.
##  - IG (Gneezy-Potters): endowment 24 (students 6), 2.5-fold. choice = amount invested.
## - CE_staircase (Falk et al.): four choices between a sure amount and 45 EUR
##        with 50% (students 11.25), sure 24 then +-12, +-6, +-3.
##        Falk_WTR / invFalk_WTR = FA (1 ... 16), the rank of the final CE interval.
##        Added on 22.10.2026, after the other three tasks, so that their r draws
##        stay as they were.
## survey_risk and survey_risk_fin are the SOEP items (0-10).
df <- df %>% 
  mutate(subject = row_number(),
         student = sample == 1,
         HL = if_else(student,
                      rowSums(across(num_range("HL_choice", 1:10)) == 2),
                      rowSums(across(num_range("invHL_choice", 1:10)) == 2)),
         EG = if_else(student, EG_choice, invEG_choice),
         ## IG choice expressed in investor euros (students x 4), endowment 24
         IG = if_else(student, GP_choice * 4, invGP_choice),
         soep = as.numeric(survey_risk),
         soep_financial = as.numeric(survey_risk_fin),
         ## one impossible age (120) is set to missing
         age = if_else(as.numeric(age) > 100, NA_real_, as.numeric(age)),
         gender = as.numeric(female),
         ## students: University of Innsbruck; private investors: clients of a German
         ## bank; professional investors: financial firms across the EU (no single country)
         country = case_when(sample == 1 ~ "Austria",
                             sample == 2 ~ "Germany",
                             TRUE ~ NA_character_),
         city = if_else(sample == 1, "Innsbruck", "")) %>% 
  select(subject, HL, EG, IG, soep, soep_financial, age, gender, country, city) %>% 
  pivot_longer(c(HL, EG, IG), names_to = "task", values_to = "choice") %>% 
  filter(!is.na(choice))

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Hackethal2023",
         paper = "Hackethal et al. 2023")

## online experiment, so no lab coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

## the staircase rows, built the same way and appended after the r draws above
fa <- read_dta("Data/Hackethal_et_al_2023/original_dataset.dta") %>% 
  mutate(subject = row_number(),
         student = sample == 1,
         choice = as.numeric(if_else(student, Falk_WTR, invFalk_WTR)),
         soep = as.numeric(survey_risk),
         soep_financial = as.numeric(survey_risk_fin),
         age = if_else(as.numeric(age) > 100, NA_real_, as.numeric(age)),
         gender = as.numeric(female),
         country = case_when(sample == 1 ~ "Austria",
                             sample == 2 ~ "Germany",
                             TRUE ~ NA_character_),
         city = if_else(sample == 1, "Innsbruck", ""),
         task = "CE_staircase",
         bibkey = "Hackethal2023",
         paper = "Hackethal et al. 2023",
         lattitude = '',
         longitude = '') %>% 
  filter(!is.na(choice)) %>% 
  select(subject, soep, soep_financial, age, gender, country, city, task, choice,
         bibkey, paper, lattitude, longitude)
fa <- fa %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))
df <- bind_rows(df, fa)

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Hackethal_et_al_2023/formatted_dataset.csv")
