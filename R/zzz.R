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

  # Check if the virtual environment exists
  if (!reticulate::virtualenv_exists("~/.virtualenvs/pytrends-in-r")) {
    # If it doesn't exist, create it
    reticulate::virtualenv_create("~/.virtualenvs/pytrends-in-r")
  }

  # Install pandas if not already installed
  if (!reticulate::py_module_available("pandas")) {
    reticulate::py_install("pandas", envname = "~/.virtualenvs/pytrends-in-r")
  }

  # Install requests if not already installed
  if (!reticulate::py_module_available("requests")) {
    reticulate::py_install("requests", envname = "~/.virtualenvs/pytrends-in-r")
  }

  # Install pytrends if not already installed
  if (!reticulate::py_module_available("pytrends")) {
    reticulate::py_install("pytrends", envname = "~/.virtualenvs/pytrends-in-r")
  }

  # Install rich if not already installed
  if (!reticulate::py_module_available("rich")) {
    reticulate::py_install("rich", envname = "~/.virtualenvs/pytrends-in-r")
  }


  reticulate::use_virtualenv("~/.virtualenvs/pytrends-in-r", required = TRUE)

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


