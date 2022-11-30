# How to contribute to BioProfiling.jl

We gladly welcome all contributions to BioProfiling.jl!  
This document presents the most constructive and ways to participate in this project.

## Code of Conduct

Please follow our [code of conduct](CODE_OF_CONDUCT.md) when participating or contributing to this repository.

## Use of the Issues tab

The project uses the [repository's issues](https://github.com/menchelab/BioProfiling.jl/issues) to track bugs and ideas for novel features and improvements. Feel free to participate, whether or not you have the time and expertise to **come up with a solution yourself**! Please do your best to make your issue clear, reproducible, and unique. In particular, do not forget the issue archive as it may have been addressed already.  
This is also the perfect place to discuss your contribution ideas with the community before starting implementing them. This can save you and others time, by making sure the changes are relevant for the community and will be compatible with the rest of the codebase.  
The most pressing issues are listed in the [Projects tab](https://github.com/menchelab/BioProfiling.jl/projects) so that they are adressed in the next release. Some issues might also be tagged as "good first issues" if they are expected to be relatively straightforward to implement and do not require an advanced understanding of the project's source code.  
Finally, **if you are seeking help** on how to use BioProfiling.jl and did not find an answer in [the documentation](https://menchelab.github.io/BioProfiling.jl/dev/) or in [the example notebooks](https://github.com/menchelab/BioProfilingNotebooks), you are also welcome to create a new issue to ask your question!

## Code contributions

For all code contributions, please [create a pull request](https://github.com/menchelab/BioProfiling.jl/pulls), either to the main branch for bug fixes and performance improvements or to a development branch, according to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).  
To do so, **fork the project, create and checkout a branch, add and commit your changes, test your code locally, push your new branch and open a pull request**. Other contributors and maintainers will be able to review your changes and may ask you to make additional modifications so that your contribution fits nicely in the project, and eventually merge your code to the master or development branches. Thanks for even considering going through this process!  
To ensure the code is functional and stays compatible with new versions of its dependencies, a [battery of tests](test/runtests.jl) is implemented. For all new features, such tests need to be added in the `test` folder before the PR can be merged. These tests will be automatically run via GitHub Actions when creating a pull request to the master branch. You can also test them locally as follows:

```julia
import Pkg
Pkg.activate("./")
Pkg.resolve()
Pkg.test()
```

All tests should pass for the supported versions of Julia and the package's dependencies.


## Development environment

BioProfiling.jl is intended to be compatible with a large set of environments as detailed in [Project.toml](Project.toml). If you need to setup a development environment, an easy solution is to **edit and run code directly in your browser thanks to GitHub codespaces**. Some instructions are available in [our documentation](https://menchelab.github.io/BioProfiling.jl/dev/).  
Another option is to start from the [latest **Docker image** designed to run the example notebooks](https://hub.docker.com/r/koalive/bioprofilingnotebooks), which comes with all dependencies installed. To avoid inteferences between the pre-installed version of BioProfiling.jl and your local version of the source code, you can remove the version installed in the container with the following lines:

```julia
import Pkg
Pkg.rm("BioProfiling")
```

As mentioned in the [Code contributions section](#code-contributions), you can test your changes locally but you do not need to worry about breaking features as we use continuous integration to validate changes to the master branch.

## Contributors acknowledgment

We really appreciate all contributions which make BioProfiling.jl more useful for the community! The package is [open source, provided for free and under the MIT license](LICENSE) and we offer our profound gratitude to the contributors, who will also be acknowledged in [the Credits section on the project's README](README.md#credits).