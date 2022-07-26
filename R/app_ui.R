#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    shinydashboard::dashboardPage(
      skin = "black",
      shinydashboard::dashboardHeader(title = "CohortsExport"),

      # Dashboard Sidebar
      shinydashboard::dashboardSidebar(
        shinydashboard::sidebarMenu(
          shinydashboard::menuItem(strong("Cohorts Export"), tabName = "export", icon = icon("download")),
          shinydashboard::menuItem(strong("Data Info"), tabName = "data_info", icon = icon("database"))
        )
      ),

      # Dashboard Body
      shinydashboard::dashboardBody(
        tags$style(
          type = 'text/css',
          '#modal1 .modal-dialog { width: 90% !important;}'
        ),
        shinydashboard::tabItems(
          # Cohort export tab content
          shinydashboard::tabItem(tabName = "export",
                  h1(strong("Cohorts Export")),
                  br(),
                  # Sources, Cohorts and Counts
                  fluidRow(
                    # Sources and Cohorts
                    shinydashboard::box(
                      title = h4(div(icon("users") ,"Cohorts")),
                      status = "primary",
                      width = 3,
                      shinyWidgets::pickerInput(
                        inputId = "cohort_menu",
                        label = div("Select a Cohort", style = "color: #337ab7"),
                        choices = "",
                        options = list(
                          title = "Select a Cohort",
                          `live-search` = TRUE)
                      ),
                    ),
                    # Counts
                    shinydashboard::box(
                      title = h4(div(icon("sign-in-alt") ,"Counts")),
                      status = "primary",
                      width = 9,
                      column(3,
                             fluidRow(
                               shinydashboard::valueBoxOutput(outputId = "entries", width = 12)),
                             fluidRow(
                               shinydashboard::valueBoxOutput(outputId = "person_count", width = 12)),
                             fluidRow(
                               shinydashboard::valueBoxOutput(outputId = "visit_count", width = 12))),
                      column(3,
                             fluidRow(
                               shinydashboard::valueBoxOutput(outputId = "condition_occurrence_count", width = 12)
                             ),
                             fluidRow(
                               shinydashboard::valueBoxOutput(outputId = "condition_era_count", width = 12)
                             ),
                             fluidRow(
                               shinydashboard::valueBoxOutput(outputId = "procedure_count", width = 12)
                             )),
                      column(3,
                             fluidRow(
                               shinydashboard::valueBoxOutput(outputId = "drug_exposure_count", width = 12)
                             ),
                             fluidRow(
                               shinydashboard::valueBoxOutput(outputId = "drug_era_count", width = 12)
                             ),
                             fluidRow(
                               shinydashboard::valueBoxOutput(outputId = "measurement_count", width = 12)
                             )),
                      column(3,
                             fluidRow(
                               shinydashboard::valueBoxOutput(outputId = "observation_count", width = 12)
                             ),
                             fluidRow(
                               shinydashboard::valueBoxOutput(outputId = "observation_period_count", width = 12)
                             ),
                             fluidRow(
                               shinydashboard::valueBoxOutput(outputId = "death_count", width = 12)
                             ))
                    )
                  ),
                  # Options + Data Tables
                  fluidRow(
                    shinydashboard::box(
                      title = h4(div(icon("cogs") ,"Settings")),
                      status = "primary",
                      width = 3,
                      div(strong("Select Tables"), style = "color: #337ab7"),
                      shinyWidgets::pickerInput(
                        inputId = "cdmTable",
                        label = NULL,
                        width = "100%",
                        choices = c(),
                        options = list(
                          `actions-box` = TRUE,
                          `selected-text-format` = "count > 3",
                          `dropup-auto` = FALSE,
                          `live-search` = TRUE
                        ),
                        multiple = TRUE
                      ),
                      hr(style = "border-top: 1px solid #DCDCDC;"),
                      div(strong("Filter Rows (optional)"), style = "color: #337ab7"),
                      p("You can select one or more CONCEPT SETS to filter rows."),
                      actionButton(inputId = "filter_conceptset", label = "Add Filter", icon = icon("plus"), style = "color: #fff; background-color: #57AF55; border-color: #3b843a"),
                      shinyjs::disabled(actionButton(inputId = "remove_filter", label = "Remove", icon = icon("trash"), style = "color: #fff; background-color: #d04a46; border-color: #ad2825")),
                      tableOutput("concept_sets"),
                      hr(style = "border-top: 1px solid #DCDCDC;"),
                      shinyjs::disabled(actionButton(inputId = "preview", label = "Preview", icon = icon("search"), style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"))
                    ),
                    shinydashboard::box(
                      title = h4(div(icon("table") ,"Data Tables")),
                      status = "primary",
                      width = 9,
                      uiOutput("dynamic_tabs"),
                      br(),
                      shinyjs::disabled(actionButton(inputId = "download", label = "Download", icon = icon("download"), style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"))
                    )
                  )
                  # fluidRow(
                  #   shinydashboard::box(
                  #     # title = h4(div(icon("cogs") ,"Options")),
                  #     status = "primary",
                  #     width = 3,
                  #     actionButton(inputId = "reset_settings", label = "Reset Settings", icon = icon("undo")),
                  #     actionButton(inputId = "export_settings", label = "Export Settings", icon = icon("download"))
                  #   )
                  # )
          ),

          # Data Info tab content
          shinydashboard::tabItem(tabName = "data_info",
                  h1(strong("Data Info")),
                  br(),
                  br(),
                  div(h3(strong("Data Sources Information")), style = "color: #337ab7"),
                  br(),
                  DT::dataTableOutput(outputId = "dataInfo")
          )

        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "CohortsExport"
    ),
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
    shinyjs::useShinyjs()
  )
}
