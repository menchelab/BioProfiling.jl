# BioProfiling.jl
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](https://github.com/menchelab/RMP.jl/blob/master/LICENSE)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://menchelab.github.io/BioProfiling.jl/dev/)

Robust multidimensional profiling to quantify complex changes via the minimum covariance determinant.
---

## Introduction

This package allows to perform robust multidimensional profiling in 'Julia' and comes with helper functions, especially designed for high-content imaging-based morphological profiling.

## Installation

### Installation from Julia's package repository (easiest option)

You can simply add this package from the Julia repository like for any other package:

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

Use can then import the package:

```julia
	using BioProfiling
```

## Learn more

* Have a look at the [documentation](https://menchelab.github.io/BioProfiling.jl/dev/)
* Run our [example analysis notebooks](https://github.com/menchelab/BioProfilingNotebooks)
* Check out the [JuliaCon 2021 poster](https://drive.google.com/file/d/1sjRONQ8dRJDGAiR-wBhC_rEBKiMIs5Rh/preview) presenting BioProfiling.jl 
* Read our [preprint on BioRxiv](https://www.biorxiv.org/content/10.1101/2021.06.18.448961v1)

## Credits

This package was created by [Loan Vulliard](http://vulliard.loan) @ [Menche lab](https://menchelab.com/).  
This package relies on several amazing open-source Julia packages, listed in the requirement file (see *Project.toml*).  
If you use this tool in your research work, please cite the [preprint](https://www.biorxiv.org/content/10.1101/2021.06.18.448961v1) in which we detail how this tool is implemented and can be used:

    BioProfiling.jl: Profiling biological perturbations with high-content imaging in single cells and heterogeneous populations
    Loan Vulliard, Joel Hancock, Anton Kamnev, Christopher W. Fell, Joana Ferreira da Silva, Joanna Loizou, Vanja Nagy, Loïc Dupré, Jörg Menche
    bioRxiv 2021.06.18.448961; doi: https://doi.org/10.1101/2021.06.18.448961 


