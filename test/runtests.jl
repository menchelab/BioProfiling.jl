using RMP
using Test
using DataFrames
using StatsBase
using LinearAlgebra: I
using Random

@testset "decorrelate" begin
    X = DataFrame([[1,2,3],[3,2,1],[0,1,2],[1,0,1]])
    @test decorrelate(X) == [1,4]
    @test decorrelate(X, ordercol = [3,1,2]) == [3]
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
	s2 = Selector(x -> mean(x) > 0.5, subset = x -> x.Experiment .== "Exp1",
				  description = "High mean for Exp1")

	@test s1.subset === nothing
	@test s2.description == "High mean for Exp1"

	@test selectFeaturesExperiment(e1, s1) == [1,2]
	selectFeaturesExperiment!(e1, [s1, s2])
	@test e1.selectedFeatures == [2]

	strToRemove = ["MedianIntensity", "MorePatterns"]
	s3 = NameSelector(x -> !any(occursin.(strToRemove, String(x))))
	e2 = Experiment(d)
	@test selectFeaturesExperiment(e2, s3) == [1,3]

	selectFeaturesExperiment!(e2, [s1, s2, s3])
	@test length(e2.selectedFeatures) == 0

	e3 = Experiment(d)
	s4 = deepcopy(s1)
	# Inverse function: keeps textual features
	s4.summarize = !s4.summarize
	s5 = deepcopy(s3)
	# Inverse function: keeps features including "MedianIntensity"
	s5.summarize = !s5.summarize

	cs1 = CombinationSelector(s4,s5,union)
	@test selectFeaturesExperiment(e3, cs1) == [2,3]
end

@testset "filterExperiment!" begin
    # Define example dataset
	Random.seed!(3895)
	d = DataFrame(rand(12,2))
	# NB: throws a warning 1.0 suggesting to use rename! instead
	# Yet rename! only accepts pairs of symbols in late 1.x versions
	names!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity])
	d.Experiment = sample(["Exp1", "Exp2"], 12)

	e1 = Experiment(d)

	# Create selectors
	s1 = Selector(x -> !(eltype(x) <: Number),
				  description = "Keep textual features")
	keptPatterns = ["MedianIntensity", "MorePatterns"]
	s2 = NameSelector(x -> any(occursin.(keptPatterns, String(x))),
					  description = "Keep features including chosen patterns")
	cs1 = CombinationSelector(s1,s2,union)

	# Create filters
	d1 = "Select only a single experiment"
    f1 = Filter("Exp1", :Experiment, description = d1)
	d2 = "Reject cells in high density regions"
	f2 = Filter(0.2, :Intensity_MedianIntensity_NeurDensity, compare = isless, 
	            description = d2)

	filterExperiment!(e1,[cs1,f1,f2])
	@test length(e1.selectedFeatures) == 2
	@test e1.selectedEntries == [7]
end

@testset "diagnostic" begin
    # Define example dataset
	Random.seed!(3895)
	d = DataFrame(rand(12,2))

	names!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity])
	d.Experiment = sample(["Exp1", "Exp2"], 12)

	e1 = Experiment(d)

	d1 = "Select only a single experiment"
	f1 = Filter("Exp1", :Experiment, description = d1)
	d2 = "Reject cells in high density regions"
	f2 = Filter(0.2, :Intensity_MedianIntensity_NeurDensity, compare = isless, 
	            description = d2)

	cf1 = CombinationFilter(f1,f2,intersect)

	@test diagnostic(e1, cf1, features = [:Ft1]) == DataFrame(Ft1 = 0.056572675137066764)

	@test diagnosticURLImage(e1, cf1, :Ft1) == [0.056572675137066764]
	@test diagnosticURLImage(e1, cf1, :Experiment, rgx = [r".*" => s"example.png"]) == ["example.png"]

	@test diagnosticImages(e1, cf1, :Experiment, rgx = [r".*" => s"example.png"], saveimages = false)
	# Additional checks that could be performed:
	# Centers of diagnosticURLImage
	# getColorImage [internal]
	# colimgifrgb [internal]
	# rgb parameters of diagnosticImages
	# output of diagnosticImages
end

