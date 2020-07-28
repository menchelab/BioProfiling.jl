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