#### Chlass, N. & Miettinen, T. (2026).
#### Commitment in sequential bargaining - An experiment.
#### Journal of Economic Behavior and Organization, 242, 107360.
#### https://doi.org/10.1016/j.jebo.2025.107360
#### Data: https://osf.io/3skrc (JEBO supplementary material)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(haven)

#### getting the data
## The package ships one file per bargaining role: datasetA.dta holds the 144
## player-A subjects (RoleA == 1) and datasetB.dta the 144 player-B subjects
## (RoleA == 0). The two ID sets are disjoint, so both are needed to reach the
## 288 participants the paper reports (32 per session, three sessions in each of
## three treatments). Both files are in long format, sixteen bargaining rounds
## per subject, while the risk task was played once at the end, so S is constant
## within subject and one row per ID is enough.
A <- read_dta("Data/Chlass_Miettinen_2026/original_playerA.dta")
B <- read_dta("Data/Chlass_Miettinen_2026/original_playerB.dta")

## The risk task, taken from the zTree programs shipped with the package
## (Ultimatum.ztt and the other two, which are identical on this screen):
## ten rows, each a choice between option X, a lottery paying 3.5 ECU with
## probability row/10 and 1.5 ECU otherwise, and option Y, a certain 2.5 ECU.
## In the tenth row option X pays 3.5 ECU for sure, so it dominates Y there.
## The authors describe this as a modified Holt and Laury list, but on this site
## a list that pitches a lottery against a certain amount is a CEPL -- see
## CEPL.md, which covers lists where "the lotteries might change in outcomes or
## in probability" -- while HL is reserved for lists of two lotteries.
##
## S is the row at which the subject first prefers the lottery, so the number of
## risky choices is 11 - S. That is the convention the other CEPL papers use
## (Holzmeister and Stefan 2021 state it explicitly) and the one HL uses.
## S runs from 1 to 11; S == 11 means the subject never took the lottery, which
## in the last row means turning down a certain 3.5 ECU for a certain 2.5 ECU.
## Two subjects did that: a dominated choice, so since 29.10.2026 they are kept
## for the download only, with inconsistent = 1 and choice 0
## (Data/inconsistent_rows.R). The file has S only, so multiple switching cannot
## be seen.
##
## Sex is not labelled in the .dta. The authors enter it unrecoded in their
## regressions and the published tables report that row as "Gender:female",
## so 1 is female. Age and Sex have no missing values.
## ID is a string of session date and seat ("27042011 1"), which the app's
## subject column cannot hold -- it is numeric everywhere else. Subjects are
## numbered instead, sorted by role and then by ID so the numbering is stable
## across rebuilds; the original identifier stays in original_player*.dta.
pick <- function(d) d %>%
  distinct(ID, .keep_all = TRUE) %>%
  arrange(ID) %>%
  transmute(id_orig = as.character(ID),
            choice = 11L - as.integer(S),
            inconsistent = as.numeric(as.integer(S) == 11L),
            age = as.numeric(Age),
            ## 1 - female, 0 - male
            gender = as.numeric(Sex))

df <- bind_rows(pick(A), pick(B)) %>%
  mutate(subject = row_number()) %>%
  select(-id_orig)

# adding task, paper name and bibkey
df <- df %>%
  mutate(task = "CEPL",
         bibkey = "Chlass2026",
         paper = "Chlass and Miettinen 2026")

## Experimental laboratory of the Max Planck Institute of Economics, Jena,
## students of Friedrich Schiller University Jena.
df$country = 'Germany'
df$city = 'Jena'
## The map shows only the country, so no coordinates (removed on 23.10.2026).
df$lattitude = ''
df$longitude = ''

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
source("Data/inconsistent_rows.R")
df$r <- consistent_r(df)   # r for consistent rows only (Data/inconsistent_rows.R)

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Chlass_Miettinen_2026/formatted_dataset.csv")
