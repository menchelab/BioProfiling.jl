# BioProfiling.jl examples

This section aim to describe how to develop and test the BioProfiling.jl package using a virtual machine hosted by GitHub and VS directly in your browser thanks to GitHub codespaces.  
Please note that no paid account is typically needed, although you might have limited access to codespaces depending on which type of GitHub account you have (see [Pricing information](https://docs.github.com/en/billing/managing-billing-for-github-codespaces/about-billing-for-github-codespaces)). 

## Starting a codespace and setting up the environment

Go to the [repository](https://github.com/menchelab/BioProfiling.jl), on the branch you would like to edit. Click on "Code <>" > "Codespaces" > "+". This will open VS, where you can edit the files, run code, and contribute to the repository using all usual GitHub features.  
First, you will need to start a Docker container to be able to run Julia code. In the terminal, run `docker run -it -v `pwd`:/home/jovyan jupyter/datascience-notebook:latest julia`. The environment should include both R and Julia, although you might want to use [another image](https://hub.docker.com/r/jupyter/datascience-notebook/tags) if you want a version in particular.

## Setting up Julia for package development

The terminal should display a Julia session. Now, set up the package as follows:
```julia
import Pkg
Pkg.activate(".") # Set up requirements for environment
Pkg.status() # This should display the dependencies of the package

Pkg.instantiate() # Actually prepare all packages
# You can now modify what you and test your new features!

# In the end, do not forget to test your code to make sure you did not break anything
Pkg.test() 
```

## Opening a pull request

Once you are satisfied with your changes and made sure that are not breaking existing features, go to the "Source Control" tab to commit your changes. Typically you will want to create a pull request with your code. Please follow the [contribution guidelines](https://github.com/menchelab/BioProfiling.jl/blob/master/CONTRIBUTING.md) and [code of conduct](https://github.com/menchelab/BioProfiling.jl/blob/master/CODE_OF_CONDUCT.md). Thanks for taking the time to contribute to BioProfiling.jl!