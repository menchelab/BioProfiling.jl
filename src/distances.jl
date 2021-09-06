""" [intended for internal use only]
Enforce small numbers to be zero 
Helper function used for testing."""
function set_small_to_zero(a::Number)
	# Note: this tolerates up to approximately 1e-8
   	return(a + 1 ≈ 1 ? 0 : a)
end

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
    # Singularity sometimes lead to negative determinant values
    # (computational artifacts) and values need to be set to zero
    dS1 = set_small_to_zero(det(S1))
    dS2 = set_small_to_zero(det(S2))
    dS = set_small_to_zero(det(S))
    H = 1 - (dS1^(1/4))*(dS2^(1/4))/(dS^(1/2))*
    	exp((-1/8)*(µ1-µ2)'*inv(S)*(µ1-µ2))
    return(H)
end