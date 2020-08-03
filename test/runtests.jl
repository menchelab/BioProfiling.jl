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

@testset "Experiment" begin
	# Define example dataset
	Random.seed!(3895)
	d = DataFrame(rand(12,2))
	names!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity])
	d.Experiment = sample(["Exp1", "Exp2"], 12)

	e1 = Experiment(d)
	@test e1.description == "No description provided"
	@test e1.selectedEntries == 1:12

	# Additional checks that could be performed:
	# Test print format
end

@testset "Filter" begin
	d1 = "Select only a single experiment"
    f1 = Filter("Exp1", :Experiment, description = d1)
	d2 = "Reject cells in high density regions"
	f2 = Filter(0.2, :Intensity_MedianIntensity_NeurDensity, compare = isless, 
	            description = d2)
	@test f1.description == d1
	@test f2.description == d2

	# Define example dataset
	Random.seed!(3895)
	d = DataFrame(rand(12,2))
	# NB: throws a warning 1.0 suggesting to use rename! instead
	# Yet rename! only accepts pairs of symbols in late 1.x versions
	names!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity])
	d.Experiment = sample(["Exp1", "Exp2"], 12)

	e1 = Experiment(d)

	filterEntriesExperiment!(e1, f1)
	@test e1.selectedEntries == [1,2,7,9,12]

	filterEntriesExperiment!(e1, f2)
	@test e1.selectedEntries == [7]

	e2 = Experiment(d)
	filterEntriesExperiment!(e2, [f1,f2])
	@test e2.selectedEntries == [7]

	e3 = Experiment(d)
	f3 = Filter(0.8, :Ft1, compare = >, description = "Large feature 1")
	cf1 = CombinationFilter(f1,f2,intersect)
	cf2 = CombinationFilter(cf1,f3,union)

	@test filterEntriesExperiment(e3, cf1) == [7]
	@test filterEntriesExperiment(e3, cf2) == [2,6,7,10]

	# Additional checks that could be performed:
	# Filter.compare::Function -> Make sure it takes 2 arguments and return 1?
	# CombinationFilter.operator::Function -> Make sure it takes 2 lists and return 1?
end

@testset "Selector" begin
	# Define example dataset
	Random.seed!(3895)
	d = DataFrame(rand(12,2))
	# NB: throws a warning 1.0 suggesting to use rename! instead
	# Yet rename! only accepts pairs of symbols in late 1.x versions
	names!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity])
	d.Experiment = sample(["Exp1", "Exp2"], 12)

	e1 = Experiment(d)

	s1 = Selector(x -> eltype(x) <: Number)
	s2 = Selector(x -> mean(x) > 0.5, subset = findall(d.Experiment .== "Exp1"),
				  description = "High mean for Exp1")

	@test s1.subset === nothing
	@test s2.description == "High mean for Exp1"

	@test selectFeaturesExperiment(e1, s1) == [1,2]
	selectFeaturesExperiment!(e1, [s1, s2])
	@test e1.selectedFeatures == [2]
end