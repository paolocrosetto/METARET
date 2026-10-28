#### Diederich, J., Eckel, C. C., Epperson, R., Goeschl, T. & Grossman, P. J.
#### (2022). Subsidizing unit donations: matches, rebates, and discounts
#### compared. Experimental Economics, 25, 734-758.
#### https://doi.org/10.1007/s10683-021-09732-9
#### Data: heiDATA 10.11588/data/GANTNY (BS_data_noIP_noMTID.dta,
#### WS_data_noIP_noMTID.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## U.S. residents on Amazon Mechanical Turk, two samples: 558 subjects in the
## between-subjects design (4 sessions) and a different sample of 113 in the
## within-subjects design. After the donation decision they chose one of six
## 50/50 gambles, 0.28/0.28, 0.24/0.36, 0.20/0.44, 0.16/0.52, 0.12/0.60 and
## 0.02/0.70 USD (Eckel and Grossman, original amounts / 100), paid.
## choice = gamble number (1 = safe). Four subjects made no choice and are
## dropped. The authors' Risk variable is their CRRA category for the chosen
## gamble, not a questionnaire. Sex: 1 = female. Age was asked only in bands
## (the file holds band midpoints), so it is left empty. The authors already
## replaced IP addresses and MTurk ids and dropped the geolocation.
## original_dataset.csv keeps design, session, the gamble, sex and the age band;
## subjects are row numbers. Online sample, so no city and no coordinates.
df <- read_csv("Data/Diederich_et_al_2022/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 671)

df <- df %>%
  filter(str_detect(gamble, "^Gamble [1-6]$")) %>%
  transmute(subject,
            task = "EG",
            choice = as.integer(str_extract(gamble, "[1-6]")),
            age = NA_real_,
            gender = female,
            country = "United States",
            bibkey = "Diederich2022",
            paper = "Diederich et al. 2022")

stopifnot(nrow(df) == 667)

df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Diederich_et_al_2022/formatted_dataset.csv")
