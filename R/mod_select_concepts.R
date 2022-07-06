#' select_concepts UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_select_concepts_ui <- function(id, conceptSetList, selectedItems){
  ns <- NS(id)
  tagList(
    modalDialog(
      p("Click on a Concept Set to filter rows using the concepts included in it. You can select one or more concept sets."),
      br(),
      shinyWidgets::multiInput(
        inputId = ns("select_concept_set"),
        label = "Concept Sets",
        choices = conceptSetList,
        selected = selectedItems,
        width = "100%"
      ),
      title = tagList(icon("filter"), "Filter Rows"),
      size = "m",
      easyClose = FALSE,
      footer=tagList(
        modalButton('Cancel', icon = icon("undo-alt")),
        shinyjs::disabled(actionButton(ns('filter_row'), 'Continue', icon = icon("step-forward"), style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"))
      )
    )

  )
}

#' select_concepts Server Functions
#'
#' @noRd
mod_select_concepts_server <- function(id, conceptSetList){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # Enable/disable continue button
    observe({
      shinyjs::toggleState(id = "filter_row", condition = length(input$select_concept_set))
    })

    # Retrieve concepts from selected concept sets
    concept <- eventReactive(input$filter_row, {
      removeModal()
      concepts <- input$select_concept_set
      return(concepts)
    })
  })
}

## To be copied in the UI
# mod_select_concepts_ui("select_concepts_1")

## To be copied in the server
# mod_select_concepts_server("select_concepts_1")
