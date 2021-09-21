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
Return the 
"""
function characteristic_features(e::Experiment, 
                                 reference, 
                                 condition;
                                 top::Int64 = 0)
end