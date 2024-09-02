# R/zzz.R

# Global references to Python modules (will be initialized in .onLoad)
TrendReq <- NULL
ResponseError <- NULL
pd <- NULL
os <- NULL
glob <- NULL
json <- NULL
requests <- NULL
dt <- NULL
relativedelta <- NULL
time <- NULL
logging <- NULL
console <- NULL
RichHandler <- NULL
math <- NULL
platform <- NULL

.onLoad <- function(libname, pkgname) {

  # Specify desired Python version
  desired_python_version <- "3.11.9"

  os_type <- Sys.info()["sysname"]

  # Define paths
  venv_path <- file.path(Sys.getenv("HOME"), ".virtualenvs", "pytrends-in-r-new")
  python_path <- file.path(venv_path, "bin", "python")


  # Debian/Ubuntu-specific handling
  if (os_type == "Linux" && file.exists("/etc/debian_version")) {
    tryCatch({
      reticulate::virtualenv_create(envname = venv_path, python = python_path)
    }, error = function(e) {
      # Attempt to install the python3-venv package
      system("sudo apt-get update && sudo apt-get install -y python3.12-venv", intern = TRUE)
      # Retry creating the virtual environment
      reticulate::virtualenv_create(envname = venv_path, python = python_path)
    })
  } else {
    # Non-Debian/Ubuntu handling
    if (!reticulate::virtualenv_exists(venv_path)) {
      tryCatch({
        reticulate::virtualenv_create(envname = venv_path, python = python_path)
      }, error = function(e) {
        stop("Failed to create a virtual environment. Ensure Python venv package is installed.")
      })
    }
  }

  # Use the virtual environment for reticulate operations
  reticulate::use_virtualenv(venv_path, required = TRUE)

  # Install packages if not already installed
  packages_to_install <- c("pandas", "requests", "pytrends", "rich")
  for (package in packages_to_install) {
    if (!reticulate::py_module_available(package)) {
      reticulate::py_install(package, envname = "pytrends-in-r-new")
    }
  }


  TrendReq <<- reticulate::import("pytrends.request", delay_load = TRUE)$TrendReq
  ResponseError <<- reticulate::import("pytrends.exceptions", delay_load = TRUE)$ResponseError
  pd <<- reticulate::import("pandas", delay_load = TRUE)
  os <<- reticulate::import("os", delay_load = TRUE)
  glob <<- reticulate::import("glob", delay_load = TRUE)
  json <<- reticulate::import("json", delay_load = TRUE)
  requests <<- reticulate::import("requests", delay_load = TRUE)
  dt <<- reticulate::import("datetime", delay_load = TRUE)
  relativedelta <<- reticulate::import("dateutil.relativedelta", delay_load = TRUE)
  time <<- reticulate::import("time", delay_load = TRUE)
  logging <<- reticulate::import("logging", delay_load = TRUE)
  console <<- reticulate::import("rich.console", delay_load = TRUE)$Console
  RichHandler <<- reticulate::import("rich.logging", delay_load = TRUE)$RichHandler
  math <<- reticulate::import("math", delay_load = TRUE)
  platform <<- reticulate::import("platform", delay_load = TRUE)

  # Configure logging
  configure_logging()
}

.onAttach <- function(libname, pkgname) {
  if (!interactive()) {
    return()  # Skip the prompt during non-interactive sessions
  }

  msg <- "This package creates new folders in your filespace to store downloaded Google Trends data. Do you want to proceed? (Y/N)"
  packageStartupMessage(msg)

  response <- readline(prompt = "Enter Y to proceed, or N to abort: ")

  if (toupper(response) != "Y") {
    stop("Initialization aborted by the user.")
  }
}



