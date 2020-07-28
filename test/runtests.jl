using RMP
using Test
using DataFrames
using StatsBase
using LinearAlgebra: I
using Random

@testset "decorrelate" begin
    X = DataFrame([[1,2,3],[3,2,1],[0,1,2],[1,0,1]])
    @test decorrelate(X) == [1,4]
    @test decorrelate(X, orderCol = [3,1,2]) == [3]
end

@testset "hellinger" begin
	Random.seed!(777)
	# The covariance matrix s is expected to be
    # a symmetric positive definite matrix
    c = rand(5)
    s = rand(5,5)
    s = s*s' + I
    # Distance of a distribution to itself should be zero, up to
    # machine precision. NB: approximation includes relative term
    # so isapprox(1e-200, 0) = false
	@test hellinger(c, s, c, s) + 1 ≈ 1 
	function testpositivedefinite()
		c = rand(5)
	    s = rand(5,5)
	    s = s*s' + I
	    return(hellinger(c, s, c .+1, s) > 0)
	end
	@test all([testpositivedefinite() for x in 1:20])
end

@testset "logtransform" begin
    @test logtransform(1) == 0
    @test_throws MethodError logtransform("str")
    @test round.(logtransform(1:5), digits=2) == [0.0, 0.69, 1.1, 1.39, 1.61]
end

@testset "mahalanobis" begin
	Random.seed!(777)
    c = rand(5)
    s = rand(5,5)
	@test mahalanobis(c, c, s) == 0
	function testpositivedefinite()
		c = rand(5)
		# The covariance matrix s is expected to be
	    # a symmetric positive definite matrix
	    s = rand(5,5)
	    s = s*s' + I
	    return(mahalanobis(c, c .+1, s) > 0)
	end
	@test all([testpositivedefinite() for x in 1:20])
end

@testset "normtransform" begin
    x = 1:5
	@test round.(normtransform(x,x), digits = 2) == [-1.35, -0.67, 0.0, 0.67, 1.35]
    @test round.(normtransform(x,x[1:3]), digits = 2)  == [-0.67, 0.0, 0.67, 1.35, 2.02]
    @test_throws MethodError normtransform("str",x)
    @test_throws MethodError normtransform(x,"str")
end

@testset "filterEntriesExperiment" begin
	d1 = "Select only a single experiment"
    f1 = Filter("Exp1", :Experiment, description = d1)
	d2 = "Reject cells in high density regions"
	f2 = Filter(0.2, :Intensity_MedianIntensity_NeurDensity, comparison = isless, 
	            description = d2)
	@test f1.description == d1
	@test f2.description == d2

	# Define example dataset
	Random.seed!(3895)
	d = DataFrame(rand(12,2))
	rename!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity])
	d.Experiment = sample(["Exp1", "Exp2"], 12)

	e1 = Experiment(d)
	@test e1.description == "No description provided"
	@test e1.selectedEntries == 1:12

	filterEntriesExperiment!(e1, f1)
	@test e1.selectedEntries == [1,2,7,9,12]

	filterEntriesExperiment!(e1, f2)
	@test e1.selectedEntries == [7]

	e2 = Experiment(d)
	filterEntriesExperiment!(e2, [f1,f2])
	@test e2.selectedEntries == [7]
end