#### Chugunova, M., Nicklisch, A. & Schnapp, K.-U. (2025). The impact of timing
#### and type of donation decision on charitable giving. Social Choice and
#### Welfare, 65, 427-447. https://doi.org/10.1007/s00355-024-01572-9
#### Data: OSF, https://osf.io/pbajr (all_apps_wide-2023-06-01.xlsx)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online oTree experiment on Prolific with UK residents aged 25 to 65 whose
## first language is English, three between-subject donation treatments. The
## repository file holds 600 started sessions; 449 reached the last page, and
## the authors drop five of those who gave a donation far beyond the scale of
## the payment as not having understood the instructions, which leaves the 444
## used here. original_dataset.csv is that file reduced to the treatment, the
## two investment decisions, the Part I score and the demographics.
##
## Task: the Gneezy-Potters (1997) investment game, played first, before the
## real-effort and donation parts. The subject receives 20 pence and may invest
## any share; with probability 0.5 the investment returns 2.5 times itself,
## otherwise it is lost, and whatever was not invested is kept. choice is the
## amount invested, converted to pence. A second investment game later in the
## study is played with money the subject earned rather than with a windfall,
## so it measures entitlement as much as risk and is not used.
##
## The paper's own analysis sample is 437, seven fewer, because it also drops
## subjects whose Part I decoding score is more than three standard deviations
## from the mean. That filter is about performance in a task that came after
## the investment game, so it is not applied here; performance_outlier marks
## those subjects in original_dataset.csv for anyone who wants to.
##
## risk_scale is the general willingness-to-take-risks question on the 0-10
## scale, carried over as soep.
df <- read_csv("Data/Chugunova_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject = row_number(),
            task = "IG",
            choice = round(bet1 * 100),
            soep = if_else(risk_scale >= 0, risk_scale, NA_real_),
            age = q_age,
            gender = case_when(q_gender == "Female" ~ 1, q_gender == "Male" ~ 0,
                               TRUE ~ NA_real_),
            country = "United Kingdom")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Chugunova2025",
         paper = "Chugunova et al. 2025")

## online sample of UK residents, so no city
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Chugunova_et_al_2025/formatted_dataset.csv")
