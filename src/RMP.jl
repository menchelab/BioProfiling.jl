module RMP
export  logtransform,
        logtransform!,
        normtransform, 
        normtransform!, 
        decorrelate, 
        decorrelate!, 
        decorrelate_by_mad!,
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
        negation,
        getdata, 
        umap
using Statistics, StatsBase, DataFrames, Images, ImageMagick, UMAP
using LinearAlgebra: det

include("struct.jl")
include("transform.jl")
include("distances.jl")
include("diagnostic.jl")
include("visu.jl")

end # module