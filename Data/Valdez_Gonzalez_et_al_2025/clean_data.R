#### Valdez Gonzalez, N. I., Brown, A. L. & Palma, M. A. (2025). Social-benefits
#### stigma and subsequent competitiveness.
#### Economic Inquiry, 63, 903-925. https://doi.org/10.1111/ecin.13293
#### Data: openICPSR, https://doi.org/10.3886/E217164V2 (downloaded by hand; the
#### 5 GB of facial-expression sensor recordings in the package are not needed)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## original_dataset.csv is built from the authors' full_sample.dta (oTree export,
## one row per subject): 276 students, 31 sessions in Fall 2019 at the Human
## Behavior Lab, Texas A&M University. Only the session (renumbered), sex, study
## year and the ten Holt-Laury answers were kept; participant codes, labels and
## IP addresses were dropped.
## Holt-Laury list (oTree app "mpl", config.py): the standard table, A = 2.00 / 1.60,
## B = 3.85 / 0.10, one row per page; hl_k = "A" or "B". choice = number of B
## choices. Check: the mean number of safe choices is 5.14, as in the paper.
## sex: "F" = 1, "M" = 0. Age was not asked (only the year of study).
df <- read_csv("Data/Valdez_Gonzalez_et_al_2025/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            task = "HL",
            choice = rowSums(across(starts_with("hl_")) == "B"),
            gender = case_when(sex == "F" ~ 1, sex == "M" ~ 0, TRUE ~ NA_real_),
            country = "United States",
            city = "College Station")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "ValdezGonzalez2025",
         paper = "Valdez Gonzalez et al. 2025")

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
df %>% write_csv("Data/Valdez_Gonzalez_et_al_2025/formatted_dataset.csv")
