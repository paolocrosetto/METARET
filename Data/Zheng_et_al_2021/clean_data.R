#### Zheng, K., Wang, X. & Ni, D. (2021). Reciprocity information and wage
#### personalization. China Economic Review, 68, 101645.
#### https://doi.org/10.1016/j.chieco.2021.101645
#### Data: Mendeley Data 10.17632/ksb6gvzcm9 (survey2.dta, data.dta,
#### analysis_new10.do)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "106 subjects from eight sessions" of a trust game and a principal-agent game
## in z-Tree; the lab is "redacted for anonymous review" in the paper, the
## authors are at the University of Electronic Science and Technology of China
## (Chengdu). survey2.dta holds the final questionnaire, one row per subject.
##
## Task: "a risk-preference test (Eckel & Grossman, 2008)" in the questionnaire,
## five 50/50 gambles in yuan: 100/100, 180/60, 260/20, 340/-20 and 420/-60, coded
## 1-5 as in the authors' do-file (risk2). It was HYPOTHETICAL: only "Stage One
## and one randomly selected round in Stage Two were used for each participant's
## payment" and average earnings were 36 yuan, against gambles of up to 420 yuan
## and losses of 60. As for Hamman2023, adding the largest loss (60) gives
## 160/160, 240/120, 320/80, 400/40, 480/0, the canonical Eckel-Grossman table
## times 40, so the task is filed as EG_loss with the canonical bounds.
##
## gender: female / male. birthyear is in the file, but the sessions are not
## dated, so age is left empty.
df <- read_csv("Data/Zheng_et_al_2021/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 106, all(df$gamble %in% 1:5))

df <- df %>%
  transmute(subject = row_number(),
            task = "EG_loss",
            choice = gamble,
            age = NA_real_,
            gender = case_when(gender == "female" ~ 1, gender == "male" ~ 0),
            country = "China",
            city = "Chengdu",
            bibkey = "Zheng2021",
            paper = "Zheng et al. 2021")

## the map is drawn by country; the coordinates are those of the authors'
## university city (the paper does not name the lab)
df$lattitude = '30.5728'
df$longitude = '104.0668'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Zheng_et_al_2021/formatted_dataset.csv")
