## Builds original_dataset.csv for the twelve papers added on 26.10.2026 from
## the raw packages in Data/<folder>/raw_repository/. One row per subject, no
## participant codes, IP addresses or free text. Run from METARET_APP_V2/:
##
##     Rscript Data/make_original_datasets_2026_10_26.R
suppressMessages({library(tidyverse); library(haven); library(readxl)})

D <- "Data"
raw <- function(folder, ...) file.path(D, folder, "raw_repository", ...)
out <- function(df, folder) {
  dir.create(file.path(D, folder), showWarnings = FALSE)
  write_csv(df, file.path(D, folder, "original_dataset.csv"))
  cat(sprintf("%-32s %5d rows\n", folder, nrow(df)))
}

## Diecidue, Guecioueur & Xia 2026 -------------------------------------------
d <- read_csv(raw("Diecidue_et_al_2026",
                        "Trusting the Algorithm A Decision Under Ambiguity - data.csv"),
              show_col_types = FALSE) %>%
  filter(participant._index_in_pages == 444)          # completed, as the authors' script
d %>% transmute(subject = row_number(),
                session_date = as.Date(substr(participant.time_started_utc, 1, 10)),
                risk_general = survey.1.player.risk,
                risk_financial = survey.1.player.financialrisk,
                ## authors' script calls it `male`: 1 male, 0 female, 2 not said
                male = coalesce(ambiguity_task_1.4.player.break_1,
                                ambiguity_task_2.4.player.break_1)) %>%
  out("Diecidue_et_al_2026")

## Toccafondi, Di Paolo & Di Guida 2026 ---------------------------------------
read_dta(raw("Toccafondi_et_al_2026", "DTADataSubmission", "WideData.dta")) %>%
  transmute(subject = row_number(), treatment = as.numeric(treatment),
            year = as.numeric(year),
            risk_general = as.numeric(Risk_Taking_Falk_1),
            age = as.numeric(Age), female = as.numeric(Female)) %>%
  out("Toccafondi_et_al_2026")

## Dalton, Nhung & Ruschenpohler 2020 -----------------------------------------
read_dta(raw("Dalton_et_al_2020", "data", "DATA_raw.dta"), encoding = "latin1") %>%
  filter(!is.na(riskinvest)) %>%
  transmute(subject = row_number(), treatment = as.numeric(TreatmentE0H1),
            riskinvest = as.numeric(riskinvest),
            gender_raw = as.numeric(sesgender),     # 1 female, 2 male (clean_DATA_raw.do)
            birthyear = as.numeric(sesbirthyear)) %>%
  out("Dalton_et_al_2020")

## Haile, Nillesen & Tirivayi 2020 --------------------------------------------
read_dta(raw("Haile_et_al_2020", "Data.dta")) %>%
  transmute(subject = row_number(), wereda = as.numeric(wereda),
            village = as.numeric(village_code),
            sure_20 = as.numeric(sure_20), sure_15 = as.numeric(sure_15),
            sure_10 = as.numeric(sure_10), sure_6 = as.numeric(sure_6),
            sure_2 = as.numeric(sure_2),           # 1 = sure amount, 2 = coin toss
            riskaverspar = as.numeric(riskaverspar),
            age = as.numeric(age), sex = as.numeric(sex)) %>%   # sex: 1 male, 0 female
  out("Haile_et_al_2020")

## Krull, Pelster & Steinorth 2024 --------------------------------------------
krull <- function(f, wave) {
  e <- new.env(); load(raw("Krull_et_al_2024", f), e)
  a <- e$data
  a %>% transmute(wave = wave,
                  finished = participant._current_app_name == "exit_survey",
                  across(all_of(paste0("mpl.1.player.choice_", 1:10)), as.character),
                  risk_self = as.character(welcome.1.player.risk_self_report1),
                  age_bracket = as.character(survey.1.player.age),
                  gender = as.character(survey.1.player.gender))
}
bind_rows(krull("rawdata.RData", "2021-12 / 2022-02"),
          krull("rawdata_endowment.RData", "2023-11")) %>%
  rename_with(~ sub("mpl.1.player.choice_", "hl_", .x)) %>%
  mutate(subject = row_number(), .before = 1) %>%
  out("Krull_et_al_2024")

## Hernandez-Arenaz & Iriberri 2023 -------------------------------------------
h <- read_dta(raw("HernandezArenaz_Iriberri_2023", "Data and Data Analysis",
                        "Bargaining_level_2021.dta"))
