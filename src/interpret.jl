"""
Return the features of `e` ranked by decreasing
median absolute deviation. Trim to the 
first `top` features if a value is provided.
"""
function most_variable_features(e::Experiment; top::Int64 = 0)
    e_mad_ind = e |>
                 getdata |>    
                 eachcol |>
                 x -> mad.(x, normalize = true) |>
                 sortperm |>
                 reverse

    # Get symbols from indices
    e_mad_sym = names(getdata(e))[e_mad_ind]

    # Truncate if needed
    if (top > 0) && (length(e_mad_sym) > top)
        e_mad_sym = e_mad_sym[1:top]
    end

    return(e_mad_sym)
end

"""
Return (all or if provided the `top`) features
varying the most in `e` (largest absolute log 
fold change), when comparing entries matching
filters `f1` and `f2`. Columns for which the 
fold change is negative come last.
"""
function characteristic_features(e::Experiment,
                                 f1::AbstractFilter, 
                                 f2::AbstractFilter;
                                 top::Int64 = 0)
    f1_col = filter_entries(e,f1)
    f2_col = filter_entries(e,f2)

    lfc_ind = e.data[:, e.selected_features] |>
         eachcol |>
         y -> map(x -> mean(x[f1_col]) / mean(x[f2_col]), y) |>
         y -> map(x -> x <= 0 ? 0 : abs(log2(x)), y) |>
         sortperm |>
         reverse

    # Get symbols from indices
    sym = names(getdata(e))[lfc_ind]

    # Truncate if needed
    if (top > 0) && (length(sym) > top)
        sym = sym[1:top]
    end

    return(sym)
end

"""
Return (all or if provided the `top`) features
in `e` associated the most with `ref` (absolute
Pearson correlation).
"""
function most_correlated(e::Experiment,
                         ref::AbstractVector;
                         top::Int64 = 0)
    @assert all( [x <: Number for x in eltype.(eachcol(getdata(e)))] )
    mostcor_ind = e |> getdata |>
                   x -> cor(ref, Array(x)) |> 
                   x -> abs.(x) |>
                   x -> sortperm([x...]) |>
                   reverse

    # Get symbols from indices
    mostcor = names(getdata(e))[mostcor_ind]

    # Truncate if needed
    if (top > 0) && (length(mostcor) > top)
        mostcor = mostcor[1:top]
    end

    return(mostcor)
end

function most_correlated(e::Experiment,
                         ref::Symbol;
                         top::Int64 = 0)
    ref_vector = e.data[e.selected_entries,ref]
    most_correlated(e,ref_vector,top = top)
end