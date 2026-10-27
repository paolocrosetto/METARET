#### Halim, E., Riyanto, Y. E. & Roy, N. (2019). Costly information acquisition,
#### social networks, and asset prices: Experimental evidence. The Journal of
#### Finance, 74(4), 1975-2010.
#### https://doi.org/10.1111/jofi.12768
#### Data: Wiley supporting information jofi12768-sup-0002-suppmat (costlyinf_subj.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv keeps one row per participant from costlyinf_subj.dta
## (which repeats each of them over the 12 market periods): 192 undergraduates at
## Nanyang Technological University, Singapore, 8 z-Tree sessions of 24, paid in
## SGD. subject is the authors' subjectid (1-192).
## The paper calls the risk task Holt-Laury, but the z-Tree program
## (costlyinfo.ztt, stage "Risk elicitation") is the same probability-equivalent
## list as in Halim et al. 2025: in rows 1-10, option A pays 1 SGD for sure and
## option B pays 3 SGD with probability 0, 0.1, ..., 0.9 (else 0). It pitches a
## sure amount against a lottery, so it is grouped with the CEPL tasks.
## The program forces a single switch from A to B and saves the switching point
## (riskaversion): 1 = B already in row 1, k = 2..10 = A in row k - 1 and B in
## row k, 11 = A in all rows. choice = switching point. The 4 subjects with 1
## chose B at probability 0, a dominated choice, and are dropped.
## female: 1 = female, 0 = male (the authors' gender is 1 = male).
df <- read_csv("Data/Halim_et_al_2019/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  filter(switch_point > 1) %>%
  transmute(subject,
            task = "CEPL",
            choice = switch_point,
            age,
            gender = female,
            country = "Singapore")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Halim2019",
         paper = "Halim et al. 2019")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Halim_et_al_2019/formatted_dataset.csv")
