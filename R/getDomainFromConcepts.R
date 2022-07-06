getDomainFromConcepts <- function(connection, tableInput, conceptDomain) {
  tableOut <- c()

  # Get unique domains
  domain <- unique(conceptDomain)

  # Check which tables contain concepts in the concept set
  for (i in tableInput) {
    columnName =  grep("_CONCEPT_ID", DatabaseConnector::dbListFields(connection, i), value = TRUE, ignore.case = TRUE)[1]
    checkDomain = grepl(paste0(domain, collapse = "|"), columnName, ignore.case = TRUE)
    # if TRUE add to the list of tables to be filtered
    if(checkDomain)
      tableOut <- c(tableOut, i)
  }

  return(tableOut)
}
