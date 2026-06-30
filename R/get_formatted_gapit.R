#' Import and format GAPIT output results for [plot_manhattan()] usage
#'
#' @param result_directory : str     Directory GAPIT package exported one folder
#'                                   for each trait.
#' @param gapit_cutOff     : double  Value used for 'cutOff' argument during
#'                                   GAPIT analysis.
#' @param verbose          : bool    Print which trait is being formatted if TRUE
#'
#' @returns GAPIT.thresh object.
#' @export
#' @importFrom magrittr %>%
#'
#' @examples
#' \dontrun{
#' get_formatted_gapit(result_directory = "./GAPIT")
#' }
#'
#' @seealso
#' * [extract_markers()] for significant marker extraction.
#' * [plot_manhattan()] for beautified Manhattan plot.
get_formatted_gapit <- function(result_directory, gapit_cutOff  = 0.05, verbose = TRUE) {
  # Look for existing GAPIT directory
  stopifnot(file.exists(result_directory))
  # Get list of folder (traits)
  traits <- list.dirs(
    path = result_directory,
    full.names = FALSE,
    recursive = FALSE
  )
  stopifnot(length(traits)>0)
  # Generate empty output
  gapit_output <- list()
  # Loop each traits
  for (trait in traits) {
    if(verbose) {
      print(paste("Formating trait", trait))
    }
    # Get file list for the trait
    gapit_files <- list.files(path = paste(result_directory, trait, sep = "/"))
    # Get models files
    models_results_files <- gapit_files[which(
      startsWith(gapit_files, "GAPIT.Association.GWAS_Results.") &
        endsWith(gapit_files, "(NYC).csv")
    )]
    # Extract data from each file
    for (file in models_results_files) {
      # Get model name
      model_name <- sub(
        eval(paste0(".", trait, ".*")),
        "",
        sub("GAPIT.Association.GWAS_Results.", "", file)
      )
      # Get data and format for scores and map manipulation
      tmp_file <- read.csv(paste(result_directory, trait, file, sep = "/")) %>%
        dplyr::select(SNP, Chr, Pos, P.value) %>%
        dplyr::mutate(Chr = factor(Chr, ordered = TRUE)) %>%
        dplyr::rename(Marker = SNP, Chrom = Chr, Position = Pos) %>%
        dplyr::mutate(Marker_row = Marker) %>%
        tibble::column_to_rownames(var = "Marker_row") %>%
        dplyr::mutate(P.value = -log10(P.value))
      # Generate a LOD score table
      if (is.null(gapit_output$scores[[trait]])) {
        gapit_output$scores[[trait]] <- data.frame(
          tmp_file$P.value,
          row.names = tmp_file$Marker
        )
      } else {
        gapit_output$scores[[trait]] <- merge(
          gapit_output$scores[[trait]],
          tmp_file["P.value"],
          by = 0,
          all = TRUE
        )
        # Rename rownames and remove poped column
        rownames(gapit_output$scores[[trait]]) <- gapit_output$scores[[trait]]$Row.names
        gapit_output$scores[[trait]]$Row.names <- NULL
      }
      # Change column name to model name
      gapit_output$scores[[trait]] <- gapit_output$scores[[trait]] %>%
        dplyr::rename("{model_name}" := dplyr::last_col())
      # Generate or correct map
      if (is.null(gapit_output$map)) {
        gapit_output$map <- tmp_file[, c("Marker", "Chrom", "Position")]
      } else {
        if (!all(tmp_file$Marker %in% gapit_output$map$Marker)) {
          gapit_output$map <- rbind(
            gapit_output$map,
            tmp_file[!tmp_file$Marker %in% gapit_output$map$Marker,
                     c("Marker", "Chrom", "Position"),
                     drop = FALSE]
          )
        }
      }
    }
    # Free memory
    rm (tmp_file)
    # Set threshold matrix using GAPIT logic
    threshold <- -log10(gapit_cutOff /nrow(gapit_output$scores[[trait]]))
    # Generate threshold matrix or append threshold to it
    if (is.null(gapit_output$threshold)) {
      gapit_output$threshold <- matrix(
        rep(threshold, times = length(models_results_files)),
        nrow = 1
      )
      colnames(gapit_output$threshold) <- sub(
        eval(paste0(".", trait, ".*")),
        "",
        sub("GAPIT.Association.GWAS_Results.", "", models_results_files)
      )
    } else {
      gapit_output$threshold <- rbind(
        gapit_output$threshold,
        "trait" =  rep(threshold, times = length(models_results_files)))
    }
    rownames(gapit_output$threshold)[nrow(gapit_output$threshold)] <- trait
  }
  # Sort map
  gapit_output$map <- gapit_output$map %>%
    arrange(Chrom, Position)
  rownames(gapit_output$map) <- NULL
  # Sort scores using map order
  for (trait in traits) {
    gapit_output$scores[[trait]] <- gapit_output$scores[[trait]][
      match(gapit_output$map$Marker, rownames(gapit_output$scores[[trait]])),
    ]
  }
  # Define class for GAPIT that match GWASpoly.thresh format
  setClass(
    Class = "GAPIT.thresh",
    slots = list(
      threshold = "matrix",
      scores = "list",
      map = "data.frame"
    )
  )
  # Generate GAPIT.thresh object
  gt <- new(
    "GAPIT.thresh",
    threshold = gapit_output$threshold,
    scores = gapit_output$scores,
    map = gapit_output$map)

  return(gt)
}
