# BioProfiling.jl
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](https://github.com/menchelab/RMP.jl/blob/master/LICENSE)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://menchelab.github.io/BioProfiling.jl/dev/)
[![CI](https://github.com/menchelab/BioProfiling.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/menchelab/BioProfiling.jl/actions/workflows/CI.yml)
[![CI](https://github.com/menchelab/BioProfiling.jl/actions/workflows/NightlyCI.yml/badge.svg)](https://github.com/menchelab/BioProfiling.jl/actions/workflows/NightlyCI.yml)
[![codecov](https://codecov.io/gh/menchelab/BioProfiling.jl/branch/master/graph/badge.svg?token=JE1KSLYYR6)](https://codecov.io/gh/menchelab/BioProfiling.jl)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md) 

A flexible Julia toolkit for high-dimensional cellular profiles
---

## Introduction

This package allows to perform robust multidimensional profiling in 'Julia' and comes with helper functions, especially designed for high-content imaging-based morphological profiling.

## Installation

### Installation from Julia's package repository (easiest option)

You can simply add this package from the Julia repository like any other package:

```julia
import Pkg
Pkg.add("BioProfiling")
using BioProfiling
```

### Local installation

Alternatively, you may use the following to load this package after cloning this repository:

```julia
import Pkg
Pkg.activate(<pathToThisFolder>)
using BioProfiling
Pkg.activate()
```

### Installation from GitHub

Use the following to install the package:

```julia
import Pkg
Pkg.add(Pkg.PackageSpec(url = "https://github.com/menchelab/BioProfiling.jl.git"))
```

You can then import the package normally:

```julia
using BioProfiling
```

## Learn more

* Have a look at the [documentation](https://menchelab.github.io/BioProfiling.jl/dev/)
* Run our [example analysis notebooks](https://github.com/menchelab/BioProfilingNotebooks)
* Check out the [JuliaCon 2021 poster](https://drive.google.com/file/d/1sjRONQ8dRJDGAiR-wBhC_rEBKiMIs5Rh/preview) presenting BioProfiling.jl 
* Read our [preprint on BioRxiv](https://www.biorxiv.org/content/10.1101/2021.06.18.448961v1)

## Contribute

We welcome all sorts of contributions to this project! See our [contribution guidelines](CONTRIBUTING.md) and our [code of conduct](CODE_OF_CONDUCT.md) for more information.

## Credits

This package was created by [Loan Vulliard](http://vulliard.loan) @ [Menche lab](https://menchelab.com/).  
BioProfiling.jl relies on several amazing open-source Julia packages, listed in the requirement file (see [*Project.toml*](Project.toml)).  
If you use this tool in your research work, please cite the [preprint](https://www.biorxiv.org/content/10.1101/2021.06.18.448961v1) in which we detail how this tool is implemented and can be used:

    BioProfiling.jl: Profiling biological perturbations with high-content imaging in single cells and heterogeneous populations
    Loan Vulliard, Joel Hancock, Anton Kamnev, Christopher W. Fell, Joana Ferreira da Silva, Joanna Loizou, Vanja Nagy, Loïc Dupré, Jörg Menche
    bioRxiv 2021.06.18.448961; doi: https://doi.org/10.1101/2021.06.18.448961 

We also thank the reviewers of this manuscript whose suggestions contributed to improve the [example analyses](https://github.com/menchelab/BioProfilingNotebooks), their biological interpretation as well as the package in itself.