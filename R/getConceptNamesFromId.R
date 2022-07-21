getConceptNamesFromId <- function(plData, connection, cdmDbSchema) {
  concept_ids <- grep("CONCEPT_ID", colnames(plData), value = TRUE)
  if (length(concept_ids)){
    sql <- 'SELECT CONCEPT_ID, CONCEPT_NAME FROM @cdm.CONCEPT WHERE CONCEPT_ID IN (@concept_id)'
    for (i in concept_ids) {
      if(length(na.omit(plData[,i]))){
        conceptTable <- DatabaseConnector::renderTranslateQuerySql(connection = connection,
                                                                   sql = sql,
                                                                   cdm = cdmDbSchema,
                                                                   concept_id = unique(plData[,i]))
      } else {
        conceptTable <- setNames(data.frame(matrix(ncol = 2, nrow = 0)), c("CONCEPT_ID", "CONCEPT_NAME"))
      }

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
