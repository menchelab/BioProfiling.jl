module BioProfiling
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
        filter_entries!, 
        filter_entries,
        Selector,
        NameSelector,
        CombinationSelector,
        select_features,
        select_features!,
        select!,
        filter!,
        diagnostic,
        diagnostic_path,
        diagnostic_images,
        negation,
        getdata, 
        shuffled_distance_robust_mahalanobis_median,
        distance_robust_mahalanobis_median,
        shuffled_distance_robust_hellinger,
        distance_robust_hellinger,
        shuffled_distance_mahalanobis_center,
        distance_mahalanobis_center,
        shuffled_distance_mahalanobis_median,
        distance_mahalanobis_median,
        robust_morphological_perturbation_value,
        umap
using Statistics, StatsBase, DataFrames, Images, ImageMagick, UMAP, RCall, MultipleTesting
using Distributed, ParallelDataTransfer

using LinearAlgebra: det

include("struct.jl")
include("transform.jl")
include("distances.jl")
include("diagnostic.jl")
include("visu.jl")
include("rmpv.jl")

end # module