bind_rows(h %>% transmute(id = id_proposer, risk = risk_pref_proposer,
                          male = male_proposer, age = edad_proposer, bilbo, session = `_1042`),
          h %>% transmute(id = id_responder, risk = risk_pref_responder,
                          male = male_responder, age = edad_responder, bilbo, session = `_1042`)) %>%
  distinct() %>%
  { stopifnot(!any(duplicated(.$id))); . } %>%
  transmute(subject = row_number(), session, bilbao = as.numeric(bilbo),
            risk_pref = as.numeric(risk), male = as.numeric(male), age = as.numeric(age)) %>%
  out("HernandezArenaz_Iriberri_2023")

## Ihli et al. 2022 -----------------------------------------------------------
read_dta(raw("Ihli_et_al_2022", "IHLI-DCE_data.dta")) %>%
  group_by(personid) %>%
  summarise(lottery = first(as.numeric(risk)), n_lot = n_distinct(risk), .groups = "drop") %>%
  { stopifnot(all(.$n_lot == 1)); . } %>%
  transmute(subject = row_number(), lottery) %>%
  out("Ihli_et_al_2022")

## Banerjee, Cason, de Vries & Hanley 2021 ------------------------------------
read_dta(raw("Banerjee_et_al_2021", "subjects.dta")) %>%
  group_by(subjID) %>%
  summarise(session = first(session),
            ## the questionnaire answer is -1 (z-Tree default) before it is filled in
            risk_general = suppressWarnings(max(Risk[Risk >= 0])),
            n_risk = n_distinct(Risk[Risk >= 0]),
            gamble = first(RiskChoice), n_gamble = n_distinct(RiskChoice), .groups = "drop") %>%
  { stopifnot(all(.$n_risk <= 1), all(.$n_gamble == 1)); . } %>%
  mutate(risk_general = if_else(is.finite(risk_general), risk_general, NA_real_)) %>%
  transmute(subject = row_number(), session, gamble = as.numeric(gamble), risk_general) %>%
  out("Banerjee_et_al_2021")

## Mittone & Papi 2020 --------------------------------------------------------
m <- read_excel(raw("Mittone_Papi_2020",
  "urn_cambridge.org_id_binary_20240508070350973-0384_S1930297500007178_S1930297500007178sup001.xlsx"),
  sheet = "Raw_Dataset")
## 18 rows per subject. One nickname in session 2 has 17 rows saying male, 21,
## BRET 34 and a single row saying female, 22, BRET 25 -- one subject with one
## corrupted row (226 subjects either way, as in the paper), so the modal row wins.
mode1 <- function(x) names(sort(table(x), decreasing = TRUE))[1]
m %>% group_by(code = `EXP.SUBJECT CODE`) %>%
  summarise(treatment = first(TREATMENT), session = first(SESSION),
            n_bret = n_distinct(BRET), bret = as.numeric(mode1(BRET)),
            female = as.numeric(mode1(`GENDER(F=1)`)), age = as.numeric(mode1(AGE)),
            .groups = "drop") %>%
  transmute(subject = row_number(), treatment, session, n_bret, bret, female, age) %>%
  out("Mittone_Papi_2020")

## Bauer, Chytilova & Miguel 2020 ---------------------------------------------
read_dta(raw("Bauer_et_al_2020", "Validation_Dataset.dta")) %>%
  transmute(survey_id = as.numeric(survey_id),
            risk_qual = as.numeric(s_risk_qual),
            e_risk = as.numeric(e_risk), e_risk_incons = as.numeric(e_risk_incons),
            s_age = as.numeric(s_age), e_birthyear = as.numeric(e_birthyear),
            s_gender = as.character(as_factor(s_gender)),
            e_gender = as.character(as_factor(e_gender))) %>%
  arrange(survey_id) %>%
  ## survey_id 142149 appears four times with the same experimental record, the
  ## same risk answer, age and gender, differing only in other survey items --
  ## one person's experiment merged onto several survey records. Kept once.
  distinct(survey_id, .keep_all = TRUE) %>%
  mutate(subject = row_number(), .before = 1) %>%
  select(-survey_id) %>%
  out("Bauer_et_al_2020")

## Charness, Chemaya & Trujano-Ochoa 2023 -------------------------------------
read_csv(raw("Charness_et_al_2023", "ExperienceRisk.csv"), show_col_types = FALSE) %>%
  transmute(subject = row_number(), session = Session,
            gamble_first = Gamble.1, gamble_final = Gamble.2,
            age = Age, gender = Gender) %>%
  out("Charness_et_al_2023")

## Pitts, Boyd & Storer 2025 --------------------------------------------------
read_dta(raw("Pitts_et_al_2025", "data", "master_participants_reduced.dta")) %>%
  transmute(subject = row_number(), region = as.numeric(region),
            game_order = as.character(game_order), extra_income = as.numeric(extra2),
            lottery = as.numeric(lottery), crra_authors = as.numeric(crra),
            female = as.numeric(female), age = as.numeric(edad)) %>%
  out("Pitts_et_al_2025")
