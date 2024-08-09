#' Concatenation of Time series method
#'
#' @param params A list containing parameters including logger, folder_name, data_format, time_window, and other necessary parameters for sub-functions.
#' @param reference_geo_code This is the same geo code that is used in collecting time_series data. If the time_series data for that geo is not collected beforehand, or the file does not exist, it will throw and error. Default is 'US'
#' @param zero_replace As data from different time periods are rescaled, sometimes the last/first data point of a period might be zero. Then the calculation will throw error or everything single data point will become zero. To avoid that, we are tweaking the zeroes to be of an insignificant number to carry on with the calculation.

#' @details
#' This method will concat the time series data collected in time_series() method.
#' Because the data points in time_series is independent of each other, they needs to be re-aligned to get correct index for the given time period.
#' This method concatenates time_series data for all the period and gives back the combined rescaled time_series data for the reference timeline.
#' This rescaled time_series data will be used in the next method to rescale the cross_section data.
#' @return NULL
#'
#' @examples
#' \donttest{
#' # Please note that this example may take a few minutes to run
#' # Create a temporary folder for the example
#'
#' # Ensure the temporary folder is cleaned up after the example
#' # Run the function with the temporary folder
#' params <- initialize_request_trends(
#'   keyword = "Joe Biden",
#'   topic = "/m/012gx2",
#'   folder_name = file.path(tempdir(), "biden_save"),
#'   start_date = "2017-12-31",
#'   end_date = "2024-05-19",
#'   data_format = "weekly"
#' )
#' result <- TRUE
#'
#' # Run the time_series function and handle TooManyRequestsError
#' tryCatch({
#'   time_series(params, reference_geo_code = "US-CA")
#' }, error = function(e) {
#'   message("An error occurred: ", conditionMessage(e))
#'   result <- FALSE # Indicate failure only on error
#' })
#'
#' # Check if at least one file is present in the expected directory
#' data_dir <- file.path("biden_save", "weekly", "over_time", "US-CA")
#' if (result && length(list.files(data_dir)) > 0) {
#'   concat_time_series(params, reference_geo_code = "US-CA")
#' } else {
#'   if (result) {
#'     message("Skipping concat_time_series because no files were found in the expected directory.")
#'   } else {
#'     message("Skipping concat_time_series because time_series failed.")
#'   }
#'   result <- FALSE
#' }
#'
#'
#' # Clean up temporary directory
#' on.exit(unlink("biden_save", recursive = TRUE))
#' }
#' @importFrom utils read.csv write.csv

#' @export
#'
concat_time_series <- function(params, reference_geo_code = "US", zero_replace = 0.1) {

  logger <- params$logger
  folder_name <- params$folder_name
  data_format <- params$data_format
  keyword <- params$keyword

  logger$info("Concatenating Over Time data now", extra = list(markup = TRUE))

  # Create Folder to save the concatenated time series data
  create_required_directory(file.path(folder_name, data_format, "concat_time_series"))

  path_to_time_data <- file.path(folder_name, data_format, "over_time", reference_geo_code)

  # List to store DataFrames
  dfs <- list()

  # Read each CSV file into a DataFrame and store in dfs list
  files <- list.files(path_to_time_data, full.names = TRUE)
  for (file in files) {
    df <- read.csv(file, check.names = FALSE)
    dfs[[length(dfs) + 1]] <- df
  }

  df <- df[, colSums(is.na(df)) != nrow(df)]

  # Replace zeros with zero_replace value
  for (i in seq_along(dfs)) {
    dfs[[i]][dfs[[i]][[keyword]] == 0, keyword] <- zero_replace
  }

  # Concatenate the time series data
  prev_window <- dfs[[1]]


  for (periods in 2:length(dfs)) {
    #print(periods)
    next_window <- dfs[[periods]]

    prev_window_multiplier <- 100 / prev_window[nrow(prev_window), keyword]
    next_window_multiplier <- 100 / next_window[1, keyword]

    prev_window[, keyword] <- prev_window[, keyword] * prev_window_multiplier
    next_window[, keyword] <- next_window[, keyword] * next_window_multiplier

    prev_window <- rbind(prev_window[-nrow(prev_window), ], next_window)

  }

  # Write concatenated DataFrame to CSV
  concat_file_path <- file.path(folder_name, data_format, "concat_time_series", paste0(reference_geo_code, ".csv"))
  write.csv(prev_window, concat_file_path, row.names = FALSE)

  logger$info("[bold green]Concatenation Complete! :)[/]", extra = list(markup = TRUE))
}
