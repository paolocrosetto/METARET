#####  Jens Rommel , Daniel Hermann, Malte Mu€ller and Oliver Mußhoff1
## Contextual Framing and Monetary Incentives in Field Experiments on Risk Preferences: Evidence from German Farmers

#### libraries
library(tidyverse)
library(haven)
library(broom)

df <- read.csv("Data/Rommel_et_al_2019/Datensatz_final_June 2016.csv", sep = ";")

## Inconsistent (29.10.2026): the authors' INCONSIST_HLL1 == 1, 13 farmers who
## switched more than once or took A in every row, including row 10 where B
## pays more for sure, were filtered out. They are now kept for the download
## only, with inconsistent = 1 and one row per switch to B (HLL1_1 ... HLL1_10,
## 1 = B; Data/inconsistent_rows.R). choice = number of B choices, as before
## (= 11 - the row where B starts for a single switch).
source("Data/inconsistent_rows.R")
B <- as.matrix(df[paste0("HLL1_", 1:10)])
df = df %>% 
  mutate(subject = 1:nrow(.),
         age = 2019 - f2,
         points = lapply(seq_len(nrow(B)), function(i) switch_points(B[i, ])),
         inconsistent = as.numeric(INCONSIST_HLL1 == 1)) %>%
  rename(gender = f1)  %>%
  ## 1 - females
  mutate(gender = case_when(gender == 2 ~ 1,
                            gender == 1 ~ 0)) %>% 
  select(subject, gender, age, points, inconsistent) %>%
  expand_switches(function(k) if_else(is.na(k), 0, 11 - k)) %>%
  arrange(gender, subject)   # the order of the earlier group_by(gender, ...), so the r draws stay the same
stopifnot(sum(df$inconsistent == 0) == 133)
 

df$task = 'HL'
df$country = 'Germany'

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Rommel2019",
         paper = "Rommel et al. 2019")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Rommel_et_al_2019/formatted_dataset.csv")
