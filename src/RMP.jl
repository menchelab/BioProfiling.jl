module RMP
export transfLog, transfNorm
using Statistics, StatsBase

# Approximate normal distribution
transfLog(x) = log.(x .+ 1 .- minimum(x))

# Center and scale on control values
transfNorm(x,y) = (x .- median(y)) ./ mad(y, normalize = true)

end # module
