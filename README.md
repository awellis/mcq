# mcq R package

Process and score **m**ultiple **c**hoice **q**uestions


## Installation

```r
remotes::install_github("awellis/mcq")
```

## Usage

Load packges:
```r
library(tidyverse)
library(mcq)
```
 
Read in exam results and answers from Excel spreadsheet:
```r
results <- readxl::read_excel("Ergebnisse.xlsx",
                              sheet = "Antworten") %>%
    select(Matrikel, StudisID, Nachname, Vorname, Serie,
           starts_with("A_"), starts_with("K_"))

 

answers <- readxl::read_excel("Ergebnisse.xlsx",
                              sheet = "Loesung") %>%
    select(Serie, starts_with("A_"), starts_with("K_"))
```
 
 
Combine `A` and `K'` question results:
```r
exam_results <- score_exams(results = results, answers = answers)
```
