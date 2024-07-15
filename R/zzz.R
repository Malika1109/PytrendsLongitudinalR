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

  # Define paths
  venv_path <- file.path(Sys.getenv("HOME"), ".virtualenvs", "pytrends-in-r-new")
  python_path <- file.path(venv_path, "bin", "python")

  # Check if the Python executable exists
  if (!file.exists(python_path)) {
    # Install Python if it doesn't exist
    packageStartupMessage("Specified Python not found. Installing Python ", desired_python_version, " using reticulate.")
    reticulate::install_python(version = desired_python_version)
  }

  # Use the correct Python installation
  #reticulate::use_python_version(desired_python_version)

  # Check if the virtual environment exists
  if (!reticulate::virtualenv_exists(venv_path)) {
    # If it doesn't exist, attempt to create it
    tryCatch({
      reticulate::virtualenv_create(envname = venv_path, python = python_path)
    }, error = function(e) {
      # Fallback: install Python and create the virtual environment
      packageStartupMessage("Failed to create virtual environment. Installing Python ", desired_python_version, " using reticulate.")
      #reticulate::install_python(version = desired_python_version, envname = "pytrends-in-r-new")
      reticulate::virtualenv_create(envname = venv_path, python = reticulate:virtualenv_starter(desired_python_version))
    })
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


