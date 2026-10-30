#### Cortes, P., Pan, J., Pilossoph, L., Reuben, E. & Zafar, B. (2023). Gender
#### Differences in Job Search and the Earnings Gap: Evidence from the Field and
#### the Lab. The Quarterly Journal of Economics, 138(4), 2069-2126.
#### https://doi.org/10.1093/qje/qjad017
#### Data: Harvard Dataverse, https://doi.org/10.7910/DVN/VNKB25
#### (data files/jobsearch_experiment.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online experiment in LIONESS Lab, March and April 2020, with Arizona State
## University undergraduates: a real-effort typing task, then five rounds of
## sequential job search, then the risk elicitation. The repository file holds
## 2,216 subjects across six treatments, of which only treat == 3 is the
## experiment of this paper; dropping the one subject with no gender leaves the
## 346 students (147 men) the paper reports. The other treatments belong to a
## companion study and are not used. original_dataset.csv is that treatment,
## reduced to the risk variables and the demographics.
##
## Task: a twelve-row price list, each row the same lottery -- 50% of $30, 50%
## of nothing -- against a certain payment rising $6, $7, ..., $17. Every
## subject also has a $5 show-up fee, so the lottery pays $35 or $5 in final
## wealth and the certain option $5 + CE. choice is the first certain payment
## chosen, with the authors' corner codes kept: 6 when the certain payment was
## chosen in every row and 18 when the lottery was.
##
## risk_errors counts departures from a single switch. The 41 subjects with any
## are out of the statistics, as multiple switchers are elsewhere in this
## corpus, leaving 305; the paper instead keeps them at their first switch and
## notes its results are unaffected either way. They are kept for the download
## only, with inconsistent = 1 (Data/inconsistent_rows.R): the file has no
## row-by-row answers, only that first switch (risk_ce), so each has one row
## with it as choice, and their later switching points are unknown.
##
## risk_survey is the general willingness-to-take-risks question on the usual
## 0-10 scale, carried over as soep. It runs in the standard direction here:
## its correlation with the certainty equivalent is +0.28, and men average 6.2
## against women's 5.3.
df <- read_csv("Data/Cortes_et_al_2023/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject = row_number(),
            task = "CEPL",
            choice = risk_ce,
            inconsistent = as.numeric(risk_errors > 0),
            soep = risk_survey,
            age,
            gender = female,
            country = "United States",
            city = "Tempe")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Cortes2023",
         paper = "Cortes et al. 2023")

df$lattitude = '33.4242'
df$longitude = '-111.9281'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Cortes_et_al_2023/formatted_dataset.csv")
