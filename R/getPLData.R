getPLData <- function(connection, columns, databaseSchema, table, personId, conceptIds = c(), domain = c()) {

  if(length(conceptIds)  & table %in% domain){
    columnName =  grep("_CONCEPT_ID", toupper(DatabaseConnector::dbListFields(connection, table)), value = TRUE)[1]
    sql <- paste0('SELECT ', paste(columns, collapse = ", ") ,' FROM @cdm.@cdm_table WHERE person_id IN (@person_id) AND @column_name IN (@concept_id)')
    plData <- DatabaseConnector::renderTranslateQuerySql(connection = connection,
                                                         sql = sql,
                                                         cdm = databaseSchema,
                                                         cdm_table = table,
                                                         person_id = personId,
                                                         column_name = columnName,
                                                         concept_id = conceptIds)
  } else {
    sql <- paste0('SELECT ', paste(columns, collapse = ", ") ,' FROM @cdm.@cdm_table WHERE person_id IN (@person_id)')
    plData <- DatabaseConnector::renderTranslateQuerySql(connection = connection,
                                                         sql = sql,
                                                         cdm = databaseSchema,
                                                         cdm_table = table,
                                                         person_id = personId)
  }
  return(plData)
}
