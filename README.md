# GWASpoly.beautifier

<!-- badges: start -->
<!-- badges: end -->

`GWASpoly.beautifier` is a small utility package that helps turn
[`GWASpoly`](https://github.com/jendelman/GWASpoly) version 2 outputs into
publication-ready Manhattan plots and marker tables.

The package is designed for users who already run GWAS analyses with
`GWASpoly`, but want more control over plotting style, significant marker
highlighting, chromosome spacing, plot dimensions, and marker export.

## Main features

- Extract all markers or only markers above the GWAS threshold from a
  `GWASpoly.thresh` object.
- Create customized Manhattan plots from `GWASpoly::set.threshold(...)` output.
- Highlight all significant markers, or only a selected list of significant
  markers.
- Save Manhattan plots with a height adapted to the number of plotted traits.
- Keep the workflow compatible with standard `GWASpoly` objects.

## Installation

You can install the development version of `GWASpoly.beautifier` from GitHub:

``` r
install.packages("remotes")
remotes::install_github("coulombevin/GWASpoly.beautifier")
```

## Suggested package dependencies

In your `DESCRIPTION` file, the package should import the packages used inside
exported functions:

``` text
Imports:
    dplyr,
    ggplot2,
    tidyr
```

If your examples or tests use the GWASpoly vignette dataset, add these packages
under `Suggests`:

``` text
Suggests:
    GWASpoly,
    testthat (>= 3.0.0)
Config/testthat/edition: 3
```

## Example workflow

This example reproduces the main structure of the GWASpoly Version 2 vignette,
then uses `GWASpoly.beautifier` to extract significant markers, create a
Manhattan plot, and save it.

``` r
library(GWASpoly)
library(GWASpoly.beautifier)

# Example files included with GWASpoly
genofile <- system.file("extdata", "new_potato_geno.csv", package = "GWASpoly")
phenofile <- system.file("extdata", "new_potato_pheno.csv", package = "GWASpoly")

# Read data
data <- read.GWASpoly(ploidy = 4, pheno.file = phenofile, geno.file = genofile, 
  format = "numeric", n.traits = 1, delim = ",")

# Fit GWASpoly model
data_loco <- set.K(data, LOCO = TRUE, n.core = 2)

N <- 957
params <- set.params(geno.freq = 1 - 5 / N, fixed = "env", fixed.type = "factor")

data_loco_scan <- GWASpoly(data = data_loco, models = c("additive", "1-dom"),
  traits = c("vine.maturity"), params = params, n.core = 2)

# Add significance threshold
data_with_threshold <- set.threshold(data_loco_scan, method = "M.eff", 
  level = 0.05)
```

## Extract markers

Use `extract_markers()` to convert the relevant marker information from the
`GWASpoly.thresh` object into a regular data frame.

``` r
significant_markers <- extract_markers(data = data_with_threshold)

head(significant_markers)
```

To extract all markers instead of only significant markers:

``` r
all_markers <- extract_markers(data = data_with_threshold,
                               significant_only = FALSE)
```

## Create a beautified Manhattan plot

Here's all possible parameters.

``` r
p <- plot_manhattan(data = data_with_threshold,
                    traits = NULL,
                    models = NULL,
                    chrom = NULL,
                    chrom_color = c('#219ebc', '#8ecae6'),
                    significant_color = '#fb8500',
                    point_size = 1.5,
                    point_alpha = NA,
                    threshold_line_color = 'grey50',
                    threshold_line_type = 2,
                    significant_markers = NULL,
                    gap_size=0.01)

p
```

If `significant_markers != NULL`, only the markers in that data frame 
(with a score above the threshold) are highlighted when `significant_color` 
is not `NULL`.

``` r
p <- plot_manhattan(data = data_with_threshold, 
                    significant_markers = head(significant_markers))

p
```

If `significant_markers = NULL`, all markers above the threshold are highlighted
when `significant_color` is not `NULL`.

``` r
p_all_significant <- plot_manhattan(data_with_threshold)
```

If `significant_color = NULL`, no separate significant-marker highlight layer is
added.

``` r
p_no_highlight <- plot_manhattan(data = data_with_threshold,
                                 significant_color = NULL)
```

## Save the plot

`save_manhattan()` saves a `ggplot` object and automatically adjusts the figure
height according to the number of facet panels.

``` r
save_manhattan(gwas_plot = p, file_name = "vine_maturity_manhattan.png")
```

You can also save to PDF, jpeg, ... by changing the file extension:

``` r
save_manhattan(gwas_plot = p, file_name = "vine_maturity_manhattan.pdf")
```

## Function overview

### `extract_markers()`

``` r
extract_markers(data, significant_only = TRUE)
```

Returns a data frame containing the trait, marker name, chromosome, position,
and GWAS model scores. When `significant_only = TRUE`, only markers with at
least one model score above the corresponding threshold are returned.

### `plot_manhattan()`

``` r
plot_manhattan(
  data,
  traits = NULL,
  models = NULL,
  chrom = NULL,
  chrom_color = c("#219ebc", "#8ecae6"),
  significant_color = "#fb8500",
  point_size = 1.5,
  point_alpha = NA,
  threshold_line_color = "grey50",
  threshold_line_type = 2,
  significant_markers = NULL,
  gap_size = 0.01
)
```

Creates a customized Manhattan plot from a `GWASpoly.thresh` object. The
function requires thresholded GWASpoly output, unlike the default GWASpoly
Manhattan plotting workflow.

### `save_manhattan()`

``` r
save_manhattan(gwas_plot, file_name)
```

Saves a Manhattan plot generated as a `ggplot` object. The output file type is
inferred from the file extension supplied in `file_name`.

## Notes

This package does not replace `GWASpoly`. It is intended as a lightweight
post-processing and visualization companion for GWASpoly analyses.

