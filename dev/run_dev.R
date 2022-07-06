# Set options here
options(golem.app.prod = FALSE) # TRUE = production mode, FALSE = development mode

# Comment this if you don't want the app to be served on a random port
options(shiny.port = httpuv::randomPort())

# Detach all loaded packages and clean your environment
golem::detach_all_attached()
# rm(list=ls(all.names = TRUE))

# Document and reload your package
golem::document_and_reload()

connection = DatabaseConnector::connect(connectionDetails = Eunomia::getEunomiaConnectionDetails())

# connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "postgresql",
#                                                                 user = "cdm1",
#                                                                 password = "biom_demo_cdm1",
#                                                                 server = "54.77.2.157/OMOP",
#                                                                 port = 5432,
#                                                                 pathToDriver = "/Users/vramella/R/drivers")
#
# connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)

# ROhdsiWebApi::authorizeWebApi(baseUrl = 'http://34.253.42.86:8080/WebAPI/',
#                               authMethod = "db",
#                               webApiUsername = Sys.getenv("WEBAPI_USERNAME"),
#                               webApiPassword = Sys.getenv("WEBAPI_PASSWORD"))
#
# baseUrl = 'http://34.253.42.86:8080/WebAPI/'

baseUrl = 'http://api.ohdsi.org/WebAPI'

# Run the application
run_app(baseUrl = baseUrl,
        connection = connection,
        cdmDbSchema = 'main',
        vocabularyDatabaseSchema = 'main',
        cohortTable = 'cohort')

# run_app(baseUrl = baseUrl,
#         connection = connection,
#         # connectionDetails = connectionDetails,
#         cdmDbSchema = 'cdm1',
#         vocabularyDatabaseSchema = 'cdm1',
#         cohortTable = 'cohort')
