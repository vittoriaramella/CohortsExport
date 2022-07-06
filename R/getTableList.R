getTableList <- function(connection, databaseSchema) {
  # Get list of all tables in the database
  tables <- DatabaseConnector::getTableNames(connection = connection,
                                             databaseSchema = databaseSchema)

  tableList <- c()

  # check which tables contain patient-level data
  for (i in tables) {
    tableFields <- DatabaseConnector::dbListFields(conn = connection,
                                                   name = i)

    if("PERSON_ID" %in% tableFields)
      tableList <- c(tableList, i)
  }

  return(tableList)
}
