#### Vieider, F. M., Lefebvre, M., Bouchouicha, R., Chmura, T., Hakimov, R.,
#### Krawczyk, M. & Martinsson, P. (2015). Common components of risk and
#### uncertainty attitudes across contexts and domains: evidence from 30
#### countries. Journal of the European Economic Association, 13(3), 421-452.
#### https://doi.org/10.1111/jeea.12102
#### Data: DATA_LOSS.csv from the replication package of Bouchouicha et al.
#### (2019), "Gender effects for loss aversion: yes, no, maybe?", JRU 59(2),
#### which re-analyses this experiment; the same package is redistributed with
#### Georgalos (2024), https://osf.io/7fvja. The same experiment is also the
#### basis of l'Haridon & Vieider, "All over the map".

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab experiment with students at major universities in 30 countries, run
## between September 2011 and October 2012; 2,939 subjects in the paper, 2,927
## in this file. Each subject gave certainty equivalents for 44 binary prospects
## (gains and losses, known and vague probabilities); payoffs were converted
## with World Bank PPP rates and stated in PPP euros. One of the 44 decisions
## was drawn and played for real money at the end (expected payoff about 15 EUR
## for a risk neutral subject, show-up fee 4 EUR).
##
## Only one prospect is used here, the one the site can price without further
## assumptions: task 3, the 50/50 prospect paying 20 or 0 PPP euros
## (Table A.1 of the paper, (20, 1/2; 0); Table 1 of Georgalos 2024 for the
## column names of this file). The subject chose between the prospect and a list
## of sure amounts running from the low to the high outcome, and the authors
## recorded the CE as the midpoint of the switching interval. Multiple switching
## was ruled out by the instructions and nobody was excluded.
## The 40 distinct values of task3 are exactly 0.25, 0.75, ..., 19.75, so the
## step of the list was 0.5: choice = number of the interval (0 ... 39) and the
## CE lies in [0.5 choice, 0.5 choice + 0.5]. This is the same prospect, the
## same list and the same coding as in Di Falco & Vieider 2022 (DiFalco2022).
## The remaining 43 prospects (the 1/8 ... 7/8 probabilities, the loss domain
## and the mixed prospect) are in the package but need probability weighting or
## loss aversion to be interpreted, so they are left out.
## original_dataset.csv keeps the subject number, this CE, the authors' female
## and age variables and the country name; the other 43 CEs and the 30 country
## dummies are dropped.
df <- read_csv("Data/Vieider_et_al_2015/original_dataset.csv", show_col_types = FALSE)

stopifnot(all(abs((df$equivalent - 0.25) / 0.5 - round((df$equivalent - 0.25) / 0.5)) < 1e-9))

df <- df %>%
  transmute(subject,
            task = "CEPL",
            choice = round((equivalent - 0.25) / 0.5),
            age,
            gender = female,
            country = case_when(country == "UK" ~ "United Kingdom",
                                country == "USA" ~ "United States",
                                TRUE ~ country))

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Vieider2015",
         paper = "Vieider et al. 2015")

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
df %>% write_csv("Data/Vieider_et_al_2015/formatted_dataset.csv")
