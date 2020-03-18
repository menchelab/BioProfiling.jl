module RMP
export logtransform, normtransform, decorrelate, mahalanobis, hellinger
using Statistics, StatsBase, DataFrames
using LinearAlgebra: det

# Approximate normal distribution
logtransform(x) = log.(x .+ 1 .- minimum(x))

# Center and scale on control values
normtransform(x,y) = (x .- median(y)) ./ mad(y, normalize = true)

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

"""Squared mahalanobis distance for covariance estimator S and center µ"""
function mahalanobis(arrX::AbstractVector{Float64}, 
					 µ::AbstractVector{Float64}, S::AbstractArray{Float64,2})
    return((arrX - µ)'*inv(S)*(arrX - µ))
end

# Allows the computation to be mapped on rows of a DataFrame
mahalanobis(x::DataFrameRow, µ::AbstractVector{Float64}, S::AbstractArray{Float64,2}) = 
    mahalanobis(convert(Vector, x), µ, S)

"""Squared hellinger distance for covariance estimators S and centers µ"""
function hellinger(µ1::AbstractVector{Float64}, S1::AbstractArray{Float64,2}, 
				   µ2::AbstractVector{Float64}, S2::AbstractArray{Float64,2})
    S = (S1 + S2)/2
    H = 1 - (det(S1)^(1/4))*(det(S2)^(1/4))/(det(S)^(1/2))*
    	exp((-1/8)*(µ1-µ2)'*inv(S)*(µ1-µ2))
    return(H)
end

end # module
