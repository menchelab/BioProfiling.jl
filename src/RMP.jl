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
        NameSelector,
        CombinationSelector,
        selectFeaturesExperiment,
        selectFeaturesExperiment!,
        selectExperiment!,
        filterExperiment!,
        diagnostic,
        diagnosticURLImage,
        diagnosticImages,
        getColorImage
using Statistics, StatsBase, DataFrames, Images, ImageMagick
using LinearAlgebra: det

include("transform.jl")
include("distances.jl")
include("struct.jl")
include("diagnostic.jl")

end # module