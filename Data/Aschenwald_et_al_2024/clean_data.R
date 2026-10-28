#### Aschenwald, M., Holzknecht, A., Kirchler, M. & Razen, M. (2024). Covariates
#### of behavioral consistency among adolescents. Journal of Behavioral and
#### Experimental Finance, 44, 100986. https://doi.org/10.1016/j.jbef.2024.100986
#### Data: OSF, https://osf.io/wxvc9 (Data and Analysis/Data/raw_data.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Cross-sectional study with 771 Austrian high school students, grades 5 to 12,
## run as an oTree questionnaire in their schools (University of Innsbruck). The
## paper measures financial literacy, a battery of behavioural biases, economic
## preferences and self-reported field behaviour.
##
## Risk task: the authors use "the non-incentivized hypothetical experiment of
## Eckel and Grossman (2002)" -- six gambles between two amounts decided by a
## coin toss, risk_preference is the one chosen (1 = the sure 10 EUR, 6 = the
## widest spread). The six gambles are not printed in the paper; they were read
## off the experimental software shipped with the package (Experimental
## Software.zip, Preferences/templates/Preferences/RiskPreference.html) and are
## quoted in the Aschenwald2024 block of generate_r.R. HYPOTHETICAL payments.
## The template's last change in the software's git history is 27.02.2021,
## before data collection (March-July 2021), and the comprehension check on
## that page (qc counter in the data) makes pupils restate the amounts of the
## chosen gamble, so this is the menu that was run.
##
## Questionnaire: general_risk is "self-assessed willingness to take risks" on
## 0 = not willing to 10 = very willing, which is the SOEP item, so it fills the
## soep slot.
##
## original_dataset.csv keeps the chosen gamble, the survey item, the authors'
## counter of failed comprehension checks on the risk task, age, gender, school
## grade and school type; the financial literacy quiz, the bias battery and the
## other survey items are dropped. Nothing is missing in these columns.
## gender: female = 1, male = 0, the 18 subjects who answered "diverse" = NA.
## All 771 subjects are kept, as in the paper.
df <- read_csv("Data/Aschenwald_et_al_2024/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 771, all(df$risk_preference >= 1 & df$risk_preference <= 6))

df <- df %>%
  transmute(subject,
            task = "EG",
            choice = risk_preference,
            soep = general_risk,
            age,
            gender = case_when(gender == "female" ~ 1,
                               gender == "male" ~ 0,
                               TRUE ~ NA_real_),
            country = "Austria")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Aschenwald2024",
         paper = "Aschenwald et al. 2024")

## schools across Austria, the project is run from Innsbruck
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Aschenwald_et_al_2024/formatted_dataset.csv")
