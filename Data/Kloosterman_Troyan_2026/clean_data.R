#### Kloosterman, A. & Troyan, P. (2026). Rankings-dependent preferences: A real
#### goods matching experiment. Games and Economic Behavior, 155, 167-191.
#### https://doi.org/10.1016/j.geb.2025.10.008
#### Data: Mendeley Data, https://doi.org/10.17632/nx38rwmsgv.1 (All_Data.txt)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Real goods matching experiment at the University of Virginia VeconLab,
## undergraduates from the Darden BRAD recruitment pool, 200 participants in two
## between-subject treatments (RSD and Boston), 100 each. The risk task is one
## of the last two tasks of Phase I and is the same in both treatments.
## original_dataset.csv is All_Data.txt of the repository reduced to the session
## and subject identifiers, the risk list answer and age.
##
## Task: a Holt-Laury list of fifty rows, lottery A paying $24.00 with x% and
## $20.00 otherwise against lottery B paying $38.00 with x% and $12.00
## otherwise, x rising 2, 4, ..., 100 percent. Subjects named the last row in
## which they preferred A, which is choice here (the stored LotterySwitchProb).
##
## The seven subjects who answered 50 preferred a certain $24 to a certain $38
## in the last row, which is dominated, so they are out of the statistics and
## 193 remain; the seven are kept for the download only, with inconsistent = 1
## and choice 50 (Data/inconsistent_rows.R). The file has the stated row only,
## so multiple switching cannot occur.
## The loss aversion task that follows is not an individual risk elicitation and
## is not used.
##
## The questionnaire asked ten demographic items and the package stores them
## only as demographics[1] ... demographics[10], with no key in the paper, the
## arXiv version or the Elsevier supplement (which is just the IRB certificate).
## demographics[4] is age from its values. demographics[5] was identified as
## gender by re-running the authors' own probits: with the Phase II ranking read
## as position -> good under the mapping 1 = mug, 2 = backpack, 3 = pens,
## 4 = water bottle, 5 = notebook, all eighteen truth-telling rates of Table 2
## come back, and the dummy for demographics[5] == 2 reproduces every
## coefficient of Tables 3, 6 and 7, column 5, to four decimals. So 1 is male
## (68), 2 female (129) and 3 a third answer (3 subjects); the authors' own
## female dummy puts those three with the men, which is left missing here.
df <- read_csv("Data/Kloosterman_Troyan_2026/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject = row_number(),
            task = "HL",
            choice = lottery_switch_row,
            inconsistent = as.numeric(lottery_switch_row == 50),
            age = if_else(age == 0, NA_real_, as.numeric(age)),
            gender = case_when(gender_raw == 2 ~ 1, gender_raw == 1 ~ 0, TRUE ~ NA_real_),
            country = "United States",
            city = "Charlottesville")

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Kloosterman2026",
         paper = "Kloosterman and Troyan 2026")

df$lattitude = '38.0336'
df$longitude = '-78.5080'

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Kloosterman_Troyan_2026/formatted_dataset.csv")
