getSourceInfo <- function(connection, databaseSchema) {

  sql <- 'SELECT * FROM @cdm.cdm_source;'

  sourceInfo <- DatabaseConnector::renderTranslateQuerySql(
    connection = connection,
    sql = sql,
    cdm = databaseSchema
  ) %>%
    dplyr::select(c("CDM_SOURCE_NAME", "SOURCE_DESCRIPTION", "CDM_HOLDER", "SOURCE_RELEASE_DATE", "CDM_RELEASE_DATE", "CDM_VERSION", "VOCABULARY_VERSION", "SOURCE_DOCUMENTATION_REFERENCE", "CDM_ETL_REFERENCE"))

  colnames(sourceInfo) <- c("Source Name", "Description", "Licensed to", "Source Released", "CDM Released", "CDM Version", "Vocabulary Version", "Source Documentation", "ETL Reference")

  return(sourceInfo)
}
