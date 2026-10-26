#### Gonzalez-Jimenez, D., Capozza, F., Dirkmaat, T., van de Veer, E., van Druten, A. & Baillon, A. (2025).
#### Falling and failing (to learn): Evidence from a nation-wide cybersecurity field experiment with SMEs.
#### Journal of Economic Behavior and Organization, 230, 106868. https://doi.org/10.1016/j.jebo.2024.106868
#### Data: https://doi.org/10.25397/eur.28123376 (Data_individueel_DEF.ods)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv is built from the authors' employee-level file
## Data_individueel_DEF.ods (sheet "Data"): employees of Dutch SMEs who answered
## at least one of the two post-treatment questionnaires (2021). Group 5 is
## dropped, as in the authors' Dataset_preparation.R (it was used for technical
## tests). The company id and the "E-mail > ID" column (which holds some real
## e-mail addresses) were not copied, nor any click/tracking data.
## One answer per person: the first questionnaire (Q1.x) when answered,
## otherwise the second one (Q2.x); `questionnaire` says which.
##
## This paper contributes questionnaire answers only -- there is no incentivised
## risk elicitation task -- so the rows are marked 'quest_only'.
## generate_data_for_app.R moves `choice` into `soep` for those rows.
## risk: "In general, to what extent are you willing or unwilling to take
## risks?" 0 = not at all willing, 10 = very willing (paper, footnote 8).
## gender: "Vrouw" = 1, "Man" = 0, "Anders" = NA.
## age was asked in brackets; the midpoints used by the authors are kept
## ("Jonger dan 18" = 17, "65 jaar of ouder" = 67).
df <- read_csv("Data/Gonzalez_Jimenez_et_al_2025/original_dataset.csv", show_col_types = FALSE)

age_mid <- c("Jonger dan 18" = 17, "18-24 jaar" = 21, "25-29 jaar" = 27, "30-34 jaar" = 32,
             "35-39 jaar" = 37, "40-44 jaar" = 42, "45-49 jaar" = 47, "50-54 jaar" = 52,
             "55-59 jaar" = 57, "60-64 jaar" = 62, "65 jaar of ouder" = 67)

df <- df %>%
  transmute(subject = row_number(),
            age = unname(age_mid[age_bracket]),
            gender = case_when(gender == "Vrouw" ~ 1, gender == "Man" ~ 0, TRUE ~ NA_real_),
            choice = risk,
            task = "quest_only")

## no task, so no CRRA coefficient: generate_r.R is deliberately not sourced
df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "GonzalezJimenez2025",
         paper = "Gonzalez-Jimenez et al 2025")

## field experiment with SMEs across the Netherlands
df$country = 'Netherlands'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Gonzalez_Jimenez_et_al_2025/formatted_dataset.csv")
