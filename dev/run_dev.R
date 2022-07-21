# Set options here
options(golem.app.prod = FALSE) # TRUE = production mode, FALSE = development mode

# Comment this if you don't want the app to be served on a random port
options(shiny.port = httpuv::randomPort())

# Detach all loaded packages and clean your environment
golem::detach_all_attached()
# rm(list=ls(all.names = TRUE))

# Document and reload your package
golem::document_and_reload()

# connection = DatabaseConnector::connect(connectionDetails = Eunomia::getEunomiaConnectionDetails())

# Run the application with Eunomia and OHDSI demo ATLAS
# baseUrl = 'http://api.ohdsi.org/WebAPI'
# run_app(baseUrl = baseUrl,
#         connection = connection,
#         cdmDbSchema = 'main',
#         vocabularyDatabaseSchema = 'main',
#         cohortTable = 'cohort')

# Run the application with Eunomia and BIOMERIS demo ATLAS
# baseUrl = 'http://34.253.42.86:8080/WebAPI'
# run_app(baseUrl = baseUrl,
#         authMethod = "db",
#         webApiUsername = Sys.getenv("WEBAPI_USERNAME"),
#         webApiPassword = Sys.getenv("WEBAPI_PASSWORD"),
#         connection = connection,
#         cdmDbSchema = 'main',
#         vocabularyDatabaseSchema = 'main',
#         cohortTable = 'cohort')

# Run the application with cdm1 demo and BIOMERIS demo ATLAS
pathToDriver <- "/Users/vramella/R/drivers"

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "postgresql",
                                                                user = Sys.getenv("CDM_USERNAME"),
                                                                password = Sys.getenv("CDM_PASSWORD"),
                                                                server = "54.77.2.157/OMOP",
                                                                port = 5432,
                                                                pathToDriver = pathToDriver)

connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)

baseUrl = 'http://34.253.42.86:8080/WebAPI'
run_app(baseUrl = baseUrl,
        authMethod = "db",
        webApiUsername = Sys.getenv("WEBAPI_USERNAME"),
        webApiPassword = Sys.getenv("WEBAPI_PASSWORD"),
        connection = connection,
        cdmDbSchema = 'cdm1',
        vocabularyDatabaseSchema = 'cdm1',
        cohortTable = 'cohort')

