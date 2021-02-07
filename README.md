Hidden Talents Multiverse Analysis
================

<style>
table{
  font-size: 14px;
}
td{
  vertical-align: top;
}
.gt_row{
  vertical-align: top;
}
</style>

This repository contains all data, code, and output for a working
manuscript by Young, Frankenhuis, and Ellis (in progress).

## Directory Structure

The names of each folder are intended to be self-explanatory. There are
five top-level folders to organize the inputs and outputs of this
project:

1.  `codebooks/`: lists of variable names, labels, and value labels
    (where applicable).
2.  `data/`: data, stored as an `.Rdata` file and `.csv` files.
3.  `figures/`: all figures that are produced by R-scripts
4.  `multiverse-objects/`: all `.Rdata` files containing objects
    necessary for performing multiverse analyses and storing
    intermediary results

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
    ## ├── figures
    ## │   ├── primary
    ## │   │   ├── interactions.pdf
    ## │   │   ├── spec-curve-shifting.pdf
    ## │   │   └── spec-curve-updating.pdf
    ## │   └── secondary
    ## │       ├── set-1
    ## │       │   ├── a1-interactions.pdf
    ## │       │   ├── a1-spec-curve-updating.pdf
    ## │       │   ├── b1-interactions.pdf
    ## │       │   └── b1-spec-curve-updating.pdf
    ## │       └── set-2
    ## │           ├── a1-ses-interactions.pdf
    ## │           ├── a1-ses-shifting.pdf
    ## │           ├── a1-ses-updating.pdf
    ## │           ├── a1-unp-interactions.pdf
    ## │           ├── a1-unp-shifting.pdf
    ## │           ├── a1-unp-updating.pdf
    ## │           ├── a1-vio-interactions.pdf
    ## │           ├── a1-vio-shifting.pdf
    ## │           └── a1-vio-updating.pdf
    ## ├── multiverse-objects
    ## │   ├── 1-multiverse-datasets
    ## │   │   ├── datalist-agg-ivs.Rdata
    ## │   │   └── datalist-all-ivs.Rdata
    ## │   ├── 2-primary-analyses
    ## │   │   ├── 1-confirmatory-results.Rdata
    ## │   │   ├── 2-exploratory-results.Rdata
    ## │   │   ├── 3-extracted-effects.Rdata
    ## │   │   ├── 4-bootstrapped-data.Rdata
    ## │   │   └── 5-bootstrapped-effects.Rdata
    ## │   └── 3-secondary-analyses
    ## │       ├── set-1
    ## │       │   ├── a1-results-ses-vio.Rdata
    ## │       │   ├── a2-extracted-effects.Rdata
    ## │       │   ├── b1-results-ses-components.Rdata
    ## │       │   └── b2-extracted-effects.Rdata
    ## │       └── set-2
    ## │           ├── a1-extracted-effects.Rdata
    ## │           ├── a1-results-expanded-shifting.Rdata
    ## │           └── a1-results-expanded-updating.Rdata
    ## └── scripts
    ##     ├── 0-functions
    ##     │   └── create_codebook.R
    ##     ├── 1-data-prep
    ##     │   ├── 1-data-non-abritrary.R
    ##     │   ├── 2-primary-multiverse-datasets.R
    ##     │   └── 3-secondary-multiverse-datasets.R
    ##     ├── 2-primary-analyses
    ##     │   ├── 1-confirmatory.R
    ##     │   ├── 2-exploratory.R
    ##     │   ├── 3-extract-effects.R
    ##     │   ├── 4-bootstrap-setup.R
    ##     │   ├── 5-bootstrap-spec-analysis.R
    ##     │   └── 6-create-plots.R
    ##     └── 3-secondary-analyses
    ##         ├── set-1
    ##         │   ├── a1-analysis-ses-vio.R
    ##         │   ├── a2-extract-effects.R
    ##         │   ├── a3-create-plots.R
    ##         │   ├── b1-analysis-ses-components.R
    ##         │   ├── b2-extract-effects.R
    ##         │   └── b3-create-plots.R
    ##         └── set-2
    ##             ├── a1-analysis-adversity-components.R
    ##             ├── a2-extract-effects.R
    ##             └── a3-create-plots.R

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

## Figures

These are all figures that are produced by R-scripts. They are divided
into the following categories:

-   Primary analysis figures
-   Secondary analysis figures
    -   Set 1
    -   Set 2

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

