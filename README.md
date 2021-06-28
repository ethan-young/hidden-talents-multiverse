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

<div id="one" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#one .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#one .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#one .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#one .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 4px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#one .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#one .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#one .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#one .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#one .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#one .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#one .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#one .gt_group_heading {
  padding: 8px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#one .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#one .gt_from_md > :first-child {
  margin-top: 0;
}

#one .gt_from_md > :last-child {
  margin-bottom: 0;
}

#one .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#one .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 12px;
}

#one .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#one .gt_first_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
}

#one .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#one .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#one .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#one .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#one .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#one .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding: 4px;
}

#one .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#one .gt_sourcenote {
  font-size: 90%;
  padding: 4px;
}

#one .gt_left {
  text-align: left;
}

#one .gt_center {
  text-align: center;
}

#one .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#one .gt_font_normal {
  font-weight: normal;
}

#one .gt_font_bold {
  font-weight: bold;
}

#one .gt_font_italic {
  font-style: italic;
}

#one .gt_super {
  font-size: 65%;
}

#one .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 65%;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">script</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">input</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">output</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td class="gt_row gt_left"><div class='gt_from_md'><p>1-data-non-abritrary.R</p>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>data1_raw.Rdata</li>
</ul>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>1-raw.csv</li>
<li>2-non_arbitrary.csv</li>
<li>3-composites.csv</li>
<li>4-multiverse_base.csv</li>
<li>vars1_raw.csv</li>
<li>vars2_non_arbitrary.csv</li>
<li>vars3_composites.csv</li>
<li>vars4_multiverse_base.csv</li>
<li>data2_analysis.Rdata</li>
</ul>
</div></td></tr>
    <tr><td class="gt_row gt_left"><div class='gt_from_md'><p>2-primary-multiverse-datasets.R</p>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>data2_analysis.Rdata</li>
</ul>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>datalist-agg-ivs.Rdata</li>
</ul>
</div></td></tr>
    <tr><td class="gt_row gt_left"><div class='gt_from_md'><p>3-secondary-multiverse-datasets.R</p>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>data2_analysis.Rdata</li>
</ul>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>datalist-all-ivs.Rdata</li>
</ul>
</div></td></tr>
  </tbody>
  
  
</table>
</div>

### Primary Analyses

<div id="one" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#one .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#one .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#one .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#one .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 4px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#one .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#one .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#one .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#one .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#one .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#one .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#one .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#one .gt_group_heading {
  padding: 8px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#one .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#one .gt_from_md > :first-child {
  margin-top: 0;
}

#one .gt_from_md > :last-child {
  margin-bottom: 0;
}

#one .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#one .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 12px;
}

#one .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#one .gt_first_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
}

#one .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#one .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#one .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#one .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#one .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#one .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding: 4px;
}

#one .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#one .gt_sourcenote {
  font-size: 90%;
  padding: 4px;
}

#one .gt_left {
  text-align: left;
}

#one .gt_center {
  text-align: center;
}

#one .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#one .gt_font_normal {
  font-weight: normal;
}

#one .gt_font_bold {
  font-weight: bold;
}

#one .gt_font_italic {
  font-style: italic;
}

#one .gt_super {
  font-size: 65%;
}

#one .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 65%;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">script</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">input</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">output</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td class="gt_row gt_left"><div class='gt_from_md'><p>1-confirmatory.R</p>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>datalist-agg-ivs.Rdata</li>
</ul>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>1-confirmatory-results.Rdata</li>
</ul>
</div></td></tr>
    <tr><td class="gt_row gt_left"><div class='gt_from_md'><p>2-exploratory.R</p>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>datalist-agg-ivs.Rdata</li>
</ul>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>2-exploratory-results.Rdata</li>
</ul>
</div></td></tr>
    <tr><td class="gt_row gt_left"><div class='gt_from_md'><p>3-extract-effects.R</p>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>1-confirmatory-results.Rdata</li>
<li>2-exploratory-results.Rdata</li>
</ul>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>3-extracted-effects.Rdata</li>
</ul>
</div></td></tr>
    <tr><td class="gt_row gt_left"><div class='gt_from_md'><p>4-bootstrap-setup.R</p>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>datalist-agg-ivs.Rdata</li>
<li>3-extracted-effects.Rdata</li>
</ul>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>4-bootstrapped-data.Rdata</li>
</ul>
</div></td></tr>
    <tr><td class="gt_row gt_left"><div class='gt_from_md'><p>5-bootstrap-spec-analysis.R</p>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>datalist-agg-ivs.Rdata</li>
<li>4-bootstrapped-data.Rdata</li>
</ul>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>5-bootstrapped-effects.Rdata</li>
</ul>
</div></td></tr>
  </tbody>
  
  
</table>
</div>

### Seconary Analyses

<div id="one" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#one .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#one .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#one .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#one .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 4px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#one .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#one .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#one .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#one .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#one .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#one .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#one .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#one .gt_group_heading {
  padding: 8px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
}

#one .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#one .gt_from_md > :first-child {
  margin-top: 0;
}

#one .gt_from_md > :last-child {
  margin-bottom: 0;
}

#one .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#one .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 12px;
}

#one .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#one .gt_first_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
}

#one .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#one .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#one .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#one .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#one .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#one .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding: 4px;
}

#one .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#one .gt_sourcenote {
  font-size: 90%;
  padding: 4px;
}

#one .gt_left {
  text-align: left;
}

#one .gt_center {
  text-align: center;
}

#one .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#one .gt_font_normal {
  font-weight: normal;
}

#one .gt_font_bold {
  font-weight: bold;
}

#one .gt_font_italic {
  font-style: italic;
}

#one .gt_super {
  font-size: 65%;
}

#one .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 65%;
}
</style>
<table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">script</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">input</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">output</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td class="gt_row gt_left"><div class='gt_from_md'><p>a1-analysis-ses-vio.R</p>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>datalist-agg-ivs.Rdata</li>
</ul>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>a1-results-ses-vio.Rdata</li>
</ul>
</div></td></tr>
    <tr><td class="gt_row gt_left"><div class='gt_from_md'><p>a2-extract-effects.R</p>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>a1-results-ses-vio.Rdata</li>
</ul>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>a2-extracted-effects.Rdata</li>
</ul>
</div></td></tr>
    <tr><td class="gt_row gt_left"><div class='gt_from_md'><p>b1-analysis-ses-components.R</p>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>datalist-agg-ivs.Rdata</li>
</ul>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>b1-results-ses-components.Rdata</li>
</ul>
</div></td></tr>
    <tr><td class="gt_row gt_left"><div class='gt_from_md'><p>b2-extract-effects.R</p>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>b1-results-ses-components.Rdata</li>
</ul>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>b2-extracted-effects.Rdata</li>
</ul>
</div></td></tr>
    <tr><td class="gt_row gt_left"><div class='gt_from_md'><p>a1-analysis-adversity-components.R</p>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>datalist-all-ivs.Rdata</li>
</ul>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>a1-results-expanded-shifting.Rdata</li>
<li>a1-results-expanded-updating.Rdata</li>
</ul>
</div></td></tr>
    <tr><td class="gt_row gt_left"><div class='gt_from_md'><p>a2-extract-effects.R</p>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>a1-results-expanded-shifting.Rdata</li>
<li>a1-results-expanded-updating.Rdata</li>
</ul>
</div></td>
<td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>a1-extracted-effects.Rdata</li>
</ul>
</div></td></tr>
  </tbody>
  
  
</table>
</div>

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
