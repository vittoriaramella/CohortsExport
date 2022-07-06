getCohortDefinitionsList <- function(baseUrl){
  cohortMetadata <- ROhdsiWebApi::getCohortDefinitionsMetaData(baseUrl = baseUrl) %>%
    dplyr::mutate(modifiedDate = ifelse(is.na(modifiedDate), createdDate, modifiedDate)) %>%
    dplyr::arrange(desc(modifiedDate))
  cohortDefinitionsList <- cohortMetadata$id
  names(cohortDefinitionsList) <- cohortMetadata$name
  return(cohortDefinitionsList)
}
