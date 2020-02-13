module RMP
export logtransform, normtransform, decorrelate, mahalanobis
using Statistics, StatsBase, DataFrames

# Approximate normal distribution
logtransform(x) = log.(x .+ 1 .- minimum(x))

# Center and scale on control values
normtransform(x,y) = (x .- median(y)) ./ mad(y, normalize = true)

function decorrelate(data::DataFrame; orderCol = nothing, threshold = 0.8)
    """Returns column  of 'data' that are never pairwise-correlated more than 'threshold',
    prioritizing columns by a given order 'orderCol' (defaults to left to right).
    """
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

function mahalanobis(arrX::Vector{Float64}, µ::Vector{Float64}, S::Array{Float64,2})
    """Squared mahalanobis distance for covariance estimator S and center µ"""
    return((arrX - µ)'*inv(S)*(arrX - µ))
end

# Allows the computation to be mapped on rows of a DataFrame
mahalanobis(x::DataFrameRow, µ::Vector{Float64}, S::Array{Float64,2}) = 
    mahalanobis(convert(Vector, x), µ, S)

end # module
