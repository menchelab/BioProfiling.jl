# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## Unreleased
### Changed
- Normalization for diagnostic images, to support some potential issues with bit depth.

### Added
- MissingFilte
- MembershipFilter

## v1.1.1 - 2022-11-30
### Changed
- Change R repository for increased compatibility
- Update links in documentation

### Added
- Documentation on codespaces
- Tests for TIF-related methods

## v1.1.0 - 2021-09-23
### Added
- Option to remove R seed from distance computation
- `most_variable_features` method
- `characteristic_features` method
- `most_correlated` method
- MissingFilter structures 
- `freqtable` support

## v1.0.1 - 2021-09-23
### Changed
- Correct intermittent error due to singular covariant matrices in helliger distance computation
- Convert columns to float if need for data log-transformation and normalization

### Added
- Continuous integration on MacOS
- Continuous integration on Ubuntu
- Test coverage through Codecov
- Support floats for center coordinates in visual diagnostic methods

## v1.0.0 - 2021-05-01
### Changed
- Rename package to BioProfiling
- Rename several methods and arguments to avoid camel case
- Bug fix in RMPV computation

### Added
- Documentation
- TagBot
- Limit to diagnostic images saved

## v0.4 - 2021-02-26
### Added
- Statistical distances
- Robust morphological perturbation value (RMPV)

## v0.3 - 2020-08-28
### Added
- Image diagnostic functions
- Negation of simple filters
- Methods to apply helper functions on Experiment structures
- UMAP support

## v0.2 - 2020-08-03
### Added
- Filters and Selectors structures and functions

## v0.1 - 2020-02-13
### Added
- Experiment structures and normalization functions

[1.1.0] https://github.com/menchelab/BioProfiling.jl/compare/v1.0.1...HEAD
[1.0.1] https://github.com/menchelab/BioProfiling.jl/compare/v1.0.0...v1.0.1
[1.0.0] https://github.com/menchelab/BioProfiling.jl/compare/v0.4.1...v1.0.0
[0.4] https://github.com/menchelab/BioProfiling.jl/compare/v0.3.4...v0.4.1
[0.3] https://github.com/menchelab/BioProfiling.jl/compare/v0.2.1...v0.3.4
[0.2] https://github.com/menchelab/BioProfiling.jl/compare/v0.1.2...v0.2.1
[0.1] https://github.com/menchelab/BioProfiling.jl/tree/v0.1.2