-   `0-functions/`: custom R-functions written for this project
-   `1-data-prep/`: Data processing scripts
-   `2-primary-analyses/`: Primary analysis scripts
-   `3-secondary-analyses/`: Secondary analysis scripts

Each script takes an input(s) and produces output(s). The table below
provides an overview of the inputs and outputs of each script.

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
  font-weight: bold;
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
  font-weight: bold;
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
  font-size: 65%;
}

#one .gt_row {
  vertical-align: top;
}
</style>
<div id="one" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;"><table class="gt_table">
  
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">script</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">input</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">output</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr class="gt_group_heading_row">
      <td colspan="3" class="gt_group_heading">functions</td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>create_codebook.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'></div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'></div></td>
    </tr>
    <tr class="gt_group_heading_row">
      <td colspan="3" class="gt_group_heading">data-prep</td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>1-data-non-abritrary.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>data1_raw.Rdata</p>
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
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>2-primary-multiverse-datasets.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>data2_analysis.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>datalist-agg-ivs.Rdata</li>
</ul>
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>3-secondary-multiverse-datasets.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>data2_analysis.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>datalist-all-ivs.Rdata</li>
</ul>
</div></td>
    </tr>
    <tr class="gt_group_heading_row">
      <td colspan="3" class="gt_group_heading">primary-analyses</td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>1-confirmatory.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>datalist-agg-ivs.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>1-confirmatory-results.Rdata</li>
</ul>
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>2-exploratory.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>datalist-agg-ivs.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>2-exploratory-results.Rdata</li>
</ul>
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>3-extract-effects.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>1-confirmatory-results.Rdata<br>2-exploratory-results.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>3-extracted-effects.Rdata</li>
</ul>
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>4-bootstrap-setup.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>datalist-agg-ivs.Rdata<br>3-extracted-effects.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>4-bootstrapped-data.Rdata</li>
</ul>
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>5-bootstrap-spec-analysis.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>datalist-agg-ivs.Rdata<br>4-bootstrapped-data.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>5-bootstrapped-effects.Rdata</li>
</ul>
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>6-create-plots.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>3-extracted-effects.Rdata<br>5-bootstrapped-effects.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>spec-curve-shifting.pdf</li>
<li>spec-curve-updating.pdf</li>
<li>interactions.pdf</li>
</ul>
</div></td>
    </tr>
    <tr class="gt_group_heading_row">
      <td colspan="3" class="gt_group_heading">secondary-analyses</td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>a1-analysis-ses-vio.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>datalist-agg-ivs.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>a1-results-ses-vio.Rdata</li>
</ul>
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>a2-extract-effects.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>a1-results-ses-vio.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>a2-extracted-effects.Rdata</li>
</ul>
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>a3-create-plots.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>a2-extracted-effects.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>a1-spec-curve-updating.pdf</li>
<li>a1-interactions.pdf</li>
</ul>
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>b1-analysis-ses-components.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>datalist-agg-ivs.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>b1-results-ses-components.Rdata</li>
</ul>
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>b2-extract-effects.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>b1-results-ses-components.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>b2-extracted-effects.Rdata</li>
</ul>
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>b3-create-plots.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>b2-extracted-effects.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>b1-spec-curve-updating.pdf</li>
<li>b1-interactions.pdf</li>
</ul>
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>a1-analysis-adversity-components.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>datalist-all-ivs.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>a1-results-expanded-shifting.Rdata</li>
<li>a1-results-expanded-updating.Rdata</li>
</ul>
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>a2-extract-effects.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>a1-results-expanded-shifting.Rdata<br>a1-results-expanded-updating.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>a1-extracted-effects.Rdata</li>
</ul>
</div></td>
    </tr>
    <tr>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>a3-create-plots.R</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><p>a1-extracted-effects.Rdata</p>
</div></td>
      <td class="gt_row gt_left"><div class='gt_from_md'><ul>
<li>a1-unp-shifting.pdf</li>
<li>a1-unp-updating.pdf</li>
<li>a1-unp-interactions.pdf</li>
<li>a1-vio-shifting.pdf</li>
<li>a1-vio-updating.pdf</li>
<li>a1-vio-interactions.pdf</li>
<li>a1-ses-shifting.pdf</li>
<li>a1-ses-updating.pdf</li>
<li>a1-ses-interactions.pdf</li>
</ul>
</div></td>
    </tr>
  </tbody>
  
  
</table></div>
