getConceptNamesFromId <- function(plData, conceptTable) {
  concept_ids <- grep("CONCEPT_ID", colnames(plData), value = TRUE)
  if (length(concept_ids)){
    for (i in concept_ids) {
      orig <- i
      tojoin <- c('CONCEPT_ID')
      names(tojoin) <- orig
      plData <- plData %>%
        dplyr::left_join(., conceptTable, by = tojoin) %>%
        dplyr::select(c(1:grep(i, colnames(.))), CONCEPT_NAME, everything()) %>%
        dplyr::rename_at('CONCEPT_NAME', ~sub("ID", "NAME", i))
    }
  }
  return(plData)
}
