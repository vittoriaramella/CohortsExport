#' download UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_download_ui <- function(id, data2export){
  ns <- NS(id)
  tagList(
    modalDialog(
      p("Select your export format."),
      br(),
      fluidRow(
        column(9,
               div(img(src = "www/Microsoft_Office_Excel.png",  height = 30, width = 30),
                   strong(" Microsoft Excel"))),
        column(3,
               downloadButton(outputId = ns("download_xlsx"), label = NULL))
      ),
      hr(),
      fluidRow(
        column(9,
               div(img(src = "www/R_logo.png",  height = 25, width = 30),
                   strong(" R Statistical Software"))),
        column(3,
               downloadButton(outputId = ns("download_R"), label = NULL))
      ),
      hr(),
      fluidRow(
        column(9,
               div(img(src = "www/stata-logo.png",  height = 15, width = 30),
                   strong(" Stata Statistical Software"))),
        column(3,
               downloadButton(outputId = ns("download_stata"), label = NULL))
      ),
      hr(),
      fluidRow(
        column(9,
               div(img(src = "www/spss_logo.png",  height = 30, width = 30),
                   strong(" SPSS Statistical Software"))),
        column(3,
               downloadButton(outputId = ns("download_spss"), label = NULL))
      ),
      hr(),
      fluidRow(
        column(9,
               div(img(src = "www/SAS_logo.png",  height = 15, width = 30),
                   strong(" SAS Statistical Software"))),
        column(3,
               downloadButton(outputId = ns("download_sas"), label = NULL))
      ),
      title = tagList(icon("file-download"), "Export Data"),
      size = "s",
      easyClose = FALSE,
      footer=tagList(
        modalButton('Cancel', icon = icon("undo-alt"))
      )
    )

  )
}

#' download Server Functions
#'
#' @noRd
mod_download_server <- function(id, data2export){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # Microsoft excel
    output$download_xlsx = downloadHandler(
      filename = function() {
        paste0("Export", Sys.Date(),".xlsx")
      },
      content = function(file){
        removeModal()
        shinybusy::show_modal_spinner(
          spin = "circle",
          text = "Please Wait"
        )
        # build excel file
        wb <- openxlsx::createWorkbook()
        for (i in 1:length(data2export)) {
          openxlsx::addWorksheet(wb, names(data2export)[i])
          openxlsx::writeData(wb, sheet = names(data2export)[i], data2export[[i]], borders = "all", borderColour = "#999999",
                              headerStyle = openxlsx::createStyle(border = c("top", "bottom", "left", "right"), borderColour = "#999999", textDecoration = "bold"))
          openxlsx::setColWidths(wb, sheet = names(data2export)[i], cols = 1:ncol(data2export[[i]]), widths = "auto")
        }
        openxlsx::saveWorkbook(wb, file)
        shinybusy::remove_modal_spinner()
      }
    )

    # R
    output$download_R = downloadHandler(
      filename = function() {
        paste0("Export", Sys.Date(), ".RData")
      },
      content = function(file){
        removeModal()
        shinybusy::show_modal_spinner(
          spin = "circle",
          text = "Please Wait"
        )
        dataExport <- data2export
        save(dataExport, file = file)
        shinybusy::remove_modal_spinner()
      }
    )

    # STATA
    output$download_stata = downloadHandler(
      filename = function() {
        paste0("Export_stata", Sys.Date(), ".zip")
      },
      content = function(file){
        removeModal()
        shinybusy::show_modal_spinner(
          spin = "circle",
          text = "Please Wait"
        )
        fs = c()
        tmpdir <- tempdir()
        for (i in 1:length(data2export)) {
          path = paste(names(data2export)[i], "dta", sep = ".")
          fs = c(fs, path)
          foreign::write.dta(data2export[[i]], path)
        }
        zip(zipfile = file, files = fs)
        shinybusy::remove_modal_spinner()
      },
      contentType = "application/zip"
    )

    # SPSS
    output$download_spss = downloadHandler(
      filename = function() {
        paste0("Export_SPSS", Sys.Date(), ".zip")
      },
      content = function(file){
        removeModal()
        shinybusy::show_modal_spinner(
          spin = "circle",
          text = "Please Wait"
        )
        fs = c()
        tmpdir <- tempdir()
        for (i in 1:length(data2export)) {
          datafile <- paste0(names(data2export)[i], ".txt")
          codefile <- paste0(names(data2export)[i], ".sps")
          fs = c(fs, datafile, codefile)
          foreign::write.foreign(data2export[[i]], datafile, codefile, package = 'SPSS')
        }
        zip(zipfile = file, files = fs)
        shinybusy::remove_modal_spinner()
      },
      contentType = "application/zip"
    )

    # SAS Cohort Table
    output$download_sas = downloadHandler(
      filename = function() {
        paste0("Export_SAS", Sys.Date(), ".zip")
      },
      content = function(file){
        removeModal()
        shinybusy::show_modal_spinner(
          spin = "circle",
          text = "Please Wait"
        )
        fs = c()
        tmpdir <- tempdir()
        for (i in 1:length(data2export)) {
          datafile <- paste0(names(data2export)[i], ".txt")
          codefile <- paste0(names(data2export)[i], ".sas")
          fs = c(fs, datafile, codefile)
          foreign::write.foreign(data2export[[i]], datafile, codefile, package = 'SAS')
        }
        zip(zipfile = file, files = fs)
        shinybusy::remove_modal_spinner()
      },
      contentType = "application/zip"
    )

  })
}

## To be copied in the UI
# mod_download_ui("download_1")

## To be copied in the server
# mod_download_server("download_1")
