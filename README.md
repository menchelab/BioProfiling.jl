# BioProfiling.jl
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](https://github.com/menchelab/RMP.jl/blob/master/LICENSE)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://menchelab.github.io/BioProfiling.jl/dev/)

Robust multidimensional profiling to quantify complex changes via the minimum covariance determinant.
---

## Introduction

This package allows to perform robust multidimensional profiling in 'Julia' and comes with helper functions, especially designed for high-content imaging-based morphological profiling.

## Installation

### Local installation

Use the following to load this package:

	import Pkg
	Pkg.activate(<pathToThisFolder>)
	using BioProfiling
	Pkg.activate()

### Installation from GitHub

Use the following to install the package:

	import Pkg
	Pkg.add(Pkg.PackageSpec(url = "https://github.com/menchelab/BioProfiling.jl.git"))

Use can then use the package:

	using BioProfiling

## Credits

This package was created by [Loan Vulliard](http://vulliard.loan) @ [Menche lab](https://menchelab.com/).  
This package relies on many other open-source Julia packages, listed in the requirement file (see *Project.toml*).

