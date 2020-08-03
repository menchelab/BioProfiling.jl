module RMP
export  logtransform, 
        normtransform, 
        decorrelate, 
        mahalanobis, 
        hellinger, 
        Filter, 
        CombinationFilter, 
        Experiment, 
        filterEntriesExperiment!, 
        filterEntriesExperiment,
        Selector,
        CombinationSelector,
        selectFeaturesExperiment,
        selectFeaturesExperiment!
using Statistics, StatsBase, DataFrames
using LinearAlgebra: det

include("transform.jl")
include("distances.jl")
include("struct.jl")

end # module