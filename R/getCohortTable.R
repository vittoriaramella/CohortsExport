getCohortTable <- function(cohortId, baseUrl, connection, databaseSchema, cohortTable, vocabularyDatabaseSchema) {
  # Get cohort definition
  cohortDefinition = ROhdsiWebApi::getCohortDefinition(cohortId = cohortId,
                                                       baseUrl = baseUrl)

  # Get sql of the selected cohort
  sql = ROhdsiWebApi::getCohortSql(cohortDefinition = cohortDefinition,
                                   baseUrl = baseUrl,
                                   generateStats = FALSE)

  sql = SqlRender::render(
    sql = sql,
    cdm_database_schema = databaseSchema,
    target_database_schema = databaseSchema,
    target_cohort_table = cohortTable,
    target_cohort_id = cohortDefinition$id
  )

  if (stringr::str_detect(string = sql, pattern = 'vocabulary_database_schema')) {
    sql <- SqlRender::render(sql = sql,
                             vocabulary_database_schema = vocabularyDatabaseSchema)
  }

  # Execute the query to instantiate the cohort
  DatabaseConnector::renderTranslateExecuteSql(connection = connection,
                            sql = sql)

  # Execute the query to get selected cohort
  sql = 'SELECT * FROM cohort WHERE cohort_definition_id = @cohort_id;'
  cohortTable <- DatabaseConnector::renderTranslateQuerySql(connection = connection,
                                         sql = sql,
                                         cohort_id = cohortDefinition$id)

  return(cohortTable)

}