@testset "negation" begin
	Random.seed!(3895)
	d = DataFrame(rand(12,2))

	names!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity])
	d.Experiment = sample(["Exp1", "Exp2"], 12)

	e1 = Experiment(d)

	# Test negation of simple filter
	d1 = "Select only a single experiment"
	f1 = Filter("Exp1", :Experiment, description = d1)
	nf1 = negation(f1)

	@test nf1.description == "Do not "*f1.description
	@test all(e1.data.Experiment[filterEntriesExperiment(e1, f1)] .== "Exp1")
	@test all(e1.data.Experiment[filterEntriesExperiment(e1, nf1)] .== "Exp2")

	# Test negation of simple selector
	s1 = Selector(x -> eltype(x) <: Number, description = "Keep numeric features")
	ns1 = negation(s1)

	@test ns1.description == "Do not "*s1.description

	ft_ns1 = selectFeaturesExperiment(e1, ns1)
	@test ft_ns1 == [3]
	# The union of the columns selected by a selector and its negation should be the set of all columns
	append!(ft_ns1, selectFeaturesExperiment(e1, s1))
	@test Set(ft_ns1) == Set(1:ncol(e1.data))

    # Test negation of name selector
	s2 = NameSelector(x -> occursin("Ft1", String(x)), "Keep Ft1")
	ns2 = negation(s2)

	@test ns2.description == "Do not "*s2.description

	ft_ns2 = selectFeaturesExperiment(e1, ns2)
	@test ft_ns2 == [2,3]
	# The union of the columns selected by a selector and its negation should be the set of all columns
	append!(ft_ns2, selectFeaturesExperiment(e1, s2))
	@test Set(ft_ns2) == Set(1:ncol(e1.data))
end

@testset "getdata" begin
    # Here we test whether we can access the data filtered
    # and use it for helper functions

    # Generate test data
	d = DataFrame(rand(12,2))
	names!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity])
	d.Experiment = repeat(["Exp1", "Exp2"], 6)

	e1 = Experiment(d)

	# Filter data
	d1 = "Select only a single experiment"
	f1 = Filter("Exp1", :Experiment, description = d1)
	s1 = Selector(x -> eltype(x) <: Number,
	              description = "Keep numerical features")

	filterExperiment!(e1,[f1,s1])

	# Test `getdata`
	@test length(e1.selectedFeatures) == 2
	@test length(e1.selectedEntries) == 6
	@test RMP.getdata(e1) == e1.data[e1.selectedEntries, e1.selectedFeatures]

	# Test `logtransform`

	# Keep track of original values
	d_copy = copy(getdata(e1))
	e2 = deepcopy(e1)

	logtransform!(e1)

	# Check the transformation of one column
	@test getdata(e1).Ft1 == d_copy.Ft1 |> x -> log.(1 .+ x .- minimum(x))
	# Check that the original data is modified but not the copy
	@test getdata(e1).Ft1 == d.Ft1[(1:6)*2 .- 1]
	@test getdata(e2) == d_copy


	# Test `normtransform`

	# Keep track of original values
	e3 = deepcopy(e2)

	thr = sort(getdata(e2).Intensity_MedianIntensity_NeurDensity)[end-2]
	f2 = Filter(thr, :Intensity_MedianIntensity_NeurDensity, 
	       compare = >=, description = "Top 3 values")

	normtransform!(e2,f2)

	# Must include at least one 0 per column (centered on median of a subset of entries)
	for c in eachcol(getdata(e2))
		@test 0 in c
	end
	# At most 1 value > 0 (after substracting median of top 3 values)
	@test sum(getdata(e2).Intensity_MedianIntensity_NeurDensity .> 0) <= 1
	# Check that the original data is modified but not the copy
	@test getdata(e3) != getdata(e2)
	@test getdata(e3) == d_copy

	# Test `decorrelate`

	# Add correlated columns
	d.Ft3 = -d.Ft1
	d.Ft4 = copy(d.Intensity_MedianIntensity_NeurDensity)
	d.Ft4[1] = 1
	d.Intensity_MedianIntensity_NeurDensity[1] = 0

	e4 = Experiment(d)
	filterExperiment!(e4,[f1,s1])
	decorrelate!(e4)
	# First column always kept, inverse column removed
	@test 1 in e4.selectedFeatures
	@test !(4 in e4.selectedFeatures)

	e4 = Experiment(d)
	filterExperiment!(e4,[f1,s1])
	decorrelate!(e4, threshold = 1)
	# Not perfectly correlated by design
	@test 5 in e4.selectedFeatures

	e4 = Experiment(d)
	filterExperiment!(e4,[f1,s1])
	decorrelate!(e4, ordercol = [4,3,2,1])
	# Reversed order: first column always kept, inverse column removed
	@test 4 in e4.selectedFeatures
	@test !(1 in e4.selectedFeatures)
end