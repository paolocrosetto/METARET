#### Barreda-Tarrazona, I., García-Gallego, A., García-Segarra, J. & Ritschel, A. (2022).
#### A gender bias in reporting expected ranks when performance feedback is at stake.
#### Journal of Economic Psychology, 90, 102505. https://doi.org/10.1016/j.joep.2022.102505
#### Data: https://osf.io/98vxa/ (view-only link from the paper)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## RankingDeprivation.csv, the authors' file (one row per subject, no personal data):
## 200 students, 5 sessions at LEE, Universitat Jaume I (Castellón), z-Tree.
## Task 2 was the standard Holt-Laury list; RiskAttitude = number of safe
## lotteries chosen (codebook), so choice = number of risky choices = 10 - RiskAttitude.
## Female: 1 = woman, 0 = man. Age was not published.
df <- read_csv("Data/Barreda_Tarrazona_et_al_2022/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = Subject,
            task = "HL",
            choice = 10 - RiskAttitude,
            gender = Female,
            country = "Spain",
            city = "Castellon")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "BarredaTarrazona2022",
         paper = "Barreda-Tarrazona et al. 2022")

## lab experiment, but the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Barreda_Tarrazona_et_al_2022/formatted_dataset.csv")
