#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  baseUrl = golem::get_golem_options("baseUrl")
  authMethod = golem::get_golem_options("authMethod")
  webApiUsername = golem::get_golem_options("webApiUsername")
  webApiPassword = golem::get_golem_options("webApiPassword")
  connection = golem::get_golem_options("connection")
  cdmDbSchema = golem::get_golem_options("cdmDbSchema")
  vocabularyDatabaseSchema = golem::get_golem_options("vocabularyDatabaseSchema")
  cohortTable = golem::get_golem_options("cohortTable")

  session$onSessionEnded(function() {
    DatabaseConnector::disconnect(connection)
    stopApp()
  })

  # Get source info
  sourceInfo <- getSourceInfo(
    connection = connection,
    databaseSchema = cdmDbSchema
  )

  # Print source info
  output$cdmName <- renderText({ sourceInfo$CDM_SOURCE_NAME })
  output$sourceDescription <- renderText({ sourceInfo$SOURCE_DESCRIPTION })
  output$cdmHolder <- renderText({ sourceInfo$CDM_HOLDER })
  output$sourceReleased <- renderText({ as.character(sourceInfo$SOURCE_RELEASE_DATE) })
  output$cdmReleased <- renderText({ as.character(sourceInfo$CDM_RELEASE_DATE) })
  output$cdmVersion <- renderText({ sourceInfo$CDM_VERSION })
  output$vocabularyVersion <- renderText({ sourceInfo$VOCABULARY_VERSION })
  output$sourceRef <- renderText({ sourceInfo$SOURCE_DOCUMENTATION_REFERENCE })
  output$etlRef <- renderText({ sourceInfo$CDM_ETL_REFERENCE })

  # Modal spinner while waiting for initial settings
  shinybusy::show_modal_spinner(
    spin = "circle",
    text = "Loading"
  )

  # Get list of ATLAS Cohorts and update pickerInput
  cohortDefinitionsList <- tryCatch(getCohortDefinitionsList(baseUrl = baseUrl),
                                    error = function(e) {
                                      if(grepl("http error 401", e)) {
                                        ROhdsiWebApi::authorizeWebApi(baseUrl,
                                                                      authMethod = authMethod,
                                                                      webApiUsername = webApiUsername,
                                                                      webApiPassword = webApiPassword)
                                        getCohortDefinitionsList(baseUrl = baseUrl)
                                      } else {
                                        stop(e)
                                      }
                                    })
  shinyWidgets::updatePickerInput(session,
                                  inputId = "cohort_menu",
                                  choices = cohortDefinitionsList)

  # Get list of ATLAS Concept Sets
  conceptSetList <- tryCatch(getConceptSetList(baseUrl = baseUrl),
                             error = function(e) {
                               if(grepl("http error 401", e)) {
                                 ROhdsiWebApi::authorizeWebApi(baseUrl,
                                                               authMethod = authMethod,
                                                               webApiUsername = webApiUsername,
                                                               webApiPassword = webApiPassword)
                                 getConceptSetList(baseUrl = baseUrl)
                               } else {
                                 stop(e)
                               }
                             })

  # get list of concepts from CONCEPT table
  sql <- 'SELECT * FROM @cdm.concept'
  concept <- DatabaseConnector::renderTranslateQuerySql(connection = connection, sql = sql, cdm = cdmDbSchema) %>%
    dplyr::select(., c('CONCEPT_ID', 'CONCEPT_NAME'))

  # Remove modal spinner when initial settings are done
  shinybusy::remove_modal_spinner()

  # Get cohort table
  cohort <- eventReactive(input$cohort_menu, {
    if(input$cohort_menu != "") {
      shinybusy::show_modal_spinner(
        spin = "circle",
        text = "Querying the Database"
      )

      cohort <- tryCatch(getCohortTable(cohortId = as.numeric(input$cohort_menu),
                                        baseUrl = baseUrl,
                                        connection = connection,
                                        databaseSchema = cdmDbSchema,
                                        cohortTable = cohortTable,
                                        vocabularyDatabaseSchema = vocabularyDatabaseSchema),
                         error = function(e) {
                           if(grepl("http error 401", e)) {
                             ROhdsiWebApi::authorizeWebApi(baseUrl,
                                                           authMethod = authMethod,
                                                           webApiUsername = webApiUsername,
                                                           webApiPassword = webApiPassword)
                             getCohortTable(cohortId = as.numeric(input$cohort_menu),
                                            baseUrl = baseUrl,
                                            connection = connection,
                                            databaseSchema = cdmDbSchema,
                                            cohortTable = cohortTable,
                                            vocabularyDatabaseSchema = vocabularyDatabaseSchema)
                           } else {
                             stop(e)
                           }
                         })

      shinybusy::remove_modal_spinner()
    } else {
      cohort <- data.frame()
    }
    return(cohort)
  })

  # Show cohort entries
  output$entries <- shinydashboard::renderValueBox({
    shinydashboard::valueBox(nrow(cohort()), "Cohort", icon = icon("users"), color = "light-blue")
  })

  # Show cohort subjects
  output$person_count <- shinydashboard::renderValueBox({
    shinydashboard::valueBox(getTableCount(connection, cdmDbSchema, "person", cohort()$SUBJECT_ID), "Person", icon = icon("user"), color = "yellow")
  })

  # Show visit count
  output$visit_count <- shinydashboard::renderValueBox({
    shinydashboard::valueBox(getTableCount(connection, cdmDbSchema, "visit_occurrence", cohort()$SUBJECT_ID), "Visit", icon = icon("stethoscope"), color = "green")
  })

  # Show condition occurrence count
  output$condition_occurrence_count <- shinydashboard::renderValueBox({
    shinydashboard::valueBox(getTableCount(connection, cdmDbSchema, "condition_occurrence", cohort()$SUBJECT_ID), "Condition Occurrence", icon = icon("notes-medical"), color = "maroon")
  })

  # Show condition era count
  output$condition_era_count <- shinydashboard::renderValueBox({
    shinydashboard::valueBox(getTableCount(connection, cdmDbSchema, "condition_era", cohort()$SUBJECT_ID), "Condition Era", icon = icon("notes-medical"), color = "teal")
  })

  # Show procedure occurrence count
  output$procedure_count <- shinydashboard::renderValueBox({
    shinydashboard::valueBox(getTableCount(connection, cdmDbSchema, "procedure_occurrence", cohort()$SUBJECT_ID), "Procedure", icon = icon("procedures"), color = "orange")
  })

  # Show drug exposure count
  output$drug_exposure_count <- shinydashboard::renderValueBox({
    shinydashboard::valueBox(getTableCount(connection, cdmDbSchema, "drug_exposure", cohort()$SUBJECT_ID), "Drug Exposure", icon = icon("pills"), color = "blue")
  })

  # Show drug era count
  output$drug_era_count <- shinydashboard::renderValueBox({
    shinydashboard::valueBox(getTableCount(connection, cdmDbSchema, "drug_era", cohort()$SUBJECT_ID), "Drug Era", icon = icon("pills"), color = "aqua")
  })

  # Show measurement count
  output$measurement_count <- shinydashboard::renderValueBox({
    shinydashboard::valueBox(getTableCount(connection, cdmDbSchema, "measurement", cohort()$SUBJECT_ID), "Measurement", icon = icon("vial"), color = "olive")
  })

  # Show observation count
  output$observation_count <- shinydashboard::renderValueBox({
    shinydashboard::valueBox(getTableCount(connection, cdmDbSchema, "observation", cohort()$SUBJECT_ID), "Observation", icon = icon("microscope"), color = "red")
  })

  # Show observation period count
  output$observation_period_count <- shinydashboard::renderValueBox({
    shinydashboard::valueBox(getTableCount(connection, cdmDbSchema, "observation_period", cohort()$SUBJECT_ID), "Observation Period", icon = icon("calendar"), color = "lime")
  })

  # Show death count
  output$death_count <- shinydashboard::renderValueBox({
    shinydashboard::valueBox(getTableCount(connection, cdmDbSchema, "death", cohort()$SUBJECT_ID), "Death", icon = icon("star-of-life"), color = "purple")
  })

  # Get list of CDM Tables and update picker input
  tableList <- getTableList(connection = connection,
                            databaseSchema = cdmDbSchema)

  shinyWidgets::updatePickerInput(session,
                                  inputId = "cdmTable",
                                  choices = tableList)

  # Initialize reactive values
  rv <- reactiveValues(start = NULL,
                       concept_set_output = c())

  # Add filter on rows with concept sets
  observeEvent(input$filter_conceptset, {
    showModal(
      mod_select_concepts_ui("select_concepts_1", conceptSetList, rv$concept_set_output)
    )
  })

  # Save and print selected concept set(s)
  concept_output <- mod_select_concepts_server("select_concepts_1", conceptSetList)

  observeEvent(concept_output(), {
    rv$concept_set_output <- concept_output()
  })

  output$concept_sets <- renderTable({
    if(length(rv$concept_set_output)){
      data.frame("Filter" = names(conceptSetList[which(conceptSetList %in% rv$concept_set_output)]))
    } else {
      NULL
    }
  })

  # Enable/Disable "Remove filter" button
  observe({
    shinyjs::toggleState(id = "remove_filter", condition = length(rv$concept_set_output))
  })

  # Remove filter
  observeEvent(input$remove_filter, {
    rv$concept_set_output <- c()
  })

  # Enable/disable preview button
  observe({
    shinyjs::toggleState(id = "preview", condition = length(input$cohort_menu) & length(input$cdmTable))
  })

  # Initialize reactive value with selected tables
  observeEvent(input$preview, {
    rv$start <- input$cdmTable
  })

  # Retrieve concepts from concept sets
  concept4filter <- eventReactive(rv$concept_set_output, {
    concept <- c()
    if(length(rv$concept_set_output)) {
      shinybusy::show_modal_spinner(
        spin = "circle",
        text = "Please Wait"
      )
      conceptIds <- c()
      for (i in rv$concept_set_output) {
        conceptSet <- tryCatch(ROhdsiWebApi::getConceptSetDefinition(conceptSetId = as.numeric(i), baseUrl = baseUrl),
                               error = function(e) {
                                 if(grepl("http error 401", e)) {
                                   ROhdsiWebApi::authorizeWebApi(baseUrl,
                                                                 authMethod = authMethod,
                                                                 webApiUsername = webApiUsername,
                                                                 webApiPassword = webApiPassword)
                                   ROhdsiWebApi::getConceptSetDefinition(conceptSetId = as.numeric(i), baseUrl = baseUrl)
                                 } else {
                                   stop(e)
                                 }
                               })
        resolvedConceptSet <- tryCatch(ROhdsiWebApi::resolveConceptSet(conceptSet = conceptSet, baseUrl = baseUrl),
                                       error = function(e) {
                                         if(grepl("http error 401", e)) {
                                           ROhdsiWebApi::authorizeWebApi(baseUrl,
                                                                         authMethod = authMethod,
                                                                         webApiUsername = webApiUsername,
                                                                         webApiPassword = webApiPassword)
                                           ROhdsiWebApi::resolveConceptSet(conceptSet = conceptSet, baseUrl = baseUrl)
                                         } else {
                                           stop(e)
                                         }
                                       })
        conceptIds <- c(conceptIds, resolvedConceptSet)
      }
      concept <- tryCatch(ROhdsiWebApi::getConcepts(conceptIds = conceptIds, baseUrl = baseUrl),
                          error = function(e) {
                            if(grepl("http error 401", e)) {
                              ROhdsiWebApi::authorizeWebApi(baseUrl,
                                                            authMethod = authMethod,
                                                            webApiUsername = webApiUsername,
                                                            webApiPassword = webApiPassword)
                              ROhdsiWebApi::getConcepts(conceptIds = conceptIds, baseUrl = baseUrl)
                            } else {
                              stop(e)
                            }
                          })
      shinybusy::remove_modal_spinner()
    }

    return(concept)
  })

  # Get list of tables which contain domains of selected concepts
  domain <- eventReactive(concept4filter(), {
    if(length(concept4filter())) {
      domain <- getDomainFromConcepts(connection = connection,
                                      tableInput = tableList,
                                      conceptDomain = concept4filter()$domainId)
    }
    return(domain)
  })

  # Get preview of patient-level data ----
  dataPrev <- eventReactive(input$preview, {
    l <- vector(mode = "list", length = length(input$cdmTable))
    names(l) <- input$cdmTable
    for (i in input$cdmTable) {
      if(length(rv$concept_set_output)){
        l[[i]] <- getPLDataPreview(connection, cdmDbSchema, i, cohort()$SUBJECT_ID, concept4filter()$conceptId, domain())
      } else {
        l[[i]] <- getPLDataPreview(connection, cdmDbSchema, i, cohort()$SUBJECT_ID)
      }
    }
    return(l)
  })

  # Open modal with preview
  observeEvent(dataPrev(), {
    showModal(
      tags$div(id="modal1",
               modalDialog(
                 uiOutput("dynamic_tabs_modal"),
                 title = "Data preview",
                 size = "l",
                 easyClose = FALSE,
                 footer=tagList(
                   modalButton('Cancel', icon = icon("undo-alt")),
                   actionButton('filter', 'Continue', icon = icon("step-forward"), style = "color: #fff; background-color: #337ab7; border-color: #2e6da4")
                 )
               )
      )
    )
  })

  # Dynamics tabs in modal
  output$dynamic_tabs_modal <- renderUI({
    tabs <- lapply(rv$start,
                   function(x) {
                     tabPanel(title = x,
                              br(),
                              shinyWidgets::checkboxGroupButtons(inputId = paste0("checkboxID_", x),
                                                                 label = "Select the columns to export",
                                                                 choices = colnames(dataPrev()[[x]]),
                                                                 selected = colnames(dataPrev()[[x]]),
                                                                 individual = TRUE,
                                                                 checkIcon = list(
                                                                   yes = tags$i(class = "fa fa-check-square",
                                                                                style = "color: steelblue"),
                                                                   no = tags$i(class = "fa fa-square-o",
                                                                               style = "color: steelblue"))
                              ),
                              DT::dataTableOutput(paste0(x, "_table"))
                     )
                   }
    )
    do.call(tabsetPanel, tabs)
  })

  observe(
    lapply(rv$start,
           function(x){
             output[[paste0(x, "_table")]] <- DT::renderDataTable({
               DT::datatable(dplyr::select(dataPrev()[[x]], input[[paste0("checkboxID_", x)]]),
                         rownames = FALSE,
                         options = list(scrollX = TRUE))
             })
           }
    )
  )

  # Get filtered table
  data_filter <- eventReactive(input$filter, {
    removeModal()
    l <- vector(mode = "list", length = length(input$cdmTable))
    names(l) <- input$cdmTable
    for (i in input$cdmTable) {
      if(length(rv$concept_set_output)){
        l[[i]] <- getPLData(connection, input[[paste0("checkboxID_", i)]], cdmDbSchema, i, cohort()$SUBJECT_ID, concept4filter()$conceptId, domain()) %>%
          getConceptNamesFromId(., concept)
      } else {
        l[[i]] <- getPLData(connection, input[[paste0("checkboxID_", i)]], cdmDbSchema, i, cohort()$SUBJECT_ID) %>%
          getConceptNamesFromId(., concept)
      }
    }
    return(l)
  })

  # Dynamics tabs with final data
  output$dynamic_tabs <- renderUI({
    tabs <- lapply(rv$start,
                   function(x) {
                     tabPanel(title = x,
                              br(),
                              DT::dataTableOutput(paste0(x, "_table_full"))
                     )
                   }
    )
    do.call(tabsetPanel, tabs)
  })

  observe(
    lapply(rv$start,
           function(x){
             output[[paste0(x, "_table_full")]] <- DT::renderDataTable({
               DT::datatable(data_filter()[[x]],
                             rownames = FALSE,
                             options = list(scrollX = TRUE))
             })
           }
    )
  )

  # Enable/disable preview button
  observe({
    shinyjs::toggleState(id = "download", condition = length(data_filter()))
  })

  # Open modal for download
  observeEvent(input$download, {
    showModal(
      mod_download_ui("download_1", data_filter())
    )
  })

  mod_download_server("download_1", data_filter())

}
