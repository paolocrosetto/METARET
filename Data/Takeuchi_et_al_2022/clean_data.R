#### Takeuchi, A., Veszteg, R. F., Kamijo, Y. & Funaki, Y. (2022). Bargaining
#### over a jointly produced pie: The effect of the production function on
#### bargaining outcomes. Games and Economic Behavior, 134, 169-198.
#### https://doi.org/10.1016/j.geb.2022.03.016
#### Data: Harvard Dataverse 10.7910/DVN/7ZLB4J (all_data2.csv,
#### Questionnaire_Paper.docx)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## 236 students (143 men, 93 women) in 9 sessions at the experimental
## laboratory of the Faculty of Political Science and Economics, Waseda
## University, Tokyo, July-November 2018. There is no incentivized risk task;
## question 5 of the post-experimental questionnaire is the SOEP question
## (Dohmen et al. 2011), "How do you see yourself: are you a person who is
## generally willing to take risks, or do you try to avoid taking risks?",
## 0-10 (mean 4.61, as in the paper). 11 subjects left it blank (* in the file)
## and are dropped; one answered 2.5, which is kept.
## Gender is in Japanese in the file (female / male). original_dataset.csv
## keeps one row per subject: session, treatment, the answer, sex and age;
## subjects are row numbers.
df <- read_csv("Data/Takeuchi_et_al_2022/original_dataset.csv", show_col_types = FALSE)

stopifnot(nrow(df) == 236, abs(mean(df$risk, na.rm = TRUE) - 4.61) < 0.01)

df <- df %>%
  filter(!is.na(risk)) %>%
  transmute(subject,
            age,
            gender = case_when(gender == "female" ~ 1, gender == "male" ~ 0),
            choice = risk,
            task = "quest_only",
            country = "Japan",
            city = "Tokyo")

stopifnot(nrow(df) == 225)

df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Takeuchi2022",
         paper = "Takeuchi et al. 2022")

## the map is drawn by country; the coordinates are those of the lab's city
df$lattitude = '35.6762'
df$longitude = '139.6503'

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Takeuchi_et_al_2022/formatted_dataset.csv")
