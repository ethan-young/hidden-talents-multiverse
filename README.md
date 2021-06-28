Hidden Talents Multiverse Analysis
================

This repository contains data, code, and (some) output for a working
manuscript by Young, Frankenhuis, and Ellis (in progress).

## IMPORTANT!!

The file sizes of many output files produced by scripts in this
repository are very large. As a consequence, these output files are not
tracked here (see .gitignore). To preserve the directory structure,
files named `0-placeholder.txt` have been added to output directories.
This ensures that scripts can reproduce and save output to the correct
directory (without having to manually add them).

## Preregistration

Details about the participants, methods, procedures, and analysis plans
can be found on the Open Science Framework (OSF). Below are the relevant
links for different aspects of the project:

-   [OSF project](https://osf.io/6r95z/)
-   [Original preregistration](https://osf.io/d2gz6/)
-   [Overview of measures](https://osf.io/5kawy/), which fully describes
    what was collected (including measures not used/analyzed in this
    project). Variable codebooks for the current project are contained
    in this repository (see Codebooks below).
-   [Final preregistration](https://osf.io/4vsnz/) which also contains a
    preliminary write-up of the Methods for an eventual publication
-   [Secondary analysis plan - set 1](https://osf.io/7fu35/)
-   [Secondary analysis plan - set 2](https://osf.io/wcauf/)

## Directory Structure

The names of each folder are intended to be self-explanatory. There are
six top-level folders to organize the inputs and outputs of this
project:

1.  `codebooks/`: lists of variable names, labels, and value labels
    (where applicable).
2.  `data/`: data, stored as an `.Rdata` file and `.csv` files.
3.  `manuscript`: a manuscript written in R markdown for submission to a
    journal.
4.  `multiverse-objects/`: all `.Rdata` files containing objects
    necessary for performing multiverse analyses and storing
    intermediary results.
5.  `scripts/`: R-scripts that read, analyze, and produce all multiverse
    objects.
6.  `supplement/`: a supplemental text (to be submitted with the
    manuscript) documenting all secondary analyses in detail.

Below is a simple visualization of the full directory structure.

    ## .
    ## ├── codebooks
    ## │   ├── vars1_raw.csv
    ## │   ├── vars2_non_arbitrary.csv
    ## │   ├── vars3_composites.csv
    ## │   └── vars4_multiverse_base.csv
    ## ├── data
    ## │   ├── 1-raw.csv
    ## │   ├── 2-non_arbitrary.csv
    ## │   ├── 3-composites.csv
    ## │   ├── 4-multiverse_base.csv
    ## │   ├── data1_raw.Rdata
    ## │   └── data2_analysis.Rdata
    ## ├── manuscript
    ## │   ├── figure1.pdf
    ## │   ├── manuscript.Rmd
    ## │   ├── manuscript.pdf
    ## │   ├── nature.csl
    ## │   ├── references.bib
    ## │   ├── scripts
    ## │   │   ├── 0-corr_table.R
    ## │   │   ├── figure-2-3.R
    ## │   │   ├── rmd-staging.R
    ## │   │   ├── table1.R
    ## │   │   ├── table2.R
    ## │   │   └── table3.R
    ## │   └── staged-objects.Rdata
    ## ├── multiverse-objects
    ## │   ├── 1-multiverse-datasets
    ## │   │   ├── 0-placeholder.txt
    ## │   │   ├── datalist-agg-ivs.Rdata
    ## │   │   └── datalist-all-ivs.Rdata
    ## │   ├── 2-primary-analyses
    ## │   │   ├── 0-placeholder.txt
    ## │   │   ├── 1-confirmatory-results.Rdata
    ## │   │   ├── 2-exploratory-results.Rdata
    ## │   │   ├── 3-extracted-effects.Rdata
    ## │   │   ├── 4-bootstrapped-data.Rdata
    ## │   │   └── 5-bootstrapped-effects.Rdata
    ## │   └── 3-secondary-analyses
    ## │       ├── set-1
    ## │       │   ├── 0-placeholder.txt
    ## │       │   ├── a1-results-ses-vio.Rdata
    ## │       │   ├── a2-extracted-effects.Rdata
    ## │       │   ├── b1-results-ses-components.Rdata
    ## │       │   └── b2-extracted-effects.Rdata
    ## │       └── set-2
    ## │           ├── 0-placeholder.txt
    ## │           ├── a1-extracted-effects.Rdata
    ## │           ├── a1-results-expanded-shifting.Rdata
    ## │           └── a1-results-expanded-updating.Rdata
    ## ├── scripts
    ## │   ├── 0-functions
    ## │   │   └── create_codebook.R
    ## │   ├── 1-data-prep
    ## │   │   ├── 1-data-non-abritrary.R
    ## │   │   ├── 2-primary-multiverse-datasets.R
    ## │   │   └── 3-secondary-multiverse-datasets.R
    ## │   ├── 2-primary-analyses
    ## │   │   ├── 1-confirmatory.R
    ## │   │   ├── 2-exploratory.R
    ## │   │   ├── 3-extract-effects.R
    ## │   │   ├── 4-bootstrap-setup.R
    ## │   │   └── 5-bootstrap-spec-analysis.R
    ## │   └── 3-secondary-analyses
    ## │       ├── set-1
    ## │       │   ├── a1-analysis-ses-vio.R
    ## │       │   ├── a2-extract-effects.R
    ## │       │   ├── b1-analysis-ses-components.R
    ## │       │   └── b2-extract-effects.R
    ## │       └── set-2
    ## │           ├── a1-analysis-adversity-components.R
    ## │           └── a2-extract-effects.R
    ## └── supplement
    ##     ├── scripts
    ##     │   ├── 1-covariates.R
    ##     │   ├── 2-secondary1.R
    ##     │   ├── 3-secondary2.R
    ##     │   ├── 4-tables.R
    ##     │   └── rmd-staging.R
    ##     ├── staged-objects.Rdata
    ##     ├── supplement.Rmd
    ##     └── supplement.pdf

Each of the top-level folders are explained in more detail below:

## Codebooks

These are lists of variable names, labels, and value labels (where
applicable). Their names correspond to the versions of the data they
document (see Data below).

## Data

The raw data for this project contain all variables necessary to produce
all multiverse outputs (cleaned data, multiverse datasets, effect sizes,
plots). The raw data file is the only file that depends on other
files/scripts to create, which saved elsewhere (for confidentiality
reasons).

There are four versions of the data, which can be loaded as `R` objects
or read/used as `.csv` files.

1.  The raw data
2.  The data after all *non-arbitrary* decisions were executed
3.  A version of the previous step with overall composites for the IVs
4.  A version of the data that contains variables for the multiverse
    analysis, only

All versions and codebooks are stored in `data/data2_analysis.Rdata`. In
addition, the following `.csv` files were created to represent each
version of the data separately. The prefixed numbers refer to the step
in the process of going from raw to multiverse-ready data.

-   `1-raw.csv`
-   `2-non_arbitrary.csv`
-   `3-composites.csv`
-   `4-multiverse_base.csv`

A codebook for these data, including variable labels and value labels
(if applicable), can be found in `codebook.csv` at the top level of this
directory.

## Manuscript

This directory contains the manuscript for this project. It was written
in R Markdown and is 100% reproducible. The `.Rmd` fie contains the
written text with all figures, tables, and in-text statistics. All
outputs reported in the manuscript were staged prior to compiling into a
`.pdf` document and stored in a `.Rdata` file called
`staged-objects.Rdata`. The R Markdown document reads these staged files
to make the overall document easier to read. The scripts that produce
the staged objects are located in the `manuscript/scripts/` directory
and are named to be self-explanatory. The `rmd-staging.R` script reads
necessary data/objects from the `multiverse-objects/` directory and
sources the other scripts to produce the objects needed for the
manuscript.

## Multiverse-objects

There are four steps to doing the multiverse:

1.  Specifying a grid of all possible arbitrary data processing
    decisions
2.  Creating a “multiverse” of alternative data sets one could analyze
3.  Analyzing each “universe” within the multiverse
4.  Extracting the relevant information from the analyses (e.g., effect
    sizes, p-values, etc.)
5.  Visualizing results or summarizing them in tables

This folder contains all objects necessary for representing each step.
Specifically:

-   `1-multiverse-datasets`: multiverse data sets with each data
    universe stored in a list. There is one list used for the composites
    and one list used for all components of each IV.
-   `2-primary-analyses`: contain the multiverse of full results and
    extracted effects for the primary confirmatory and exploratory
    results
-   `3-secondary-analyses`: contain the same objects as above for each
    set of secondary analyses.

## Data Processing Scripts

There are four types of R-scripts in this repository, each with a
separate folder.

-   `0-functions/`: Custom R-functions written for this project
-   `1-data-prep/`: Data processing scripts
-   `2-primary-analyses/`: Primary analysis scripts
-   `3-secondary-analyses/`: Secondary analysis scripts

Each script takes an input(s) and produces output(s). The tables below
provides an overview of the inputs and outputs of each script.

### Data Prep

| script                            | input                 | output                                                                                                                                                                                          |
|:----------------------------------|:----------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1-data-non-abritrary.R            | data1\_raw.Rdata      | 1-raw.csv, 2-non\_arbitrary.csv, 3-composites.csv, 4-multiverse\_base.csv, vars1\_raw.csv, vars2\_non\_arbitrary.csv, vars3\_composites.csv, vars4\_multiverse\_base.csv, data2\_analysis.Rdata |
| 2-primary-multiverse-datasets.R   | data2\_analysis.Rdata | datalist-agg-ivs.Rdata                                                                                                                                                                          |
| 3-secondary-multiverse-datasets.R | data2\_analysis.Rdata | datalist-all-ivs.Rdata                                                                                                                                                                          |

### Primary Analyses

| script                      | input                                                     | output                       |
|:----------------------------|:----------------------------------------------------------|:-----------------------------|
| 1-confirmatory.R            | datalist-agg-ivs.Rdata                                    | 1-confirmatory-results.Rdata |
| 2-exploratory.R             | datalist-agg-ivs.Rdata                                    | 2-exploratory-results.Rdata  |
| 3-extract-effects.R         | 1-confirmatory-results.Rdata, 2-exploratory-results.Rdata | 3-extracted-effects.Rdata    |
| 4-bootstrap-setup.R         | datalist-agg-ivs.Rdata, 3-extracted-effects.Rdata         | 4-bootstrapped-data.Rdata    |
| 5-bootstrap-spec-analysis.R | datalist-agg-ivs.Rdata, 4-bootstrapped-data.Rdata         | 5-bootstrapped-effects.Rdata |

### Seconary Analyses

| script                             | input                                                                  | output                                                                 |
|:-----------------------------------|:-----------------------------------------------------------------------|:-----------------------------------------------------------------------|
| a1-analysis-ses-vio.R              | datalist-agg-ivs.Rdata                                                 | a1-results-ses-vio.Rdata                                               |
| a2-extract-effects.R               | a1-results-ses-vio.Rdata                                               | a2-extracted-effects.Rdata                                             |
| b1-analysis-ses-components.R       | datalist-agg-ivs.Rdata                                                 | b1-results-ses-components.Rdata                                        |
| b2-extract-effects.R               | b1-results-ses-components.Rdata                                        | b2-extracted-effects.Rdata                                             |
| a1-analysis-adversity-components.R | datalist-all-ivs.Rdata                                                 | a1-results-expanded-shifting.Rdata, a1-results-expanded-updating.Rdata |
| a2-extract-effects.R               | a1-results-expanded-shifting.Rdata, a1-results-expanded-updating.Rdata | a1-extracted-effects.Rdata                                             |

## Supplement

This directory contains the supplement to the manuscript described
above. The supplement was produced using the same approach as the
manuscript: it was written in R Markdown, is 100% reproducible, and all
outputs were staged prior to compiling into a `.pdf`. The staged objects
are stored in `supplement/staged-objects.Rdata`. The scripts that
produce the staged objects are located in the `supplement/scripts/`
directory and are named to be self-explanatory. The `rmd-staging.R`
script reads necessary data/objects from the `multiverse-objects/`
directory and sources the other scripts to produce the objects needed
for the supplement.
