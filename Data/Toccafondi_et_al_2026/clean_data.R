#### Toccafondi, N., Di Paolo, R. & Di Guida, S. (2026). Virtual currencies in
#### online gaming increase the willingness to pay for loot boxes: an
#### experimental analysis. Experimental Economics, 28, 1262-1280.
#### https://doi.org/10.1017/eec.2026.10049
#### Data: https://osf.io/cuvre

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Online experiment in Qualtrics with Prolific workers resident in the United
## Kingdom (the Prolific export in the package has "Country of residence" =
## United Kingdom for everyone), January and June 2023 plus one treatment in
## July 2025. The main task is the willingness to pay for opening a loot box,
## i.e. for a lottery, with the currency varied across treatments; it is the
## treatment outcome and is priced in game currencies, so it is not used.
## The rows are 'quest_only' and generate_data_for_app.R moves `choice` into
## `soep`.
##
## The closing questions (Qualtrics_PDFVersion.pdf): "Please tell us, in
## general, how willing or unwilling you are to take risks. Please use a scale
## from 0 to 10, where 0 means 'completely unwilling to take risks' and a 10
## means you are 'very willing to take risks'. You can also use any numbers
## between 0 and 10" -- the Preference Survey Module version of the SOEP item,
## answered on a slider, hence the decimals (Risk_Taking_Falk_1).
##
## WideData.dta holds the 753 participants who completed the study. Female is
## 1 woman, 0 man, 2 other / not said (NA here); six have no Prolific
## demographics.
##
## The PDF header reads "Experimental Economics (2025), 28"; the DOI and the
## companion paper of the same volume already on the site (Cox2026) carry
## 2026, so the bibkey follows them.
df <- read_csv("Data/Toccafondi_et_al_2026/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 753, all(df$risk_general >= 0 & df$risk_general <= 10))

df <- df %>%
  transmute(subject,
            task = "quest_only",
            ## choice is what generate_data_for_app.R moves into soep
            choice = risk_general,
            gender = case_when(female == 1 ~ 1, female == 0 ~ 0, TRUE ~ NA_real_),
            age,
            bibkey = "Toccafondi2026",
            paper = "Toccafondi et al. 2026")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>% mutate(r = NA_real_)

## online, UK residents
df$country = 'United Kingdom'
df$city = ''
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Toccafondi_et_al_2026/formatted_dataset.csv")
