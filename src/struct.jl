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

abstract type AbstractFilter end
abstract type AbstractSimpleFilter <: AbstractFilter end
abstract type AbstractCombinationFilter <: AbstractFilter end

mutable struct Filter <: AbstractSimpleFilter
    value::Any
    feature::Symbol
    comparison::Function
    description::String
end

# Constructor
function Filter(value, feature; 
                comparison = isequal, description = "No description provided")
    return Filter(value, feature, comparison, description)
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
    return(e.selectedEntries[f.comparison.(expEntries, f.value)])
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
    e.selectedEntries = filterEntriesExperiment(e,f)
end


function filterEntriesExperiment!(e::AbstractExperiment, filters::Array{T,1}) where {T<:AbstractFilter}
    for f in filters
        filterEntriesExperiment!(e, f)
    end
end