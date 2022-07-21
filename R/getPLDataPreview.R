getPLDataPreview <- function(connection, databaseSchema, table, personId, conceptIds = c(), domain = c(), filterObservation = FALSE){
  # if filterObservation is TRUE, add OBSERVATION to the list of tables to filter
  # if(filterObservation & !("OBSERVATION" %in% domain))
  #   domain = c(domain, "OBSERVATION")

  if(length(conceptIds)  & table %in% domain){
    columnName =  grep("_CONCEPT_ID", toupper(DatabaseConnector::dbListFields(connection, table)), value = TRUE)[1]
    sql <- 'SELECT * FROM @cdm.@cdm_table WHERE person_id IN (@person_id) AND @column_name IN (@concept_id) LIMIT 5'
    plData <- DatabaseConnector::renderTranslateQuerySql(connection = connection,
                                                         sql = sql,
                                                         cdm = databaseSchema,
                                                         cdm_table = table,
                                                         person_id = personId,
                                                         column_name = columnName,
                                                         concept_id = conceptIds)
  } else {
    sql <- 'SELECT * FROM @cdm.@cdm_table WHERE person_id IN (@person_id) LIMIT 5'
    plData <- DatabaseConnector::renderTranslateQuerySql(connection = connection,
                                                         sql = sql,
                                                         cdm = databaseSchema,
                                                         cdm_table = table,
                                                         person_id = personId)
  }
  return(plData)
}
