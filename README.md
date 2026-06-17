# GWASpoly.beautifier

<!-- badges: start -->
[![R-CMD-check](https://github.com/coulombevin/GWASpoly.beautifier/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/coulombevin/GWASpoly.beautifier/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

`GWASpoly.beautifier` is a small utility package that helps turn [`GWASpoly`](https://github.com/jendelman/GWASpoly) version 2 outputs into publication-ready Manhattan plots and marker tables.

The package is designed for users who already run GWAS analyses with `GWASpoly`, but want more control over plotting style, significant marker highlighting, chromosome spacing, plot dimensions, and marker export.

## Comparison

Library | Plot
:---:|:---:
GWASPoly | <img width="3375" height="675" alt="GWASpoly" src="https://github.com/user-attachments/assets/8ef0609d-8d49-487f-b82b-3ddf38e3b5f4" /> 
GWASpoly beautifier | <img width="3375" height="675" alt="GWASpoly beautifier" src="https://github.com/user-attachments/assets/a045423d-fc4c-4ed3-a004-66fe8ac9fcbd" />

## Main features

- Extract all markers or only markers above the GWAS threshold from a `GWASpoly.thresh` object.
- Create customized Manhattan plots from `GWASpoly::set.threshold(...)` output.
- Highlight all significant markers, or only a selected list of significant markers.
- Save Manhattan plots with a height adapted to the number of plotted traits.
- Keep the workflow compatible with standard `GWASpoly` objects.

## Installation

You can install the development version of `GWASpoly.beautifier` from GitHub:

``` r
install.packages("remotes")
remotes::install_github("coulombevin/GWASpoly.beautifier")
```

## Example workflow

This example reproduces the main structure of the GWASpoly Version 2 vignette, then uses `GWASpoly.beautifier` to extract significant markers, create a Manhattan plot, and save it.

``` r
library(GWASpoly)
library(GWASpoly.beautifier)

# Example files included with GWASpoly
genofile <- system.file("extdata", "new_potato_geno.csv", package = "GWASpoly")
phenofile <- system.file("extdata", "new_potato_pheno.csv", package = "GWASpoly")

# Read data
data <- read.GWASpoly(ploidy = 4, pheno.file = phenofile, geno.file = genofile, format = "numeric", n.traits = 1, delim = ",")

# Fit GWASpoly model
data_loco <- set.K(data, LOCO = TRUE, n.core = 2)

N <- 957
params <- set.params(geno.freq = 1 - 5 / N, fixed = "env", fixed.type = "factor")

data_loco_scan <- GWASpoly(data = data_loco, models = c("additive", "1-dom"), traits = c("vine.maturity"), params = params, n.core = 2)

# Add significance threshold
data_with_threshold <- set.threshold(data_loco_scan, method = "M.eff", level = 0.05)
```

## Extract markers

Use `extract_markers()` to convert the relevant marker information from the `GWASpoly.thresh` object into a regular data frame.

``` r
significant_markers <- extract_markers(data = data_with_threshold)

head(significant_markers)

#           trait              Marker  additive 1-dom-alt  1-dom-ref Chrom Position
# 1 vine.maturity solcap_snp_c2_54335  5.225447 2.0624696 1.69601346 chr04 56277376
# 2 vine.maturity solcap_snp_c1_10751  5.028428 1.7368136 2.10121407 chr04 56641710
# 3 vine.maturity solcap_snp_c2_11851  6.398708 0.8355040 4.56589342 chr05  3955639
# 4 vine.maturity       PotVar0026425  5.640068        NA 3.09710652 chr05  4333934
# 5 vine.maturity       PotVar0078045 19.440148 1.1944001 0.08347777 chr05  4359118
# 6 vine.maturity       PotVar0078411  6.869819 0.7598943 0.82621292 chr05  4370035
```

To extract all markers instead of only significant markers:

``` r
all_markers <- extract_markers(data = data_with_threshold, significant_only = FALSE)

head(all_markers)

#           trait              Marker  additive 1-dom-alt   1-dom-ref Chrom Position
# 1 vine.maturity solcap_snp_c2_36608 1.2767930 0.6882403 0.009385239 chr01   508800
# 2 vine.maturity solcap_snp_c2_36658 0.7275347        NA 0.233650964 chr01   527068
# 3 vine.maturity solcap_snp_c1_10930 0.3234306        NA 0.047479482 chr01   566972
# 4 vine.maturity       PotVar0120126 0.8730041        NA 0.316506892 chr01   603013
# 5 vine.maturity solcap_snp_c2_36629 0.6189437        NA 0.036880059 chr01   681589
# 6 vine.maturity       PotVar0120070 0.5117262        NA 0.047284840 chr01   681589
```

## Create a beautified Manhattan plot

Here's a fully customised Manhattan plot.

``` r
p <- plot_manhattan(data_with_threshold,,
                    traits = 'vine.maturity',
                    chrom_color = c('#74c69d', '#b7e4c7'),
                    significant_color = '#bc4749',
                    point_size = 1,
                    threshold_line_color = '#1b4332',
                    threshold_line_type = 3,
                    gap_size=0.03)
```
<img width="3375" height="675" alt="GWASpoly beautifier_custom" src="https://github.com/user-attachments/assets/e2ee370d-b853-4f61-9279-6f78016219c4" />

&nbsp;
<br>

If `significant_markers = NULL`, all markers above the threshold are highlighted when `significant_color` is not `NULL`.

``` r
p_all_significant <- plot_manhattan(data_with_threshold)
```
<img width="3375" height="675" alt="GWASpoly beautifier" src="https://github.com/user-attachments/assets/a045423d-fc4c-4ed3-a004-66fe8ac9fcbd" />

&nbsp;
<br>

If `significant_markers != NULL`, only the markers in that data frame (with a score above the threshold) are highlighted when `significant_color` is not `NULL`.

``` r
p <- plot_manhattan(data = data_with_threshold, significant_markers = dplyr::filter(significant_markers, Chrom == 'chr05'))
```
<img width="3375" height="675" alt="GWASpoly beautifier_head_significant" src="https://github.com/user-attachments/assets/96735065-930b-4358-bdc2-69f9e1ac807c" />

&nbsp;
<br>

If `significant_color = NULL`, no separate significant-marker highlight layer is added.

``` r
p_no_highlight <- plot_manhattan(data = data_with_threshold, significant_color = NULL)
```
<img width="3375" height="675" alt="GWASpoly beautifier_no_sig_color" src="https://github.com/user-attachments/assets/8c6ba9fe-dde6-46a8-a22d-a7b638a6d388" />
&nbsp;
<br>
## Save the plot

`save_manhattan()` saves a `ggplot` object and automatically adjusts the figure height according to the number of facet panels.

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

Returns a data frame containing the trait, marker name, chromosome, position, and GWAS model scores. When `significant_only = TRUE`, only markers with at least one model score above the corresponding threshold are returned.

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

Creates a customized Manhattan plot from a `GWASpoly.thresh` object. The function requires thresholded GWASpoly output, unlike the default GWASpoly Manhattan plotting workflow.

### `save_manhattan()`

``` r
save_manhattan(gwas_plot, file_name)
```

Saves a Manhattan plot generated as a `ggplot` object. The output file type is inferred from the file extension supplied in `file_name`.

## Notes

This package does not replace `GWASpoly`. It is intended as a lightweight
post-processing and visualization companion for GWASpoly analyses.

