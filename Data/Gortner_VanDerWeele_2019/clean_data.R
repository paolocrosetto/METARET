#### Gortner, P. J. & van der Weele, J. J. (2019). Peer effects and risk sharing
#### in experimental asset markets. European Economic Review, 116, 129-147.
#### https://doi.org/10.1016/j.euroecorev.2019.04.001
#### Data: Mendeley Data 10.17632/n495wrx5cr (Social_Markets_Data.dta and the
#### authors' do-file)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Sessions "at the Frankfurt Laboratory for Experimental Economic Research at
## the Goethe University Frankfurt, the first 20 in the spring of 2014, additional
## eight sessions in the winter of 2017": 278 subjects. The file has one row per
## subject and trading period; original_dataset.csv keeps one row per subject.
##
## Task: BRET (Crosetto and Filippin 2013), "how many boxes to collect from a pile
## of 36 boxes. With each collected box, subjects earned ... 10 ECU (= 15
## eurocents). One randomly chosen box contained a bomb." As in the authors'
## do-file, the answer is bombchoice in sessions 1-20 and bomb2 in sessions 21-28
## (riska); 7 subjects have none.
##
## gender: 1 = male (133 men, as in the paper's Table 1).
df <- read_csv("Data/Gortner_VanDerWeele_2019/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 278, sum(df$gender == 1) == 133)

df <- df %>%
  filter(!is.na(bret)) %>%
  transmute(subject = id,
            task = "BRET",
            choice = bret,
            age = NA_real_,
            gender = if_else(gender == 1, 0, 1),
            country = "Germany",
            city = "Frankfurt",
            bibkey = "Gortner2019",
            paper = "Gortner and van der Weele 2019")

## the map is drawn by country; the coordinates are those of the lab's city
df$lattitude = '50.1109'
df$longitude = '8.6821'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Gortner_VanDerWeele_2019/formatted_dataset.csv")
