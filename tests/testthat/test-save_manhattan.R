test_that('save_manhattan saves a plot file', {
  data_with_threshold <- .make_gwaspoly_threshold_data()
  p <- plot_manhattan(data_with_threshold, traits = 'vine.maturity')

  outfile <- tempfile(fileext = '.png')
  save_manhattan(p, outfile)

  expect_true(file.exists(outfile))
  expect_gt(file.info(outfile)$size, 0)
})

test_that('save_manhattan rejects non-ggplot objects', {
  outfile <- tempfile(fileext = '.png')

  expect_error(save_manhattan(data.frame(x = 1), outfile),
               regexp = "ggplot|n'est pas TRUE|is not TRUE")
})
