# Shared test data adapted from the GWASpoly Version 2 vignette by Jeff Endelman
# https://jendelman.github.io/GWASpoly/GWASpoly.html
# Date: 2026.06.16

.make_gwaspoly_threshold_data <- local({
  cache <- NULL

  function() {
    testthat::skip_if_not_installed('GWASpoly')

    if (!is.null(cache)) {
      return(cache)
    }

    genofile <- system.file('extdata', 'new_potato_geno.csv', package = 'GWASpoly')
    phenofile <- system.file('extdata', 'new_potato_pheno.csv', package = 'GWASpoly')

    testthat::skip_if(genofile == '', 'GWASpoly example genotype file not found.')
    testthat::skip_if(phenofile == '', 'GWASpoly example phenotype file not found.')

    data <- GWASpoly::read.GWASpoly(
      ploidy = 4,
      pheno.file = phenofile,
      geno.file = genofile,
      format = 'numeric',
      n.traits = 1,
      delim = ','
    )

    data_loco <- GWASpoly::set.K(data, LOCO = TRUE, n.core = 1)

    N <- 957
    params <- GWASpoly::set.params(
      geno.freq = 1 - 5 / N,
      fixed = 'env',
      fixed.type = 'factor'
    )

    data_loco_scan <- GWASpoly::GWASpoly(
      data = data_loco,
      models = c('additive', '1-dom'),
      traits = c('vine.maturity'),
      params = params,
      n.core = 1
    )

    cache <<- GWASpoly::set.threshold(
      data_loco_scan,
      method = 'M.eff',
      level = 0.05
    )

    cache
  }
})
