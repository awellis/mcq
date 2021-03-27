## read data ----
library(tidyverse)

results <- readxl::read_excel("~/GitHub/projects/multiple-choice/data/HS2019-1 Emot Ergebnisse.xlsx",
                              sheet = "Antworten") %>%
    select(Matrikel, StudisID, Nachname, Vorname, Serie,
           starts_with("A_"), starts_with("K_"))

answers <- readxl::read_excel("~/GitHub/projects/multiple-choice/data/HS2019-1 Emot Ergebnisse.xlsx",
                              sheet = "Loesung") %>%
    select(Serie, starts_with("A_"), starts_with("K_"))


exam_results <- score_exams(results = results, answers = answers)
