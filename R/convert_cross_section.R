#' Converting Cross-section data method
#' @param params A list containing parameters including logger, folder_name, data_format, time_window, and other necessary parameters for sub-functions.
#' @param reference_geo_code Same as the reference_geo from time_series(). If any other is used, then the result will not be accurate
#' @param zero_replace Same as zero_replace from concat_time_series(). It is highly recommended to use the same to avoid incosistent results.
#' @details
#' This final method will rescale the cross section data based on the concatenated time series data.
#' This will finally provide the accurate google trends index for each region/country/city over the provided time period.
#' @return NULL
#'
#' @examples
#' \dontrun{
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
#' cross_section(params, geo = "US", resolution = "REGION")
#' time_series(params, reference_geo_code = "US-CA")
#' convert_cross_section(params, reference_geo_code = "US-CA")
#'
#' # Clean up temporary directory
#' unlink(folder_name, recursive = TRUE)
#' }

#' @importFrom utils read.csv write.csv tail
#' @export
#'

convert_cross_section <- function(params, reference_geo_code = "US-CA", zero_replace = 0.1) {

  logger <- params$logger
  folder_name <- params$folder_name
  data_format <- params$data_format
  keyword <- params$keyword
  topic <- params$topic
  start_date <- params$start_date
  end_date <- params$end_date

  logger$info("Rescaling cross section Data now", extra = list(markup = TRUE))

  # Create required directories
  create_required_directory(file.path(folder_name, data_format, "converted"))
  create_required_directory(file.path(folder_name, data_format, "converted", reference_geo_code))

  concat_file_path <- file.path(folder_name, data_format, "concat_time_series", paste0(reference_geo_code, ".csv"))
  if (file.exists(concat_file_path)) {
    time_series_concat <- read.csv(concat_file_path, header = TRUE, check.names = FALSE)
  } else {
    files_in_over_time <- list.files(file.path(folder_name, data_format, "over_time", reference_geo_code), full.names = TRUE)
    time_series_concat <- read.csv(files_in_over_time, header = TRUE, check.names = FALSE)
  }

  names(time_series_concat)[names(time_series_concat) == ''] <- 'date'

  # Initialize empty data frame for conversion result
  conv <- data.frame()

  # Iterate over rows in time_series_concat
  for (ind in seq_len(nrow(time_series_concat))) {
    record <- format(as.POSIXct(as.character(time_series_concat$date[ind]), format = "%Y-%m-%d %H:%M:%S"), "%Y%m%d")
    time_ind <- as.numeric(time_series_concat[[keyword]][ind])

    # Construct snapshot file path based on record date
    snap_file <- list.files(path = file.path(folder_name, data_format, "by_region"), pattern = paste0(".*", record, ".*csv"), full.names = TRUE)[1]


    # Extract column name from snapshot file
    if (Sys.info()['sysname'] == "Windows") {

      fl_name <- tail(unlist(strsplit(snap_file, "\\\\")), 1)

    } else {

      fl_name <- tail(unlist(strsplit(snap_file, "/")), 1)

    }

    col_name <- gsub("\\.csv", "", fl_name)

    # Read snapshot data
    snap_df <- read.csv(snap_file, header = TRUE, stringsAsFactors = FALSE, na.strings = "", check.names = FALSE)

    #snap_df[[keyword]][is.na(snap_df[[keyword]])] <- zero_replace
    col_name_in_snap <- ifelse(keyword %in% names(snap_df), keyword,
                               ifelse(topic %in% names(snap_df), topic, NA))



    # Replace NA values with zero_replace
    snap_df[[col_name_in_snap]][is.na(snap_df[[col_name_in_snap]])] <- zero_replace

    #cat(col_name_in_snap)


    # Find reference value based on geoCode
    ref_value <- as.numeric(snap_df[snap_df$geoCode == reference_geo_code, col_name_in_snap])


    # Calculate conversion multiplier
    conv_multiplier <- time_ind / ref_value

    # Perform conversion on snapshot dataframe
    snap_df[[col_name]] <- round(snap_df[[col_name_in_snap]] * conv_multiplier, 2)


    # Collect initial geoName and geoCode if it's the first iteration
    if (ind == 1) {
      conv <- snap_df[, c(1, which(names(snap_df) == "geoCode"))]
    }



    # Append converted data to conv data frame
    conv[[col_name]] <- snap_df[[col_name]]
  }

  # Write converted DataFrame to CSV
  write.csv(conv, file.path(folder_name, data_format, "converted", reference_geo_code, paste0("final-converted-",
                                                                                              format(start_date, "%Y%m%d"), "-",
                                                                                              format(end_date, "%Y%m%d"), ".csv")), row.names = FALSE)



  logger$info("[bold green]DONE Converting! :) [/]", extra = list(markup = TRUE))
}
