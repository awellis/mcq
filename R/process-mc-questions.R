
library(tidyverse)

#' @export
score_a_questions <- function(results, answers) {

    ## convert to long ----
    answers_long <- answers %>%
        select(Serie, starts_with("A_")) %>%
        pivot_longer(-Serie,
                     names_to = "question",
                     values_to = "correct_response")

    results_long <- results %>%
        select(Matrikel, StudisID, Nachname, Vorname, Serie,
               starts_with("A_")) %>%
        pivot_longer(!c(Matrikel, StudisID, Nachname, Vorname, Serie),
                     names_to = "question",
                     values_to = "response")

    ## join results and answers, add indicator column ----
    joined <- results_long %>%
        left_join(answers_long) %>%
        mutate(correct = if_else(response == correct_response, 1, 0))

    joined_wide <- joined %>%
        select(-ends_with("response")) %>%
        pivot_wider(names_from = question,
                    values_from = correct)

    ## count correct responses ----
    total_a_scores <- joined %>%
        group_by(Matrikel, StudisID, Nachname, Vorname) %>%
        summarise(score_a = sum(correct, na.rm = TRUE))

    a_scores <- joined_wide %>%
        left_join(total_a_scores)

    a_scores
}



#' @export
score_k_questions <- function(results, answers) {

    ## convert to long ----
    answers_long <- answers %>%
        select(Serie, starts_with("K_")) %>%
        pivot_longer(-Serie,
                     names_to = "question",
                     values_to = "correct_response")

    results_long <- results %>%
        select(Matrikel, StudisID, Nachname, Vorname, Serie,
               starts_with("K_")) %>%
        pivot_longer(!c(Matrikel, StudisID, Nachname, Vorname, Serie),
                     names_to = "question",
                     values_to = "response")

    ## join results and answers ----
    joined <- results_long %>%
        left_join(answers_long)

    ## separate into question and items ----
    joined <- joined %>%
        mutate(question = str_remove(question, "K_")) %>%
        separate(question,
                 into = c("question_num", "item_num"),
                 sep = "_")

    joined <- joined %>%
        group_by(Matrikel, StudisID, Nachname, Vorname, Serie, question_num) %>%
        mutate(nk = n()) %>%
        ungroup()

    ## score items
    joined <- joined %>%
        mutate(item_score = if_else(response == correct_response, 1/nk, 0))

    final_k_score <- joined %>%
        group_by(Matrikel, StudisID, Nachname, Vorname, Serie, question_num) %>%
        summarise(total = sum(item_score, na.rm = TRUE))

    final_k_score <- final_k_score %>%
        mutate(score = case_when(
            total == 1 ~ 1,
            total == 0.75 ~ 0.5,
            total < 0.75 ~ 0)) %>%
        mutate(question = str_c("K_", question_num)) %>%
        select(-question_num)

    item_k_scores <- final_k_score %>%
        select(-total) %>%
        pivot_wider(names_from = question,
                    values_from = score)

    total_k_scores <- final_k_score %>%
        group_by(Matrikel, StudisID, Nachname, Vorname, Serie) %>%
        summarise(score_k = sum(score, na.rm = TRUE))

    k_scores <-  item_k_scores %>%
        left_join(total_k_scores)

    k_scores
}



#' @export
score_exams <- function(results, answers) {
    #TODO: check results and answer
    #TODO: compute scores with answer labels switched
    a_scores <- score_a_questions(results = results, answers = answers)
    k_scores <- score_k_questions(results = results, answers = answers)

    total <- a_scores %>%
        inner_join(k_scores) %>%
        rename_with(~str_remove(.x, pattern = "score_"),
                    starts_with("score_")) %>%
        mutate(total_score = a + k)

    total
}
