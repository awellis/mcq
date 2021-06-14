#' mcq: A package for evaluating multiple choice test results
#'
#' The mcq package provides three functions:
#' score_a_questions() for 'A' questions, score_k_questions() for 'Kprime'
#' and score_exams(), which calls both of the above and joins their outputs.
#'
#' @section mcq functions:
#' score_a_questions()
#' score_k_questions()
#' score_exams()
#'
#' @docType package
#' @name mcq
#'
#' @importFrom dplyr select group_by summarize mutate left_join arrange inner_join rename_with
#' @importFrom tidyr pivot_longer pivot_wider separate
#' @importFrom stringr str_remove str_c
NULL
#> NULL
