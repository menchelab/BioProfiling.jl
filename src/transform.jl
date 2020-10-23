"""Approximate normal distribution"""
logtransform(x) = log.(x .+ 1 .- minimum(x))

"""Approximate normal distribution of selected entries 
for all selected features of an Experiment `e`.
"""
function logtransform!(e::Experiment)
    e.data[e.selectedEntries, e.selectedFeatures] .= e |>
                                                     getdata |>    
                                                     eachcol |>    
                                                     x -> map(logtransform, x) |>  
                                                     x -> hcat(x...)
end

"""Center and scale on control values"""
normtransform(x,y) = (x .- median(y)) ./ mad(y, normalize = true)

"""Center and scale all selected entries for each selectead features
of an Experiment `e` on control values matching a Filter `f`
"""
function normtransform!(e::Experiment, f::RMP.AbstractFilter)
    f_col = filterEntriesExperiment(e,f)
    e.data[e.selectedEntries, e.selectedFeatures] .= e.data[:, e.selectedFeatures] |>
                                                     eachcol |>
                                                     x -> map(y -> normtransform(y[e.selectedEntries],
                                                                                 y[f_col]), x) |>
                                                     x -> hcat(x...)    
end

"""Returns column  of 'data' that are never pairwise-correlated more than 'threshold',
   prioritizing columns by a given order 'orderCol' (defaults to left to right).
"""
function decorrelate(data::DataFrame; orderCol = nothing, threshold = 0.8)
    if orderCol === nothing
        orderCol = collect(1:size(data, 2))
    end
    # Columns to sort
    L1 = copy(orderCol) # Copy to avoid modifying the input list
    # Sorted columns to keep
    L2 = Array{Int64,1}() 
    while length(L1) > 0
        # Use the first non-correlated term as "pivot"
        refFt = first(L1)
        append!(L2, refFt)
        popfirst!(L1)
        stillToKeep = []
        # Which remaining terms are non correlated?
        for (ift, ft) in enumerate(L1)
            if abs(cor(data[:,refFt], data[:,ft])) < threshold
                append!(stillToKeep, ift)
            end
        end
        # Remove remaining correlated terms
        L1 = L1[stillToKeep]
    end
    return(L2)
end

# Allows the computation to be mapped on  of a DataFrame
decorrelate(data::AbstractMatrix; orderCol = nothing, threshold = 0.8) =
	decorrelate(DataFrame(data), orderCol = orderCol, threshold = threshold)