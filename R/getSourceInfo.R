getSourceInfo <- function(connection, databaseSchema) {

  sql <- 'SELECT * FROM @cdm.cdm_source;'

  sourceInfo <- DatabaseConnector::renderTranslateQuerySql(
    connection = connection,
    sql = sql,
    cdm = databaseSchema
  )

  return(sourceInfo)
}
