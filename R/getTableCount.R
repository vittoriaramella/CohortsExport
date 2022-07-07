getTableCount <- function(connection, databaseSchema, cdmTable, personId) {
  if(length(personId)){
    sql = 'SELECT COUNT(*) FROM @cdm.@cdm_table WHERE person_id IN (@person_id)'

    n = DatabaseConnector::renderTranslateQuerySql(connection = connection,
                                                   sql = sql,
                                                   cdm = databaseSchema,
                                                   cdm_table = cdmTable,
                                                   person_id = personId)
  } else {
    n = 0
  }

  return(n)
}
