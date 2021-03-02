# RMP.jl examples

## Introduction 

This package provides multidimensional profiling tools to quantify complex biological changes via robust statistical distances. It is particularly suitable for morphological profiling on high-content imaging data. 

## Getting started

### Generate an example dataset 

The package requires data describing your experiment in a tabular format. Here we simulate such a dataset with 100 profiles, composed of five columns with numerical features (e.g. morphological measurements) and one metadata column (e.g. experimental condition).

```julia
using RMP, DataFrames, Random, StatsBase

d = DataFrame(rand(100,5))
d.Condition = sample('A':'D', 100);

# Make one condition stand out
d[d.Condition .== 'D',1:5] .+= 1;
```

### Create and filter your `Experiment`

```julia
# Create Experiment object from DataFrame
e = Experiment(d, description = "Small simulated experiment")

# Exclude metadata from the downstream computations
slt = NameSelector(x -> x != "Condition")

# Apply your NameSelector to the Experiment
selectFeaturesExperiment!(e, slt);
```

### Compute statistical significance of changes to a reference

```julia
# This filter defines our reference condition (when :Condition is equal to 'C')
f = Filter('C', :Condition)

# Compute the significance of changes compared to the reference
rmpv = robust_morphological_perturbation_value(e, :Condition, f)
```

Note from the statistical distance that 'C' is identical to itself, while the condition 'D' is the most different, as all values for the profiles of condition 'D' where incremented when we constructed the dataset.


## Vignette

You can find a full example use case of the package in a series of notebooks collected in a dedicated repository: [BioProfilingNotebooks](https://github.com/menchelab/BioProfilingNotebooks).