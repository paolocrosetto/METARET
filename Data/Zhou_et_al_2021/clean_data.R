#### Zhou, R., Myung, J. I., Mathews, C. A. & Pitt, M. A. (2021).
#### Assessing the validity of three tasks of risk-taking propensity.
#### Journal of Behavioral Decision Making, 34(4), 555-567.
#### https://doi.org/10.1002/bdm.2229
#### Data: https://osf.io/92hkt

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The paper compares three balloon-style tasks -- the BART, the C-ART and the
## S-ART -- against self-report scales. Only the BART is a task this site
## collects, so only it is kept; the C-ART and the S-ART have no entry here.
##
## 251 students took part, split into a BART group (57), a C-ART group (64), an
## S-ART group (63) and a group that did all three (67). The shared file holds
## the BART group only: ids g1001 to g1058 with four gaps, 54 subjects. The
## three-task group, which would have put the same people in several cells, is
## not in it.
df <- read_csv("Data/Zhou_et_al_2021/original_dataset.csv", show_col_types = FALSE)

## BARTscore is the adjusted score, the mean number of pumps over the trials
## that did not burst -- the standard BART statistic and the one generate_r.R
## inverts. The file also carries the four fitted parameters of the Wallsten
## model (BARTgplus, BARTbeta, BARTalpha, BARTmu), which are a different
## measure and are not used.
##
## The three questionnaires in the file -- the Eysenck impulsivity subscale,
## a sensation seeking scale and the DAST-10 drug abuse screen -- are left out.
## The site's BSSS, BIS, AuditS and CDCrisk columns belong to Fairley and
## Parelman's specific instruments, and these are not the same ones.
##
## No gender or age: the file has neither, and the paper reports them only in
## aggregate for all 251 participants (mean age 21, 137 women).
df <- df %>%
  transmute(subject = row_number(),
            task = "BART",
            choice = BARTscore,
            gender = NA_real_,
            age = NA_real_,
            bibkey = "Zhou2021",
            paper = "Zhou et al. 2021")

## The Ohio State University, Columbus. The map shows only the country, so no
## coordinates (removed on 23.10.2026).
df$country = 'United States'
df$city = 'Columbus'
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Zhou_et_al_2021/formatted_dataset.csv")
