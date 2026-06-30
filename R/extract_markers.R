#' Extract all/significant markers from GWASpoly.thresh or GAPIT.thresh data
#' obtained with [GWASpoly::set.threshold()] or [get_formatted_gapit()] command.
#'
#' @param data             : 'package'.thresh GWASpoly or GAPIT threshold
#'                                            formated data.
#' @param significant_only : bool             Extract only markers above
#'                                            threshold.
#'
#' @returns data.frame object with all requested markers.
#' @export
#' @importFrom magrittr %>%
#' @examples
#' \dontrun{
#' significant_markers <- extract_markers(data = data_with_threshold)
#' }
#' @seealso
#' [get_formatted_gapit()] for GAPIT output data conversion.
extract_markers <- function (data, significant_only = TRUE) {
  # Allow only data from GWASpoly::set.threshold(...) or
  # GWASbeautifier::get_formatted_gapit(...) command.
  stopifnot(inherits(data, 'GWASpoly.thresh') | inherits(data, "GAPIT.thresh"))
  # Define columns names
  col_names <- c(c('trait', 'Marker', 'Chrom', 'Position'), colnames(data@scores[[1]]))
  # Generate data frame
  data_markers <- data.frame(matrix(ncol = length(col_names), nrow = 0))
  # Set columns names
  colnames(data_markers) <- col_names

  # Loop trough traits
  for (i in seq(from = 1, to = length(data@scores))) {
    # Generate a data frame using marker, trait, scores, chrom and pos
    data_tmp <- data@scores[[i]] %>%
      dplyr::mutate(Marker = rownames(.), .before = 1) %>%
      dplyr::mutate(trait = names(data@scores[i]), .before = 1) %>%
      dplyr::left_join(dplyr::select(data@map, Marker, Chrom, Position), by = 'Marker') %>%
      relocate(Chrom, .after = Marker) %>%
      relocate(Position, .after = Chrom)

    if (significant_only) {
      # Get the threshold
      thr <- data@threshold[i]
      # Filter for significant markers
      data_tmp <- data_tmp %>%
        dplyr::filter(dplyr::if_any(dplyr::all_of(colnames(data@scores[[i]])), ~ .x >= thr))
    }
    # Append filtered data to significant data frame
    data_markers <- rbind(data_markers, data_tmp)
    # Reset row index
    rownames(data_markers) <- NULL
  }

  return(data_markers)
}
