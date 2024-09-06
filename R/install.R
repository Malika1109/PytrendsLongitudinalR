#' Install and Set Up Python Environment for PytrendsLongitudinalR
#'
#' This function sets up the Python virtual environment and installs required packages.
#' @param envname Name of the virtual environment.
#' @param ... Additional arguments passed to `py_install()`.
#' @export
install_pytrendslongitudinalr <- function(envname = "pytrends-in-r-new", ...) {
  if (reticulate::virtualenv_exists(envname)) {
    message("Virtual environment exists. Reinstalling packages if necessary...")
  } else {
    message("Creating virtual environment...")
    reticulate::virtualenv_create(envname = envname)
  }

  # Install the required Python packages
  reticulate::py_install(
    c("pandas", "requests", "pytrends", "rich"),
    envname = envname,
    ...
  )
}
