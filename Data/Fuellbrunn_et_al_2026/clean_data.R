#### Füllbrunn, S., Luhan, W. & Mangin, P.-E. (2026).
#### Experimental currency units in investment tasks.
#### Journal of Economic Behavior and Organization, 242, 107400. https://doi.org/10.1016/j.jebo.2025.107400

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The paper has two experiments on Prolific (UK residents, fluent in English):
##  - main experiment (504 subjects): a zero-expected-value Gneezy-Potters task
##    (6 times the investment with a 1-in-6 chance). With zero expected value
##    every risk-averse subject should invest nothing, so the task gives no
##    CRRA intervals for r < 1; it is not used.
##  - robustness check (525 other subjects): the original Gneezy-Potters task.
##    With a 2-in-6 chance the subject gets the endowment PLUS 2.5 times the
##    amount invested, otherwise loses the investment. Steps of 5%. This one is used.
## FLM_00_Robustness data.csv is the authors' cleaned file (IP address and
## location already dropped by the authors). Five treatments only change the
## currency label and its scale (200 Pence, 200 / 2,000 / 20,000 / 200,000 Tokens)
## with the same money at stake; all are kept, as the paper finds no differences.
## choice = % of the endowment invested.
df <- read_csv("Data/Fuellbrunn_et_al_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  transmute(subject = row_number(),
            task = "IG",
            choice = round(sit_inv * 100),
            age = as.numeric(age),
            gender = as.numeric(female),
            country = "United Kingdom",
            city = "")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Fuellbrunn2026",
         paper = "Füllbrunn et al. 2026")

## online experiment, so no lab coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Fuellbrunn_et_al_2026/formatted_dataset.csv")
