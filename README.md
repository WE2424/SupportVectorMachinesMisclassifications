# Support Vector Machines: Proposals For Dealing With Misclassifications

A thesis written for the degree of
Bachelor in Econometrics and Operations Research at
Tilburg University. It investigates the performance of a [support vector machine](https://en.wikipedia.org/wiki/Support_vector_machine) (SVM) on the [binary classification problem](https://en.wikipedia.org/wiki/Binary_classification) when misclassifications are present. 8 new SVMs are proposed and compared to 3 existing models. An in depth discussion is given [here](doc/thesis.pdf).

- [Features](#features)
  - [Data generation](#data-generation)
  - [11 different SVMs](#11-different-svms)
  - [Evaluation](#evaluation)
- [Requirements](#requirements)
  - [MATLAB](#matlab)
  - [Gurobi](#gurobi)
- [Getting Started](#getting-started)
- [License](#license)

## Features

### Data generation
Data is simulated by two methods. The [first](src/data/GetDataByMeasurements.m) gives more control in measurements, such as overlap and outliers, while the [second](src/data/GetDataByDistributions.m) can use any distribution to draw data.

### 11 different SVMs
SVMs with the following cost functions are implemented:
- [L1 (LASSO)](src/models/SvmL1.m)
- [L2 (Ridge)](src/models/SvmL2.m)
- L0
  - [with binary variable](src/models/SvmL0a.m)
  - [without binary variable](src/models/SvmL0b.m)
- [Capped L1](src/models/SvmCappedL1.m)
- [L2L1 (Elastic Net)](src/models/SvmL2L1.m)
- [L2L0](src/models/SvmL2L0.m)
- [L1L0](src/models/SvmL1L0.m)
- [SCAD](src/models/SvmScad.m)
- [Elastic SCAD](src/models/SvmElasticScad.m)
  
In addition, a [method](src/models/SvmBootstrap.m) based on bootstrapping using the L1 SVM is used. 

### Evaluation
The models are evaluated on runtime and score for 2370 datasets with different properties. The method based on bootstrapping is found to work best when noise and outliers are present. The capped L1 SVM performs better when outliers are too large.

## Requirements

### MATLAB
MATLAB version 9.14+ is required.

Statistics and Machine Learning Toolbox

### Gurobi
The solution uses the solver from [Gurobi](https://www.gurobi.com), which is not freely available. At the top of `main.m`, the location of the solver needs to be added.
Examples:
```m
addpath('C:\gurobi1001\win64\matlab')
```
```m
addpath('/Library/gurobi1100/macos_universal2/matlab')
```

## Getting Started
1. Clone the repository

```bash
git clone https://github.com/WE2424/SupportVectorMachinesMisclassifications.git
cd SupportVectorMachinesMisclassifications
```
2. Configure the location of the Gurobi solver

3. Open the MATLAB application and run `main.m`.


## License
[MIT License](LICENSE.md)