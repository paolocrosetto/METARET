#### Buser, T., Cappelen, A. W. & Tungodden, B. (2025). Fairness and willingness
#### to compete. Experimental Economics, 28, 1022-1040.
#### https://doi.org/10.1017/eec.2025.10011
#### Data: Harvard Dataverse 10.7910/DVN/TMCB3W (Raw data (for import).xlsx and
#### Raw data 2 (for import).xlsx)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## First-year students at NHH Norwegian School of Economics, Bergen, in a
## computer lab, late September and early October 2018 (406) and 2019 (398, two
## of whom did not finish and are dropped by the authors). The incentivized
## choices (Choice1-*, Choice3-*) are between piece rate and a tournament, not
## between lotteries, so there is no risk task. At the end the subjects answered
## the SOEP question (Dohmen et al. 2011), "How do you see yourself: are you
## generally a person who is fully prepared to take risks or do you try to
## avoid taking risks?", 0-10; the 2019 survey stored it as 1-11 and it is moved
## back here, as in the authors' EXEX.do. original_dataset.csv keeps wave,
## treatment, sex, age and the answer; Qualtrics ids and dates are dropped and
## subjects are row numbers.
df <- read_csv("Data/Buser_Cappelen_Tungodden_2025/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 804)

## four people (two per wave) have no answer and nothing else to show
df <- df %>% filter(!is.na(risk_scale))

stopifnot(nrow(df) == 800, all(df$risk_scale %in% 0:10))

df <- df %>%
  transmute(subject,
            age,
            gender = case_when(gender == "female" ~ 1, gender == "male" ~ 0),
            choice = risk_scale,
            task = "quest_only",
            country = "Norway",
            city = "Bergen")

df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "BuserCappelen2025",
         ## "Buser et al. 2025" is already BuserVanVeldhuizen2025; the app
         ## counts papers by this label, so the two would merge into one
         paper = "Buser, Cappelen and Tungodden 2025")

## the map is drawn by country; the coordinates are those of the lab's city
df$lattitude = '60.3913'
df$longitude = '5.3221'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Buser_Cappelen_Tungodden_2025/formatted_dataset.csv")
