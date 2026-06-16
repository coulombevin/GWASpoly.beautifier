test_that('extract_markers returns a data frame with marker metadata', {
  data_with_threshold <- .make_gwaspoly_threshold_data()

  markers <- extract_markers(data_with_threshold,
                             significant_only=FALSE)

  expect_s3_class(markers, 'data.frame')
  expect_true(all(c('trait', 'Marker', 'Chrom', 'Position') %in% names(markers)))
  expect_gt(nrow(markers), 0)
  expect_true(all(markers$trait %in% names(data_with_threshold@scores)))
})

test_that('extract_markers filters significant markers when requested', {
  data_with_threshold <- .make_gwaspoly_threshold_data()

  all_markers <- extract_markers(data_with_threshold,
                                 significant_only=FALSE)
  significant_markers <- extract_markers(data_with_threshold,
                                         significant_only=TRUE)

  expect_s3_class(significant_markers, 'data.frame')
  expect_lte(nrow(significant_markers), nrow(all_markers))

  score_cols <- colnames(data_with_threshold@scores[[1]])
  threshold <- data_with_threshold@threshold[1]

  if (nrow(significant_markers) > 0) {
    expect_true(all(apply(significant_markers[, score_cols, drop = FALSE], 1, function(x) {
      any(x >= threshold, na.rm = TRUE)
    })))
  }
})

test_that('extract_markers rejects objects that are not GWASpoly.thresh', {
  expect_error(extract_markers(data.frame(x = 1), significant_only = TRUE),
               regexp = NA)
})
