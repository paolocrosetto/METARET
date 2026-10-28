#### Chaturvedi, R. & Kanjilal, K. (2021). Experimental analysis of a land assembly
#### mechanism. Journal of Behavioral and Experimental Economics, 91, 101680.
#### https://doi.org/10.1016/j.socec.2021.101680
#### Data: Mendeley Data v68hy8jk93 (Data.xlsx, Variable Description.docx, the
#### z-Tree files, the supplement with the instructions), kept in raw_repository

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Lab sessions at the Indraprastha Institute of Information Technology Delhi
## (IIITD, undergraduates in computer engineering) and the Delhi School of
## Economics (DSE, master's students in economics), after the IRB approval of
## October 10, 2019. Data.xlsx has one row per subject and round of the land
## assembly game, with the same risk answers in every round; original_dataset.csv
## keeps one row per subject (Institution, Round, ID): 173 subjects.
##
## Task: at the end of every session, "Holt and Laury (2002)'s 'menu of lottery
## choices'": "A: INR 80 if throw of die is 1 and INR 64 is throw of die is any
## number from 2 to 10; B: INR 140 if throw of die is 1 and INR 4 ...", the high
## payoff with probability k/10 in row k (Risk Experiment.ztt). One question is
## drawn and paid. rk: 0 = A, 1 = B; choice = number of B choices, as for the other
## HL papers. Only 105 subjects switched once (from A to B); the 68 who switched
## more than once are left out.
##
## gender: Female / Male; age in years.
df <- read_csv("Data/Chaturvedi_Kanjilal_2021/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 173)

hl <- df %>% select(num_range("r", 1:10)) %>% as.matrix()
n_b <- rowSums(hl)
single <- sapply(seq_len(nrow(hl)), function(i)
  identical(unname(hl[i, ]), c(rep(0, 10 - n_b[i]), rep(1, n_b[i]))))
stopifnot(sum(single) == 105, all(n_b[single] >= 1))

df <- df %>%
  filter(single) %>%
  transmute(subject = row_number(),
            task = "HL",
            choice = rowSums(across(num_range("r", 1:10))),
            age,
            gender = case_when(gender == "Female" ~ 1, gender == "Male" ~ 0),
            country = "India",
            city = if_else(Institution == "IIITD", "New Delhi", "Delhi"),
            ## the map is drawn by country; the coordinates are those of the
            ## two institutes
            lattitude = if_else(Institution == "IIITD", "28.5459", "28.6889"),
            longitude = if_else(Institution == "IIITD", "77.2732", "77.2090"),
            bibkey = "Chaturvedi2021",
            paper = "Chaturvedi and Kanjilal 2021")

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Chaturvedi_Kanjilal_2021/formatted_dataset.csv")
