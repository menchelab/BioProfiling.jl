# This is used to store experiment details
abstract type AbstractExperiment end

mutable struct Experiment <: AbstractExperiment
    data::DataFrame
    description::String
    selected_features::Array{Int64,1}
    selected_entries::Array{Int64,1}
end

# Constructor
# WARNING: data is not copied so any transformation of the Experiment's data
# will modify the original `data` DataFrame fed to the constructor. 
function Experiment(data; description = "No description provided")
    return Experiment(data, description, 1:ncol(data), 1:nrow(data))
end

function Base.show(io::IO, e::Experiment)
    compact = get(io, :compact, false)

    if compact
        show(io, "Exp.: "*string(length(e.selected_entries))*"/"*string(nrow(e.data))*
             "-"*string(length(e.selected_features))*"/"*string(ncol(e.data)))
    else
        show(io, "Experiment with "*string(length(e.selected_entries))*"/"*string(nrow(e.data))*
             " entries and "*string(length(e.selected_features))*"/"*string(ncol(e.data))*
             " features selected.")
    end
end

abstract type AbstractReduce end
abstract type AbstractFilter <: AbstractReduce end
abstract type AbstractSimpleFilter <: AbstractFilter end
abstract type AbstractCombinationFilter <: AbstractFilter end
# Unused type - can probably be removed in next major release
abstract type AbstractMissingFilter <: AbstractFilter end 

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

# Unused type - can probably be removed in next major release
mutable struct MissingFilter <: AbstractMissingFilter end

# Special filters
"""
Returns a Filter object excluding rows having missing values
for a given `feature`.
"""
function MissingFilter(feature; 
                        description = "Remove missing values")
    return Filter(1, feature, (x,y) -> !ismissing(x), description)
end

"""
Returns a Filter object excluding rows in which the values for a  
given `feature` are elements in `collection` (set membership).
"""
function MembershipFilter(collection, feature; 
                        description = "Keep entries with specific values")
    return Filter(collection, feature, _compare_in, description)
end

# Methods

"""Return filtered entries in an Experiment `e` based on filter `f`
"""
function filter_entries(e::AbstractExperiment, f::AbstractSimpleFilter)
    expEntries = e.data[e.selected_entries, f.feature]
    return(e.selected_entries[f.compare.(expEntries, f.value)])
end

function filter_entries(e::AbstractExperiment, f::AbstractCombinationFilter)
    e1 = filter_entries(e, f.filter1)
    e2 = filter_entries(e, f.filter2)
    return(sort(f.operator(e1, e2)))
end

function filter_entries(e::AbstractExperiment, f::AbstractMissingFilter)
    return(sort(∩([filter_entries(e, MissingFilter(f)) 
                   for f in Symbol.(names(e.data)[e.selected_features])]...)))
end

"""Filter entries in an Experiment `e` based on filter(s) `f`,
updating `e.selected_entries` in place accordingly.
"""
function filter_entries!(e::AbstractExperiment, f::AbstractFilter)
    # Currently returns the indices kept
    e.selected_entries = filter_entries(e,f)
end


function filter_entries!(e::AbstractExperiment, filters::Array{T,1}) where {T<:AbstractFilter}
    for f in filters
        filter_entries!(e, f)
    end
end

abstract type AbstractReduce end
abstract type AbstractSelector <: AbstractReduce end
abstract type AbstractSimpleSelector <: AbstractSelector end
abstract type AbstractNameSelector <: AbstractSelector end
abstract type AbstractCombinationSelector <: AbstractSelector end

mutable struct Selector <: AbstractSimpleSelector
    summarize::Function
    subset::Union{Function, Nothing}
    description::String
end

# Constructor
function Selector(summarize; subset = nothing,
                  description = "No description provided")
    return Selector(summarize, subset, description)
end

mutable struct NameSelector <: AbstractNameSelector
    summarize::Function
    description::String
end

# Constructor
function NameSelector(summarize; description = "No description provided")
    return NameSelector(summarize, description)
end

