#### Holzmeister, F., Holmen, M., Kirchler, M., Stefan, M. & Wengstrom, E.
#### (2023). Delegation Decisions in Finance. Management Science, 69(8),
#### 4828-4844. https://doi.org/10.1287/mnsc.2022.4555
#### Data: OSF, https://osf.io/quxmd
#### (Data/Data Raw/oTree Downloads (task-wise)/t4_survey.csv)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online experiment in Sweden with finance professionals and a general
## population sample, run with Statistics Sweden; the study is about whether
## clients delegate investment decisions to professionals or to algorithms.
## original_dataset.csv is the survey task of the oTree data, reduced to the
## two risk questions and the self-reported investment activity; 960 of the
## participants answered it.
##
## The incentivised part of this study is an allocation task across sets of two
## or five assets, scored by how the portfolio is spread; it is not one of the
## elicitation formats this site inverts, so no CRRA coefficient is computed
## and the rows are marked 'quest_only'. generate_data_for_app.R moves `choice`
## into `soep`.
##
## What is used are the two standard scales, both on 0 to 10 (the wording is in
## the repository's own codebook for the survey task):
##  - risk_gen, "Are you generally a person who is willing to take risks or do
##    you try to avoid taking risks?", carried over as soep;
##  - risk_fin, "I am generally willing to take risks in financial matters.",
##    carried over as soep_financial.
##
## The data carry no age or gender: those come from the Swedish register, which
## the authors are not allowed to share.
df <- read_csv("Data/Holzmeister_et_al_2023/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            choice = risk_gen,
            soep_financial = risk_fin,
            age = NA_real_,
            gender = NA_real_,
            bibkey = "Holzmeister2023",
            paper = "Holzmeister et al. 2023")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

df$country = 'Sweden'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Holzmeister_et_al_2023/formatted_dataset.csv")
