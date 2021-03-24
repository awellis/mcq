
#' @export
score_a <- function(results, answers) {

    ## convert to long ----
    answers_long <- answers %>%
        select(starts_with("A_")) %>%
        pivot_longer(everything(),
                     names_to = "question",
                     values_to = "correct_response")

    results_long <- results %>%
        select(Matrikel, StudisID, Nachname, Vorname,
               starts_with("A_")) %>%
        pivot_longer(!c(Matrikel, StudisID, Nachname, Vorname),
                     names_to = "question",
                     values_to = "response")

    ## join results and answers, add indicator column ----
    joined <- results_long %>%
        left_join(answers_long) %>%
        mutate(correct = if_else(response == correct_response, 1, 0))


    ## count correct responses ----
    a_scores <- joined %>%
        group_by(Matrikel, StudisID, Nachname, Vorname) %>%
        summarise(score_a = sum(correct))

    a_scores
}


#' @export
score_k <- function(results, answers) {

    ## convert to long ----
    answers_long <- answers %>%
        select(starts_with("K_")) %>%
        pivot_longer(everything(),
                     names_to = "question",
                     values_to = "correct_response")

    results_long <- results %>%
        select(Matrikel, StudisID, Nachname, Vorname,
               starts_with("K_")) %>%
        pivot_longer(!c(Matrikel, StudisID, Nachname, Vorname),
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
        group_by(Matrikel, StudisID, Nachname, Vorname, question_num) %>%
        mutate(nk = n()) %>%
        ungroup()

    ## score items
    joined <- joined %>%
        mutate(item_score = if_else(response == correct_response, 1/nk, 0))

    final_K_score <- joined %>%
        group_by(Matrikel, StudisID, Nachname, Vorname, question_num) %>%
        summarise(total = sum(item_score))

    final_K_score <- final_K_score %>%
        mutate(score = case_when(
            total == 1 ~ 1,
            total == 0.75 ~ 0.5,
            total < 0.75 ~ 0))

    k_scores <- final_K_score %>%
        group_by(Matrikel, StudisID, Nachname, Vorname) %>%
        summarise(score_k = sum(score))

    k_scores
}




