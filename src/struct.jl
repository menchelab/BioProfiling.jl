# This is used to store experiment details
abstract type AbstractExperiment end

mutable struct Experiment <: AbstractExperiment
    data::DataFrame
    description::String
    selectedFeatures::Array{Int64,1}
    selectedEntries::Array{Int64,1}
end

# Constructor
function Experiment(data; description = "No description provided")
    return Experiment(data, description, 1:ncol(data), 1:nrow(data))
end

function Base.show(io::IO, e::Experiment)
    compact = get(io, :compact, false)

    if compact
        show(io, "Exp.: "*string(length(e.selectedEntries))*"/"*string(nrow(e.data))*
             "-"*string(length(e.selectedFeatures))*"/"*string(ncol(e.data)))
    else
        show(io, "Experiment with "*string(length(e.selectedEntries))*"/"*string(nrow(e.data))*
             " entries and "*string(length(e.selectedFeatures))*"/"*string(ncol(e.data))*
             " features selected.")
    end
end

abstract type AbstractReduce end
abstract type AbstractFilter <: AbstractReduce end
abstract type AbstractSimpleFilter <: AbstractFilter end
abstract type AbstractCombinationFilter <: AbstractFilter end

mutable struct Filter <: AbstractSimpleFilter
    value::Any
    feature::Symbol
    compare::Function
    description::String
end

# Constructor
function Filter(value, feature; 
                compare = isequal, description = "No description provided")
    return Filter(value, feature, compare, description)
end

mutable struct CombinationFilter <: AbstractCombinationFilter
    filter1::AbstractFilter
    filter2::AbstractFilter
    operator::Function
end

# Methods

"""Return filtered entries in an Experiment `e` based on filter `f`
"""
function filterEntriesExperiment(e::AbstractExperiment, f::AbstractSimpleFilter)
    expEntries = e.data[e.selectedEntries, f.feature]
    return(e.selectedEntries[f.compare.(expEntries, f.value)])
end

function filterEntriesExperiment(e::AbstractExperiment, f::AbstractCombinationFilter)
    e1 = filterEntriesExperiment(e, f.filter1)
    e2 = filterEntriesExperiment(e, f.filter2)
    return(sort(f.operator(e1, e2)))
end


"""Filter entries in an Experiment `e` based on filter(s) `f`,
updating `e.selectedEntries` in place accordingly.
"""
function filterEntriesExperiment!(e::AbstractExperiment, f::AbstractFilter)
    # Currently returns the indices kept
    e.selectedEntries = filterEntriesExperiment(e,f)
end


function filterEntriesExperiment!(e::AbstractExperiment, filters::Array{T,1}) where {T<:AbstractFilter}
    for f in filters
        filterEntriesExperiment!(e, f)
    end
end

abstract type AbstractReduce end
abstract type AbstractSelector <: AbstractReduce end
abstract type AbstractSimpleSelector <: AbstractSelector end
abstract type AbstractCombinationSelector <: AbstractSelector end

mutable struct Selector <: AbstractSimpleSelector
    summarize::Function
    subset::Union{Vector{Number}, Nothing}
    description::String
end

# Constructor
function Selector(summarize; subset = nothing,
                  description = "No description provided")
    return Selector(summarize, subset, description)
end

mutable struct CombinationSelector <: AbstractCombinationSelector
    filter1::AbstractSelector
    filter2::AbstractSelector
    operator::Function
end

# Methods

"""Return selected features in an Experiment `e` based on selectors `s`
"""
function selectFeaturesExperiment(e::AbstractExperiment, s::AbstractSimpleSelector)
    # NB: isnothing was not implemented in 1.0
    if s.subset === nothing
        data = e.data[e.selectedEntries, e.selectedFeatures]
    else
        data = e.data[e.selectedEntries[s.subset], e.selectedFeatures]
    end
    selectedFtDF = mapcols(x -> s.summarize(x), data)
    return(e.selectedFeatures[[x for x in selectedFtDF[1,:]]])
end

"""Return selected features in an Experiment `e` based on selectors `s`,
updating `e.selectedFeatures` in place accordingly.
"""
function selectFeaturesExperiment!(e::AbstractExperiment, s::AbstractSimpleSelector)
    # Currently returns the indices kept
    e.selectedFeatures = selectFeaturesExperiment(e,s)
end

function selectFeaturesExperiment!(e::AbstractExperiment, selectors::Array{T,1}) where {T<:AbstractSelector}
    for s in selectors
        selectFeaturesExperiment!(e, s)
    end
end