#### Holmen, M., Holzmeister, F., Kirchler, M., Stefan, M. & Wengstrom, E.
#### (2023). Economic preferences and personality traits among finance
#### professionals and the general population.
#### The Economic Journal, 133(654), 2949-2977.
#### https://doi.org/10.1093/ej/uead038
#### Data: https://osf.io/ezxtm (component "Data & Analysis" of project 6rdp8)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Artefactual field experiment in Sweden with two samples: "In total, 298
## financial analysts, investment advisors, traders, fund-managers, and
## financial brokers, and 395 participants from a randomly selected sample of
## the Swedish working population - excluding finance professionals -
## participated in our study." Both are kept, 693 subjects in all; pool is 1
## for the general population and 2 for the professionals.
##
## The risk task is the variable `risk`, labelled in the file "preferences
## towards risks (SCL)" and documented in the package as "Lottery choice task
## a la Eckel/Grossman (2002)", with "choice: id of the chosen lottery (1-6)".
## The six gambles themselves are not in the paper; they were read off the
## oTree app shipped with the project (t3_rls/models.py) and are written into
## the Holmen2023 block of generate_r.R.
##
## risk_skew and loss_skew are the same menu redrawn with skewed and with loss
## outcomes; the site has no slot for either, so they are kept in
## original_dataset.csv for reference only.
##
## GENDER AND AGE ARE DELIBERATELY NOT USED. The package's readme states that
## the register variables may not be shared and that "the register data
## included in this replication package has been replaced by a synthetic copy",
## with one of age, gender and education randomly altered for every single
## observation -- and when gender is the one altered, it is simply reversed.
## About a third of the gender values are therefore wrong, which would corrupt
## the gender analysis, and the ages carry a shift of one or two years. Both
## are left missing rather than silently passed on. The lottery choices
## themselves are the real experimental data and are unaffected.
df <- read_csv("Data/Holmen_et_al_2023/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 693, all(df$risk >= 1 & df$risk <= 6))

df <- df %>%
  transmute(subject,
            task = "EG",
            choice = as.numeric(risk),
            gender = NA_real_,
            age = NA_real_,
            bibkey = "Holmen2023",
            paper = "Holmen et al. 2023")

## nationwide Swedish samples, so no city
df$country = 'Sweden'
df$city = ''
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Holmen_et_al_2023/formatted_dataset.csv")
