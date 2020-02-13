# RMP.jl
Robust multidimensional profiling to quantify complex changes via the minimum covariance determinant.
---

## Disclaimer

This package is under active development and is not intended for external use yet. Test at your own risk.

## Introduction

This package allows to perform robust multidimensional profiling in 'Julia' and comes with helper functions, especially designed for high-content imaging-based morphological profiling.

## Installation

### Local installation

Use the following to load this package:

	import Pkg
	Pkg.activate(<pathToThisFolder>)
	using RMP
	Pkg.activate()

### Installation from GitHub

Use the following to install the package:

	import Pkg
	Pkg.add("https://github.com/menchelab/RMP.jl")

Use can then use the package:

	using RMP

## Credits

This package was created by [Loan Vulliard](http://vulliard.loan) @ [Menche lab](https://menchelab.com/).  
This package relies on many other open-source Julia packages, listed in the requirement file (see *Project.toml*).