mutable struct CombinationSelector <: AbstractCombinationSelector
    selector1::AbstractSelector
    selector2::AbstractSelector
    operator::Function
end

# Methods

"""Return selected features in an Experiment `e` based on selectors `s`
"""
function select_features(e::AbstractExperiment, s::AbstractSimpleSelector)
    # NB: isnothing was not implemented in 1.0
    if s.subset === nothing
        data = e.data[e.selected_entries, e.selected_features]
    else
        subIndices = s.subset(e.data[e.selected_entries,:])
        data = e.data[e.selected_entries[subIndices], e.selected_features]
    end
    selectedFtDF = mapcols(s.summarize, data)
    return(e.selected_features[[x for x in selectedFtDF[1,:]]])
end

function select_features(e::AbstractExperiment, s::AbstractNameSelector)
    selectedFtDF = map(s.summarize, names(e.data[:,e.selected_features]))
    return(e.selected_features[selectedFtDF])
end

function select_features(e::AbstractExperiment, s::AbstractCombinationSelector)
    f1 = select_features(e, s.selector1)
    f2 = select_features(e, s.selector2)
    return(sort(s.operator(f1, f2)))
end

"""Return selected features in an Experiment `e` based on selectors `s`,
updating `e.selected_features` in place accordingly.
"""
function select_features!(e::AbstractExperiment, s::AbstractSelector)
    # Currently returns the indices kept
    e.selected_features = select_features(e,s)
end

function select_features!(e::AbstractExperiment, selectors::Array{T,1}) where {T<:AbstractSelector}
    for s in selectors
        select_features!(e, s)
    end
end


# Not exported in favor of the shorter "filter!" and "select!"
"""For an experiment `e`, update in place `e.selected_features` and 
`e.selected_entries` based on an array `arr` of feature selectors and 
entry filters. Filters and selectors are applied sequentially.
"""
function filter_experiment!(e::AbstractExperiment, arr::Array{T,1}) where {T<:AbstractReduce}
    for a in arr
        filter!(e, a)
    end
end

"""For an experiment `e`, update in place `e.selected_features` and 
`e.selected_entries` based on a feature selector `s`.
"""
function filter_experiment!(e::AbstractExperiment, s::AbstractSelector) 
    select_features!(e,s)
end

"""For an experiment `e`, update in place `e.selected_features` and 
`e.selected_entries` based on an entry filter `f`.
"""
filter_experiment!(e::AbstractExperiment, f::AbstractFilter) = filter_entries!(e,f)


# Aliases 
@doc (@doc filter_experiment!)
Base.filter!(e::AbstractExperiment, 
                   arr::Array{T,1}) where {T<:AbstractReduce} = filter_experiment!(e,arr)
Base.filter!(e::AbstractExperiment, s::AbstractSelector) = filter_experiment!(e,s)
Base.filter!(e::AbstractExperiment, f::AbstractFilter) = filter_experiment!(e,f)

@doc (@doc filter_experiment!)
DataFrames.select!(e::AbstractExperiment, 
                   arr::Array{T,1}) where {T<:AbstractReduce} = filter_experiment!(e,arr)
DataFrames.select!(e::AbstractExperiment, s::AbstractSelector) = filter_experiment!(e,s)
DataFrames.select!(e::AbstractExperiment, f::AbstractFilter) = filter_experiment!(e,f)

"""Return a negative Filter or Selector by inverting 
the entries or features that are kept and excluded.
"""
function negation(r::Union{AbstractNameSelector,AbstractSimpleSelector})
    neg_r = deepcopy(r)
    neg_r.summarize = !neg_r.summarize
    neg_r.description = "Do not "*neg_r.description
    return(neg_r)
end

function negation(r::AbstractSimpleFilter)
    neg_r = deepcopy(r)
    neg_r.compare = !neg_r.compare
    neg_r.description = "Do not "*neg_r.description
    return(neg_r)
end

"""Return a copy of the data in Experiment `e` for its 
selected entries and features.
"""
function getdata(e::Experiment)
    return(e.data[e.selected_entries, e.selected_features])
end
