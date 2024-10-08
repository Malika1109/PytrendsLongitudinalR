% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/concat_time_series.R
\name{concat_time_series}
\alias{concat_time_series}
\title{Concatenate Multiple Time-Series Data Sets}
\usage{
concat_time_series(params, reference_geo_code = "US", zero_replace = 0.1)
}
\arguments{
\item{params}{A list containing parameters including keyword, topic, folder_name, start_date, end_date, and data_format.}

\item{reference_geo_code}{Google Trends Geo code for the user-selected reference region. For example, UK's Geo is 'GB', Central Denmark Region's Geo is 'DK-82, and US DMA Philadelphia PA's Geo is '504'. The default is 'US'.}

\item{zero_replace}{When re-scaling data from different time periods for concatenation, the last/first data point of a time period may be zero. Then the calculation will throw an error, or every single data point will be zero. To avoid this, the user can adjust the zero to an insignificant number to continue the calculation. The default is 0.1.}
}
\value{
No return value, called for side effects. The function concatenates the time-series data and saves it as a CSV file.
}
\description{
This function concatenates the time-series data collected by the 'time_series()' function
}
\details{
This method concatenates the reference time-series data collected by the 'time_series()' function when the function has produced more than one data file. Because the time series data of each time period is normalized, the multiple time-series data sets are not on the same scale and must be re-scaled.
The re-scaled reference time-series data will be used in the next step to re-scale the cross-section data. If the given period is less than 269 days/weeks/months, and the 'time_series()' function produced only one data file, concatenation is unnecessary, and thus no concatenated file will be created in this step. The user can move to the 'convert_cross_section()' function without any problems.
}
\examples{
\donttest{
# Please note that this example may take a few minutes to run
# Create a temporary folder for the example

# Ensure the temporary folder is cleaned up after the example
if (reticulate::py_module_available("pytrends")) {
  params <- initialize_request_trends(
    keyword = "Coronavirus disease 2019",
    topic = "/g/11j2cc_qll",
    folder_name = file.path(tempdir(), "test_folder"),
    start_date = "2017-12-31",
    end_date = "2024-05-19",
    data_format = "weekly"
  )
  result <- TRUE

  # Run the time_series function and handle TooManyRequestsError
  tryCatch({
    time_series(params, reference_geo_code = "US-CA")
  }, error = function(e) {
    message("An error occurred: ", conditionMessage(e))
    result <- FALSE # Indicate failure only on error
  })

  # Check if at least one file is present in the expected directory
  data_dir <- file.path("test_folder", "weekly", "over_time", "US-CA")
  if (result && length(list.files(data_dir)) > 0) {
    concat_time_series(params, reference_geo_code = "US-CA")
  } else {
    if (result) {
      message("Skipping concat_time_series because no files were found in the expected directory.")
    } else {
      message("Skipping concat_time_series because time_series failed.")
    }
    result <- FALSE
  }

  # Clean up temporary directory
  on.exit(unlink("test_folder", recursive = TRUE))
} else {
  message("The 'pytrends' module is not available.
  Please install it by running install_pytrendslongitudinalr()")
}
}
}
