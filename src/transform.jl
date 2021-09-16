"""[intended for internal use only]
Convert all selected data columns to floats
"""
function _data_to_float!(e::Experiment)
    # Make sure all values are numbers
    @assert all(eltype.(eachcol(getdata(e))) .<: Number)
    # Convert each column to floats
    for colname in names(getdata(e))
        e.data[!,colname] = float.(e.data[:,colname])
    end
end

"""Approximate normal distribution"""
logtransform(x) = log.(x .+ 1 .- minimum(x))

"""Approximate normal distribution of selected entries 
for all selected features of an Experiment `e`.
Warning: columns are converted to float when necessary.
"""
function logtransform!(e::Experiment)
    _data_to_float!(e)
    e.data[e.selected_entries, e.selected_features] .= e |>
                                                     getdata |>    
                                                     eachcol |>    
                                                     x -> map(logtransform, x) |>  
                                                     x -> hcat(x...)
end

"""Center and scale on control values"""
normtransform(x,y) = (x .- median(y)) ./ mad(y, normalize = true)

"""Center and scale all selected entries for each selectead features
of an Experiment `e` on control values matching a Filter `f`,
based on the median and median absolute deviation of the control.
Warning: columns are converted to float when necessary.
"""
function normtransform!(e::Experiment, f::AbstractFilter)
    f_col = filter_entries(e,f)
    _data_to_float!(e)
    e.data[e.selected_entries, e.selected_features] .= e.data[:, e.selected_features] |>
                                                     eachcol |>
                                                     x -> map(y -> normtransform(y[e.selected_entries],
                                                                                 y[f_col]), x) |>
                                                     x -> hcat(x...)    
end

"""Returns column  of 'data' that are never pairwise-correlated more than 'threshold',
   prioritizing columns by a given order 'ordercol' (defaults to left to right).
"""
function decorrelate(data::DataFrame; ordercol = nothing, threshold = 0.8)
    if ordercol === nothing
        ordercol = collect(1:size(data, 2))
    end
    # Columns to sort
    L1 = copy(ordercol) # Copy to avoid modifying the input list
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

# Allows the computation to be mapped on columns of a DataFrame
decorrelate(data::AbstractMatrix; ordercol = nothing, threshold = 0.8) =
	decorrelate(DataFrame(data), ordercol = ordercol, threshold = threshold)

"""Returns column  of selected data in Experiment `e` that are never 
    pairwise-correlated more than 'threshold', prioritizing columns by 
    a given order 'ordercol' (defaults to left to right).
"""
function decorrelate!(e::Experiment; ordercol = nothing, threshold = 0.8)
    e.selected_features = e.selected_features[decorrelate(getdata(e), 
                                                        ordercol=ordercol,
                                                        threshold=threshold)]
end

"""Returns column  of selected data in Experiment `e` that are never 
    pairwise-correlated more than 'threshold', prioritizing columns 
    with largest median absolute deviation.
"""
function decorrelate_by_mad!(e::Experiment; threshold = 0.8)
    # Order features from biggest mad to smallest mad
    # When features have mad(reference) = 1, it means that we rank features 
    # by how more variable they are overall compared to the reference
    order_features = sortperm(convert(Array, map(x -> mad(x, normalize = true), 
                     eachcol(getdata(e)))), rev=true);
    decorrelate!(e, ordercol = order_features, threshold = threshold)
end
