#### Jiang, S. & Villeval, M. C. (2024).
#### Dishonesty as a collective-risk social dilemma.
#### Economic Inquiry, 62(3), 1203-1223. https://doi.org/10.1111/ecin.13171
#### Data: https://doi.org/10.3886/E191041 (openICPSR, downloaded by hand --
#### the platform refuses automated access)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)
library(readxl)

#### getting the data
## The die-rolling game is not a risk elicitation task; the Eckel and Grossman
## list played at the start of each session is. Long format, twenty periods per
## subject, 12 sessions of 24 -- 288 subjects, exactly as the paper reports.
## The shipped code book describes 10 sessions and 240 subjects; it predates the
## two No-Lying sessions, which the authors' own do-file does keep (it renumbers
## subjects through session 12).
##
## The .dta in the package carries the raw variable names and an empty sex
## column, so the xlsx is used instead -- it has both GambleChoice and sex.
df <- read_excel("Data/Jiang_Villeval_2024/original_dataset.xlsx")
names(df) <- tolower(names(df))

## Eckel and Grossman (2008), six 50/50 gambles, taken from the package code
## book: 1 (56, 56), 2 (48, 72), 3 (40, 88), 4 (32, 104), 5 (24, 120),
## 6 (4, 140) tokens. Expected values 56, 60, 64, 68, 72, 72 -- options 5 and 6
## share an expected value, the Dave et al. (2010) structure. This is the
## Charness et al. (2019) gamble set multiplied by eight, and the bounds come out
## the same to two decimals, which is a useful check on both.
##
## sex is recorded by z-Tree only in the period where the question was asked
## (period 20) and is zero everywhere else, so it has to be taken from that row
## rather than averaged: 92 subjects answered 1 and the paper's own share of men
## is 31.9%. The code book says 1 is male, so gender is the complement.
## Note that the authors' do-file collapses sex by its mean over all twenty
## periods, which turns a man into 0.05; that is a slip in their replication
## code and is not followed here.
##
## Age is not in the data -- Education is an ordinal 1-8 scale used as a proxy.
df <- df %>%
  mutate(id = paste(session, subject, sep = "-")) %>%
  group_by(id) %>%
  summarise(choice = first(gamblechoice),
            male = max(sex, na.rm = TRUE),
            session = first(session),
            .groups = "drop") %>%
  transmute(subject = row_number(),
            choice = as.numeric(choice),
            age = NA_real_,
            ## 1 - female, 0 - male
            gender = 1 - as.numeric(male),
            session = session)

# adding task, paper name and bibkey
df <- df %>%
  mutate(task = "EG",
         bibkey = "Jiang2024",
         paper = "Jiang and Villeval 2024")

## Two sites: sessions 1-10 at Zhejiang University of Finance and Economics in
## Hangzhou (June 2019), sessions 11-12, the No-Lying treatment, at Shandong
## University in Jinan (October 2022).
df <- df %>%
  mutate(country = 'China',
         city = if_else(session >= 11, 'Jinan', 'Hangzhou'),
         lattitude = '',
         longitude = '') %>%
  select(-session)

## Computing the CRRA (x^r) coefficient of risk aversion from the task data
source("Data/generate_r.R")
df <- df %>% mutate(r = purrr::pmap_dbl(list(bibkey, task, choice), get_r))

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Jiang_Villeval_2024/formatted_dataset.csv")
