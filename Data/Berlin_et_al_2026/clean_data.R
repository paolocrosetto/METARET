#### Berlin, N., Kemel, E., Lenglin, V. & Nebout, A. (2026). Paying none, some or all?
#### Between-subject random incentives and preferences towards risk and time.
#### Journal of Economic Psychology, 112, 102870. https://doi.org/10.1016/j.joep.2025.102870
#### Data: openICPSR, https://doi.org/10.3886/E209071V2 (CC BY 4.0, downloaded by hand)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Data_indiff_rt.rda, risk rows only (four certainty equivalents per subject):
## 335 subjects of the INSEAD-Sorbonne University Behavioral Lab pool, online
## sessions via Zoom. Between-subject probability that the choices are paid:
## treatment 0 (hypothetical), 0.1, 0.5, 1. Only the three paid treatments are kept.
## Only the CE of the lottery 80 EUR with 50%, otherwise 0, is used (one row per
## subject). The CE was found by four bisection questions, so the task is the
## CE staircase (CE_staircase; it was filed as CEPL until 22.10.2026). This is equivalent to a
## list of 15 sure amounts 5, 10, ..., 75 against the lottery with one switch;
## indiff is the midpoint of the final 5-EUR interval (2.5 ... 77.5), so
## choice = number of sure amounts below the CE = (indiff - 2.5) / 5 (0 ... 15).
## No demographics in the file.
df <- read_csv("Data/Berlin_et_al_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>% 
  filter(xA == 80, yA == 0, pA == 50, treatment != "0") %>% 
  transmute(subject = row_number(),
            task = "CE_staircase",
            choice = (indiff - 2.5) / 5,
            country = "France",
            city = "Paris")

# adding paper name and bibkey
df <- df %>% 
  mutate(bibkey = "Berlin2026",
         paper = "Berlin et al. 2026")

## online sessions, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>% 
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Berlin_et_al_2026/formatted_dataset.csv")
