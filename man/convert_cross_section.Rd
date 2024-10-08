% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/convert_cross_section.R
\name{convert_cross_section}
\alias{convert_cross_section}
\title{Convert the Cross-Section data for Re-scaling.}
\usage{
convert_cross_section(params, reference_geo_code = "US-CA", zero_replace = 0.1)
}
\arguments{
\item{params}{A list containing parameters including keyword, topic, folder_name, start_date, end_date, and data_format.}

\item{reference_geo_code}{Google Trends Geo code for the user-selected reference region. For example, UK's Geo is 'GB', Central Denmark Region's Geo is 'DK-82, and US DMA Philadelphia PA's Geo is '504'. The default is 'US'.}

\item{zero_replace}{When re-scaling data from different time periods for concatenation, the last/first data point of a time period may be zero. Then the calculation will throw an error, or every single data point will be zero. To avoid this, the user can adjust the zero to an insignificant number to continue the calculation. The default is 0.1.}
}
\value{
No return value, called for side effects.
}
\description{
This function uses the single or concatenated reference time-series data to re-scale the cross-section data collected by the cross_section() function.
}
\details{
This final method rescales the cross-section data based on the concatenated time series data to generate re-scaled accurate longitudinal Google Trends index.
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
    start_date = "2024-05-01",
    end_date = "2024-05-03",
    data_format = "daily"
  )
  cross_section_success <- TRUE
  time_series_success <- TRUE

  # Run the cross_section function and handle potential errors
  tryCatch({
    cross_section(params, geo = "US", resolution = "REGION")
  }, pytrends.exceptions.TooManyRequestsError = function(e) {
    message("Too many requests error in cross_section: ", conditionMessage(e))
    cross_section_success <- FALSE # Indicate failure
  })

  # Run the time_series function and handle potential errors
  tryCatch({
    time_series(params, reference_geo_code = "US-CA")
  }, pytrends.exceptions.TooManyRequestsError = function(e) {
    message("Too many requests error in time_series: ", conditionMessage(e))
    time_series_success <- FALSE # Indicate failure
  })

  data_dir_time <- file.path("test_folder", "daily", "over_time", "US-CA")
  data_dir_region <- file.path("test_folder", "daily", "by_region")

  # Conditionally run convert_cross_section only if both functions succeeded
  if (cross_section_success && time_series_success && length(list.files(data_dir_time)) > 0
  && length(list.files(data_dir_region)) > 0) {
    convert_cross_section(params, reference_geo_code = "US-CA")
  } else {
    message("Skipping convert_cross_section due to previous errors.")
  }

  # Clean up temporary directory
  on.exit(unlink("test_folder", recursive = TRUE))
} else {
  message("The 'pytrends' module is not available.
  Please install it by running install_pytrendslongitudinalr()")
}
}
}
