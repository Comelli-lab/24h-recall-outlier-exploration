# 24h-recall-outlier-exploration

**Background**

Twenty-four-hour dietary recalls are widely used to assess dietary intake but generally necessitate multiple administrations. Longitudinal collection introduces temporal dependencies and complicates data cleaning. Existing approaches are static, largely manual, and use USA- and adult-relevant thresholds, limiting their applicability across ages and populations.

**Objective**

To establish an all-in-one, automated, systematic software pipeline for detecting, exploring, and evaluating outliers in 24-hour recall data for both cross-sectional and longitudinal contexts.

**Methods**

We utilized 251 repeated recalls from 126 children aged 8-12 years from the Microbiota, GROWth and Diet study and 15,216 repeated recalls from children and adults in the 2015 Canadian Community Health Survey (CCHS). The pipeline was codified and had three components for outlier detection, exploration, and evaluation. For outlier detection, we digitized the National Cancer Institute (NCI) recommendations and compared values against population data from the CCHS (sex and age specific). Exploration of dietary patterns contributing to outliers was via a decision tree.

**Results**

The pipeline detected 75 outliers across seven nutrients, with varying counts (energy intake, 17; carbohydrates, 24; fiber, 18; sugars, 24; total fats, 20; proteins, 24; sodium, 16; vitamin C, 10). Age-specific reference values highlighted significant differences between groups. The longitudinal method outperformed the static method, achieving over 77% sensitivity, 97% specificity, and 88% precision. Rule extraction identified dietary patterns linked to outliers (low consumption of red/orange vegetables, fruits, milk, and potatoes, and high consumption of poultry and eggs).

**Conclusions**

This is the first automated pipeline detecting outliers in longitudinal dietary data and clarifying the basis for their identification. Findings, validated across two datasets, underscore the longitudinal method's superior ability to identify true outliers while minimizing false positives in both children and adults. This universally applicable, scalable method improves dietary data analysis efficiency and reproducibility, enhancing its quality and advancing nutritional research and public health outcomes.


**Keywords**

data-driven outlier detection, 24-h dietary recall, longitudinal data, child and adult nutrition


**Outlier Detection**

For outlier detection, we digitized the National Cancer Institute recommendations and compared values against population data from the Canadian Community Health Survey (2015), specified for sex and age groups.

**Outlier Exploration**
The pipeline features a decision tree-based exploration of dietary patterns contributing to outliers.

**Outlier Evaluation**

The pipeline detected 75 outliers across seven nutrients, with counts varying by nutrient
Age-specific reference values highlighted significant differences between groups. The longitudinal method outperformed the static method, achieving over 77% sensitivity, 97% specificity, and 88% precision. Rule extraction identified dietary patterns linked to outliers, such as low consumption of red/orange vegetables, fruits, milk, and potatoes, and high consumption of poultry and eggs.


**Installation**

To install and run the pipeline, follow these steps:

Clone the repository:
```
git clone https://github.com/Comelli-lab/24h-recall-outlier-exploration.git```

Navigate to the project directory:
```
cd 24h-recall-outlier-exploration``

Install the required dependencies:

```
Rscript install_packages.R
```
Run code:
```
Rscript cleaning_functions.R
Rscript 1.cchs_data_analysis.R
Rscript 2.NCI_literature_digitize.R

```

**Usage**

Detailed usage instructions and examples can be found in the docs directory of this repository.

**Contributing**

We welcome contributions from the community. Please refer to the CONTRIBUTING.md file for guidelines on how to contribute.

**License**

This project is licensed under the MIT License. See the LICENSE file for more details.

**Acknowledgements**

We would like to thank the participants of the MiGrowD study and the Canadian Community Health Survey for providing the data used in this research.
