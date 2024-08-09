#' Time Series Data Collection Method
#'
#' This function collects time series data using the Google Trends API. It dynamically selects between daily, weekly, or monthly data collection based on the time window specified.
#'
#' @param params A list containing parameters including logger, folder_name, data_format, time_window, and other necessary parameters for sub-functions.
#' @param reference_geo_code Country/State/City to be used as reference point to rescale the data in later part

#' @details
#' This method collects Google Trends time series data by calling pytrends.interest_over_time(). By default, Google provides weekly data if the time period between start and end dates is more than 270 days, and monthly data if it's more than 270 weeks. This function handles the collection of daily/weekly data in chunks less than 270 days/weeks to accommodate Google's limitations.
#' The collected data is saved in the structure: \code{folder_name/data_format/over_time/reference_geo_code}.
#'
#' @return NULL
#'
#' @examples
#' \donttest{
#' # Create a temporary folder for the example
#'
#' # Ensure the temporary folder is cleaned up after the example

#' # Run the function with the temporary folder
#' params <- initialize_request_trends(
#'   keyword = "Joe Biden",
#'   topic = "/m/012gx2",
#'   folder_name = file.path(tempdir(), "biden_save"),
#'   start_date = "2024-05-01",
#'   end_date = "2024-05-03",
#'   data_format = "daily"
#' )
#'
#' # Run the time_series function with the parameters
#' tryCatch({
#'   time_series(params, reference_geo_code = "US-CA")
#' }, pytrends.exceptions.TooManyRequestsError = function(e) {
#'   message("Too many requests error: ", conditionMessage(e))
#' })
#' on.exit(unlink(tempdir(), recursive = TRUE))
#'
#' }
#' @export
#'
time_series <- function(params, reference_geo_code = "US") {

  logger <- params$logger
  folder_name <- params$folder_name
  data_format <- params$data_format
  time_window <- params$time_window

  logger$info("Collecting Over Time Data now")

  create_required_directory(file.path(folder_name, data_format, "over_time"))
  create_required_directory(file.path(folder_name, data_format, "over_time", reference_geo_code))

  if (!is.null(time_window)) {

    time_series_nmonthly(params, reference_geo_code)
  } else {
    time_series_monthly(params, reference_geo_code)
  }

  logger$info("[bold green]Collected Time Series Data![/]")
}
