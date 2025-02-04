# 24h-recall-outlier-exploration

**Background**

Dietary data are characterized by high dimensionality and the presence of outliers. Short-term diet collection tools like 24-hour dietary recalls are sensitive to daily variations and require multiple recalls, creating temporal dependencies. The presence and removal of outliers in repeated diet recall data has not been evaluated yet, and there are no automated tools to facilitate studies with diet data.

**Objective**

To establish an automated, systematic software pipeline for detecting, exploring, and evaluating outliers in 24-hour recall data, addressing both cross-sectional and longitudinal contexts.

**Methods**

We utilized 251 repeated recalls from 126 children aged 8-12 years from the gut MIcrobiota, GROWth and Diet (MiGrowD) study and 15,216 repeated recalls from the 2015 Canadian Community Health Survey (CCHS). The pipeline consisted of three components: outlier detection, outlier exploration, and outlier evaluation.

**Outlier Detection**

For outlier detection, we digitized the National Cancer Institute recommendations and compared values against population data from the Canadian Community Health Survey (2015), specified for sex and age groups.

**Outlier Exploration**
The pipeline features a decision tree-based exploration of dietary patterns contributing to outliers.

**Outlier Evaluation**

The pipeline detected 75 outliers across seven nutrients, with counts varying by nutrient
Age-specific reference values highlighted significant differences between groups. The longitudinal method outperformed the static method, achieving over 77% sensitivity, 97% specificity, and 88% precision. Rule extraction identified dietary patterns linked to outliers, such as low consumption of red/orange vegetables, fruits, milk, and potatoes, and high consumption of poultry and eggs.

**Results**

This study presents the first automated method for detecting longitudinal outliers in dietary data. The pipeline's evaluation across multiple datasets demonstrated improved sensitivity and specificity, enhancing replicability and efficiency. The integration of comprehensive reference values for different sexes and age groups supports more precise dietary data analysis, paving the way for advanced nutritional research and interventions.

**Keywords**

data-driven, outlier detection, 24-h dietary recall, longitudinal data, child and adult nutrition

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
