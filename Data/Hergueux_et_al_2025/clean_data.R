#### Hergueux, J., Algan, Y., Benkler, Y. & Fuster-Morell, M. (2025). Public good
#### superstars: A lab-in-the-field study of Wikipedia.
#### The Economic Journal, 135, 861-891. https://doi.org/10.1093/ej/ueae093
#### Data: https://doi.org/10.5281/zenodo.13928231 ("Données students Online Lab.dta")

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## The paper's main sample (730 Wikipedia editors, "Base Wikipédia EJ.dta") is not
## in the replication package -- only the 154 students of the online lab that the
## paper uses as a standard subject pool (Table 4). original_dataset.csv keeps
## their risk answer, gender and age; subjects are row numbers. The paper does not
## say where the students were recruited; it takes them from Hergueux & Jacquemet
## (2015, Experimental Economics 18, 251-283), whose working paper (HAL
## halshs-00748615) describes French undergraduates, sessions in November 2010
## and 2011, instructions in French and "not born in France" as a covariate. The
## country is therefore France; no city is given.
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
## The risk item is the SOEP general risk question (Dohmen et al. 2011), from 0 =
## unwilling to 10 = fully prepared to take risks. The student file stores it as
## 1-11; as in the authors' do-file, 1 is subtracted (mean 5.42, as in the paper).
## female: 1 = woman, 0 = man (60% women, as in the paper).
df <- read_csv("Data/Hergueux_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age,
            gender = female,
            choice = risk_1to11 - 1,
            task = "quest_only",
            country = "France")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Hergueux2025",
         paper = "Hergueux et al. 2025")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Hergueux_et_al_2025/formatted_dataset.csv")
