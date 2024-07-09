#' Install Python Dependencies
#'
#' This function installs the required Python packages for this R package.
#' It ensures that the necessary Python environment is set up and that all
#' dependencies are installed.
#'
#' @param envname Name of the virtual environment. The default is "pytrends-in-r".
#' If the virtual environment does not exist, it will be created.
#' @param method Method to use for installation. Options are "auto", "virtualenv",
#' or "conda". The default is "auto", which will automatically choose the best
#' method based on the system configuration.
#'
#' @details
#' This function checks if the specified virtual environment exists. If it does
#' not exist, it creates the virtual environment. It then installs the required
#' Python packages (`pandas`, `requests`, `pytrends`, and `rich`) into the
#' virtual environment. This is essential for the proper functioning of the R
#' package, which relies on these Python packages for data manipulation,
#' API requests, Google Trends data collection, and enhanced logging.
#'
#' @return NULL. This function is called for its side effects.
#'
#' @examples
#' \dontrun{
#' # Install dependencies using the default virtual environment and method
#' install_python_deps()
#'
#' # Install dependencies specifying a different virtual environment
#' install_python_deps(envname = "my-env")
#'
#' # Install dependencies using conda
#' install_python_deps(method = "conda")
#' }
#'
#' @export

install_python_deps <- function(envname = "pytrends-in-r", method = "auto") {
  if (!reticulate::virtualenv_exists(envname)) {
    reticulate::virtualenv_create(envname)
  }
  reticulate::py_install(c("pandas", "requests", "pytrends", "rich"), envname = envname, method = method)
}

