getTableCount <- function(connection, databaseSchema, cdmTable, personId) {
  sql = 'SELECT COUNT(*) FROM @cdm.@cdm_table WHERE person_id IN (@person_id)'

  n = DatabaseConnector::renderTranslateQuerySql(connection = connection,
                              sql = sql,
                              cdm = databaseSchema,
                              cdm_table = cdmTable,
                              person_id = personId)
  return(n)
}
