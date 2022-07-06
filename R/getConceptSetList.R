getConceptSetList <- function(baseUrl) {
  conceptSetMetadata <- ROhdsiWebApi::getConceptSetDefinitionsMetaData(baseUrl = baseUrl) %>%
    dplyr::mutate(modifiedDate = ifelse(is.na(modifiedDate), createdDate, modifiedDate)) %>%
    dplyr::arrange(desc(modifiedDate))
  conceptSetList <- conceptSetMetadata$id
  names(conceptSetList) <- conceptSetMetadata$name
  return(conceptSetList)
}
