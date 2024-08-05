#' Collect Cross Section Data
#'
#' This function collects cross section data for a given keyword and timeline using the Google Trends API.
#' It retrieves data using the pytrends.interest_by_region() method and saves it automatically to the specified directory.
#'
#' @param params A list containing parameters including logger, data_format, folder_name, start_date, end_date, keyword, topic, num_of_days, and pytrend.
#' @param geo Country/Region to collect data from. Defaults to worldwide if empty.
#' @param resolution Resolution level for the data ('COUNTRY', 'REGION', 'CITY'). Defaults to 'COUNTRY'.
#' @details
#' This function collects Google Trends data based on the specified parameters and saves it in the following structure:
#' \code{folder_name/data_format/by_region}.
#' Each file contains data for a specific time period (day/week/month) and geographical region.
#' The filenames include the start and end dates of the data period.
#'
#' PS: This method may take a long time to complete due to Google Trends API rate limits.
#' For example, collecting 350 days of daily data can take approximately 5 hours.

#' @return NULL
#'
#' @examples
#' \dontrun{
#' # Create a temporary folder for the example
#' temp_folder <- file.path(tempdir(), "google_trends_example")
#' dir.create(temp_folder, showWarnings = FALSE)
#'
#' # Ensure the temporary folder is cleaned up after the example
#' on.exit(unlink(temp_folder, recursive = TRUE))
#'
#' # Initialize request trends with the temporary folder
#' params <- initialize_request_trends(
#'   keyword = "Joe Biden",
#'   topic = "/m/012gx2",
#'   folder_name = temp_folder,
#'   start_date = "2024-02-01",
#'   end_date = "2024-05-1",
#'   data_format = "weekly"
#' )
#'
#' # Run the cross_section function with the parameters
#' tryCatch({
#'   cross_section(params, geo = "US", resolution = "REGION")
#' }, pytrends.exceptions.TooManyRequestsError = function(e) {
#'   message("Too many requests error: ", conditionMessage(e))
#'   # You can add additional handling or logging here if needed
#' })
#' }


#' @importFrom utils read.csv write.csv
#' @export

cross_section <- function(params, geo = "", resolution = "COUNTRY") {
  logger <- params$logger
  data_format <- params$data_format
  folder_name <- params$folder_name
  start_date <- params$start_date
  end_date <- params$end_date
  keyword <- params$keyword
  topic <- params$topic
  num_of_days <- params$num_of_days
  pytrend <- params$pytrend

  logger$info("Collecting Cross Section Data now")
  res <- c("COUNTRY", "REGION", "CITY")

  if (geo == "") {
    stop("geo cannot be empty. For worldwide data, geo='Worldwide'")
  }

  if ((geo == "" && resolution != "COUNTRY") || (geo != "" && !(resolution %in% res))) {
    logger$info("Incorrect Resolution Provided. Defaulting to 'COUNTRY'")
    resolution <- "COUNTRY"
  }

  create_required_directory(file.path(folder_name, data_format, "by_region"))

  if (data_format == 'daily') {
    chng_delta <- lubridate::days(1)
    end_delta <- lubridate::days(0)
    form <- 'day'
  } else if (data_format == 'weekly') {
    chng_delta <- lubridate::weeks(1)
    end_delta <- lubridate::weeks(1) - lubridate::days(1)
    form <- 'week'
  } else if (data_format == 'monthly') {
    chng_delta <- months(1)
    end_delta <- months(1) - lubridate::days(1)
    form <- 'month'
  }

  current_time <- start_date
  i <- 0
  logger$info("Please note that this method may take hours to finish. Have patience.", extra = list(markup = TRUE))

  while (TRUE) {
    if ((data_format == 'weekly' && current_time >= end_date) || (data_format != 'weekly' && current_time > end_date)) {
      break
    }

    current_end_time <- current_time + end_delta
    current_time_str <- format(current_time, "%Y-%m-%d")
    current_end_time_str <- format(current_end_time, "%Y-%m-%d")

    file_path <- file.path(folder_name, data_format, "by_region", sprintf("%s_%d-%s-%s.csv", form, i + 1, current_time_str, current_end_time_str))

    if (file.exists(file_path)) {
      logger$info(sprintf("Data for %s-%s already collected. Moving to next date...", current_time_str, current_end_time_str), extra = list(markup = TRUE))
      current_time <- current_time + chng_delta
      i <- i + 1
    } else {
      tryCatch({
        pytrend$build_payload(kw_list = list(topic), geo = geo, timeframe = sprintf('%s %s', current_time_str, current_end_time_str))
        Sys.sleep(5)
        df <- pytrend$interest_by_region(resolution = resolution, inc_geo_code = TRUE, inc_low_vol = TRUE)
        df <- reticulate::py_to_r(df)
        names(df)[names(df) == keyword] <- keyword
        i <- i + 1
        write.csv(df, file = file.path(folder_name, data_format, "by_region", paste0(form, "_", i, "-", format(current_time, "%Y%m%d"), "-", format(current_end_time, "%Y%m%d"), ".csv")))

      }, error = function(e) {
        if (inherits(e, "ResponseError")) {
          logger$info("Please have patience as we reset rate limit ... ", extra = list(markup = TRUE))
          Sys.sleep(5)
        } else {
          stop(e)
        }
      })
      Sys.sleep(5)
      current_time <- current_time + chng_delta
    }
  }
  logger$info("[bold green]Successfully Collected Cross Section Data![/]", extra = list(markup = TRUE))
}
