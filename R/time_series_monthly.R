#' Time Series Data Collection Method for 'monthly'
#'
#' This function collects time series data on a monthly basis using the Google Trends API.
#' It retrieves interest over time data using pytrends.interest_over_time() and saves it to the specified directory.
#'
#' @param params A list containing parameters including logger, pytrend, folder_name, data_format, start_date, end_date, keyword, and topic.
#' @param reference_geo_code Geographic code to specify the location for data collection (default is "US").
#' @keywords internal
#' @details
#' This function collects Google Trends time series data based on the specified parameters and saves it in the following structure:
#' \code{folder_name/data_format/over_time/reference_geo_code}.
#' The filename includes the start and end dates of the data period.
#' @importFrom utils read.csv write.csv
#' @return NULL


time_series_monthly <- function(params, reference_geo_code = "US") {

  logger <- params$logger
  pytrend <- params$pytrend
  folder_name <- params$folder_name
  data_format <- params$data_format
  start_date <- params$start_date
  end_date <- params$end_date
  keyword <- params$keyword
  topic <- params$topic

  # Create file path
  file_path <- file.path(folder_name, data_format, "over_time", reference_geo_code, sprintf("%s-%s.csv", format(start_date, "%Y%m%d"), format(end_date, "%Y%m%d")))

  # Check if file already exists
  if (file.exists(file_path)) {
    logger$info("All Data for current request is already collected", extra = list(markup = TRUE))
  } else {
    tryCatch({
      # Build the payload
      pytrend$build_payload(kw_list = list(topic), geo = reference_geo_code,
                            timeframe = sprintf('%s %s', format(start_date, "%Y-%m-%d"), format(end_date, "%Y-%m-%d")))
      Sys.sleep(5)

      # Get interest over time data
      df <- pytrend$interest_over_time()

      # Convert to R dataframe and rename columns
      df <- reticulate::py_to_r(df)

      # Save the dataframe to a CSV file
      write.csv(df, file_path)
    }, ResponseError = function(e) {
      logger$info("Please have patience as we reset rate limit ... ", extra = list(markup = TRUE))
      Sys.sleep(5)
    }, error = function(e) {

      logger$error(sprintf("[bold red]Whoops![/] An error occurred during the request"), exc_info = TRUE, extra = list(markup = TRUE))
    })
  }
}
