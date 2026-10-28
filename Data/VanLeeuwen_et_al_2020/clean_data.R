#### van Leeuwen, B., Offerman, T. & Schram, A. (2020). Competition for status
#### creates superstars: An experiment on public good provision and network
#### formation. Journal of the European Economic Association.
#### https://doi.org/10.1093/jeea/jvz001
#### Data: the journal's supplementary materials (superstars_rawdata.dta,
#### superstars.do, the z-Tree software)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## "Sessions were run between May and July 2014 in the CREED laboratory of the
## University of Amsterdam ... In total, 320 subjects participated." The file has
## one row per subject and period of the network game; original_dataset.csv keeps
## one row per subject (session, ppnr).
##
## Task: before the game, "a procedure similar to Gneezy and Potters (1997) ...
## each subject decided how much to invest of a capital of 600 points. The amount
## invested was lost or multiplied by 2.5 with equal probability." inzet = points
## invested.
##
## sexe: vrouw = woman, man = man. Age is not in the file.
df <- read_csv("Data/VanLeeuwen_et_al_2020/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 320, all(df$inzet >= 0 & df$inzet <= 600))

df <- df %>%
  transmute(subject = row_number(),
            task = "IG",
            choice = inzet,
            age = NA_real_,
            gender = case_when(sexe == "vrouw" ~ 1, sexe == "man" ~ 0),
            country = "Netherlands",
            city = "Amsterdam",
            bibkey = "VanLeeuwen2020",
            paper = "van Leeuwen et al. 2020")

## the map is drawn by country; the coordinates are those of the lab's city
df$lattitude = '52.3676'
df$longitude = '4.9041'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/VanLeeuwen_et_al_2020/formatted_dataset.csv")
