## Drichoutis, Andreas and Vassilopoulos, Achilleas (2021)
## Intertemporal stability of survey-based measures of risk and time preferences. Open Science
## Framework. Available at https://osf.io/xkj43/

library(haven)
df <- read_dta("Data/Drichoutis_2021/data and codes/data.dta")

drichoutis = df %>% 
  filter(year == 1) %>% 
  select(id, patience, impulsive, risk, risklottery, gender) %>%
  rename(subject = id,
         soep = risk,
         soep_financial = risklottery,
         soep_patience = patience,
         soep_impulsive = impulsive)

# change gender for 1 - female, 0 - male
drichoutis <- drichoutis %>% 
  mutate(gender = case_when(gender == 0 ~ 1,
                            gender == 1 ~ 0))

# adding paper name and bibkey
drichoutis <- drichoutis %>% 
  mutate(bibkey = "drichoutis2021",
         paper = "Drichoutis et al 2021")
drichoutis$country = 'Greece'
# Order of variables
drichoutis <- drichoutis %>% 
  select(bibkey, paper, subject, everything())

drichoutis %>% write_csv("Data/Drichoutis_2021/data and codes/formatted_dataset.csv")
