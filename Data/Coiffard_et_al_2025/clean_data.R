#### Coiffard, A., Preget, R. & Tidball, M. (2025). Target versus budget
#### reverse auctions: an online experiment using the strategy method.
#### Experimental Economics, 28, 936-951.
#### https://doi.org/10.1017/eec.2025.10031
#### Data: replication package of the article (1-experiment, 2-raw_data,
#### 3-analysis_results)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online procurement-auction experiment run in 2021 on the French crowdworking
## platform FouleFactory (now Wirk), 329 participants. The experiment itself
## asks for a whole bidding strategy by the strategy method -- a bid for each of
## 21 cost levels -- and compares a target auction with a budget auction. That
## is not a risk elicitation, so the rows are 'quest_only' and
## generate_data_for_app.R moves `choice` into `soep`.
##
## The closing questionnaire carries the general SOEP risk item, asked in French
## and quoted here from the oTree code shipped with the package
## (1-experiment/oTree/expeO/models.py, field choix_risque):
##   "De maniere generale, etes-vous pret a prendre des risques ou essayez-vous
##    de les eviter autant que possible ? (De 0 : J'evite les risques autant que
##    possible, a 10 : Je suis tres a l'aise avec l'idee de prendre des risques)"
## with choices = range(0, 11), so the usual 0 to 10 scale and the usual
## direction. It is Risk_aversion in the authors' cleaned file -- a misleading
## name, since a high value means a WILLINGNESS to take risks.
##
## original_dataset.csv is the five columns needed out of 3-analysis_results/
## data/data.csv (one row per subject).
df <- read_csv("Data/Coiffard_et_al_2025/original_dataset.csv", show_col_types = FALSE)

## the paper's own figures: 329 subjects, average age 41, 50.8% women
stopifnot(nrow(df) == 329,
          all(df$Risk_aversion >= 0 & df$Risk_aversion <= 10),
          abs(mean(df$Female) - 0.508) < 0.005)

df <- df %>%
  transmute(subject = row_number(),
            task = "quest_only",
            ## choice is what generate_data_for_app.R moves into soep
            choice = as.numeric(Risk_aversion),
            gender = as.numeric(Female),
            age = as.numeric(Age),
            bibkey = "Coiffard2025",
            paper = "Coiffard et al. 2025")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## French crowdworking platform, nationwide, so no city
df$country = 'France'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Coiffard_et_al_2025/formatted_dataset.csv")
