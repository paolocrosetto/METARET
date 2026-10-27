#### Gill, A., Heinz, M., Schumacher, H. & Sutter, M. (2023). Social Preferences
#### of Young Professionals and the Financial Industry. Management Science, 69.
#### https://doi.org/10.1287/mnsc.2022.4562
#### Data: Management Science replication package (Data Finance Paper Wave 2013.dta)

#### cleaning data to be used for the meta-analysis

#### libraries
library(tidyverse)

#### getting the data
## Students of Goethe University Frankfurt, Germany, surveyed and tested in 2013
## and followed up in 2020. The survey has the willingness to take risks of
## Dohmen et al. (2011), 0-10. Only the 2013 wave (265 students) is used, since
## the 2020 wave re-asks the same people and the files share no id.
## original_dataset.csv keeps semester, age, sex and the answer; subjects are row
## numbers. female: 1 = woman, 0 = man.
df <- read_csv("Data/Gill_et_al_2023/original_dataset.csv", show_col_types = FALSE)

df <- df %>%
  transmute(subject,
            age,
            gender = female,
            choice = risk,
            task = "quest_only",
            country = "Germany")

df <- df %>%
  mutate(r = NA_real_)

# adding paper name and bibkey
df <- df %>%
  mutate(bibkey = "Gill2023",
         paper = "Gill et al. 2023")

## the map shows only the country, so no coordinates
df$lattitude = ''
df$longitude = ''

# Order of variables
df <- df %>%
  select(bibkey, paper, task, subject, age, gender, choice, r, everything())

# Writing to file
df %>% write_csv("Data/Gill_et_al_2023/formatted_dataset.csv")
