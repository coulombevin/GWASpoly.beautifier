test_that('plot_manhattan returns a ggplot object', {
  data_with_threshold <- .make_gwaspoly_threshold_data()

  p <- plot_manhattan(data_with_threshold, traits = 'vine.maturity')

  expect_s3_class(p, 'ggplot')
})

test_that('plot_manhattan accepts selected models', {
  data_with_threshold <- .make_gwaspoly_threshold_data()

  p <- plot_manhattan(data_with_threshold,
                      traits = 'vine.maturity',
                      models = 'additive')

  built <- ggplot2::ggplot_build(p)

  expect_s3_class(p, 'ggplot')
  expect_gt(nrow(built$data[[1]]), 0)
})

test_that('plot_manhattan accepts a significant marker data frame', {
  data_with_threshold <- .make_gwaspoly_threshold_data()
  significant_markers <- extract_markers(data_with_threshold, significant_only = TRUE)

  p <- plot_manhattan(data_with_threshold,
                      traits = 'vine.maturity',
                      significant_markers = significant_markers)

  expect_s3_class(p, 'ggplot')
})

test_that('plot_manhattan rejects objects that are not GWASpoly.thresh', {
  expect_error(plot_manhattan(data.frame(x = 1)),
               regexp = NA)
})
