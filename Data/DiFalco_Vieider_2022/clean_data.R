#### Di Falco, S. & Vieider, F. M. (2022). Environmental adaptation of risk preferences.
#### The Economic Journal, 132(648), 2737-2766. https://doi.org/10.1093/ej/ueac030
#### Data: replication package (data.csv), downloaded from Zenodo by hand

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## data.csv is a panel of subsistence farmers in 20 woredas (districts) of the
## Ethiopian highlands, three waves (2013, 2015, 2017), 14 incentivized certainty
## equivalents per person and wave. Amounts in the file are birr divided by 6.
## Only one CE per person is used: the 50/50 prospect paying 120 birr or 0
## (equiv_nr 3, stored as high = 20, low = 0), in the first wave (2013): 889
## farmers. original_dataset.csv keeps only these rows and the district, CE and
## gender (no household ids; ages in the file are not usable).
## The CE comes from a list of sure amounts from 0 to 120 birr in steps of 3 birr
## (0.5 in file units); `equivalent` is the midpoint of the switching interval,
## 0.25, 0.75, ..., 19.75. choice = number of the interval (0 ... 39), so the CE
## lies in [0.5 choice, 0.5 choice + 0.5]. Check: the authors' rt = equivalent / 20.
## gender: "Female" = 1, "Male" = 0.
df <- read_csv("Data/DiFalco_Vieider_2022/original_dataset.csv", show_col_types = FALSE)

stopifnot(all(df$high == 20 & df$low == 0 & df$probability == 0.5))

df <- df %>%
  transmute(subject,
            task = "CEPL",
            choice = round((equivalent - 0.25) / 0.5),
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0, TRUE ~ NA_real_),
            country = "Ethiopia")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "DiFalco2022",
         paper = "Di Falco and Vieider 2022")

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
df %>% write_csv("Data/DiFalco_Vieider_2022/formatted_dataset.csv")
