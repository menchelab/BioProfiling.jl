using BioProfiling
using Test
using DataFrames
using Statistics
using StatsBase
using LinearAlgebra: I
using Random
using RCall
using Distributed
using ParallelDataTransfer

@testset "freqtable" begin
	d = DataFrame(Any[0.05131 0.32830 "Exp1"; 0.83296 0.97647 "Exp1"; 0.66463 0.66939 "Exp2"; 
	                  0.30651 0.58938 "Exp2"; 0.71313 0.18477 "Exp2"; 0.81810 0.16309 "Exp2"; 
	                  0.05657 0.06012 "Exp1"; 0.02205 0.17055 "Exp2"; 0.49819 0.91871 "Exp1"; 
	                  0.90857 0.18794 "Exp2"; 0.12327 0.00619 "Exp2"; 0.34146 0.62640 "Exp1"])
	rename!(d, [:Ft1, :Ft2, :Experiment])

	e1 = Experiment(d, description = "Test Experiment")

	d1 = "Reject cells with high Ft2 values"
	f1 = Filter(0.9, :Ft2, compare = isless, 
	            description = d1)

	@test freqtable(e1, f1) == [2,10]
	filter_entries!(e1, f1)

	d2 = "Select only a single experiment"
    f2 = Filter("Exp1", :Experiment, description = d2)

    @test freqtable(e1, f2) == [7,3]

    @test freqtable(e1, :Experiment) == [3,7]
end

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
    # machine precision. Note: approximation includes relative term
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
	d = DataFrame(Any[0.0513198 0.328301 "Exp1"; 0.832986 0.976474 "Exp1"; 0.664634 0.669392 "Exp2"; 
	                  0.306519 0.58938 "Exp2"; 0.71313 0.184778 "Exp2"; 0.818107 0.163095 "Exp2"; 
	                  0.0565727 0.0601279 "Exp1"; 0.022015 0.170559 "Exp2"; 0.498196 0.918719 "Exp1"; 
	                  0.908576 0.187947 "Exp2"; 0.123237 0.00619995 "Exp2"; 0.341462 0.626406 "Exp1"])
	rename!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity, :Experiment])
	d.Ft1 = convert.(Float64, d.Ft1)
	d.Intensity_MedianIntensity_NeurDensity = convert.(Float64, d.Intensity_MedianIntensity_NeurDensity)
	d.Experiment = convert.(String, d.Experiment)

	e1 = Experiment(d)
	@test e1.description == "No description provided"
	@test e1.selected_entries == 1:12

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
	d = DataFrame(Any[0.0513198 0.328301 "Exp1"; 0.832986 0.976474 "Exp1"; 0.664634 0.669392 "Exp2"; 
	                  0.306519 0.58938 "Exp2"; 0.71313 0.184778 "Exp2"; 0.818107 0.163095 "Exp2"; 
	                  0.0565727 0.0601279 "Exp1"; 0.022015 0.170559 "Exp2"; 0.498196 0.918719 "Exp1"; 
	                  0.908576 0.187947 "Exp2"; 0.123237 0.00619995 "Exp2"; 0.341462 0.626406 "Exp1"])
	rename!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity, :Experiment])
	d.Ft1 = convert.(Float64, d.Ft1)
	d.Intensity_MedianIntensity_NeurDensity = convert.(Float64, d.Intensity_MedianIntensity_NeurDensity)
	d.Experiment = convert.(String, d.Experiment)


	e1 = Experiment(d)

	filter_entries!(e1, f1)
	@test e1.selected_entries == [1,2,7,9,12]

	filter_entries!(e1, f2)
	@test e1.selected_entries == [7]

	e2 = Experiment(d)
	filter_entries!(e2, [f1,f2])
	@test e2.selected_entries == [7]

	e3 = Experiment(d)
	f3 = Filter(0.8, :Ft1, compare = >, description = "Large feature 1")
	cf1 = CombinationFilter(f1,f2,intersect)
	cf2 = CombinationFilter(cf1,f3,union)

	@test filter_entries(e3, cf1) == [7]
	@test filter_entries(e3, cf2) == [2,6,7,10]

	# Additional checks that could be performed:
	# Filter.compare::Function -> Make sure it takes 2 arguments and return 1?
	# CombinationFilter.operator::Function -> Make sure it takes 2 lists and return 1?

	filter_entries!(e3, f2)

	# Add missing values
	e3.data.Ft1 = Array{Union{Missing, Float64},1}(e3.data.Ft1)
	e3.data.Experiment = Array{Union{Missing, String},1}(e3.data.Experiment)	
	e3.data.Ft1[4:6] .= missing
	e3.data.Experiment[[5,10,12]] .= missing

	mf1 = MissingFilter(:Ft1)
	mf2 = MissingFilter()

	@test filter_entries(e3, mf1) == [7,8,10,11]
	@test filter_entries(e3, mf2) == [7,8,11]
end

@testset "Selector" begin
	# Define example dataset
	d = DataFrame(Any[0.0513198 0.328301 "Exp1"; 0.832986 0.976474 "Exp1"; 0.664634 0.669392 "Exp2"; 
	                  0.306519 0.58938 "Exp2"; 0.71313 0.184778 "Exp2"; 0.818107 0.163095 "Exp2"; 
	                  0.0565727 0.0601279 "Exp1"; 0.022015 0.170559 "Exp2"; 0.498196 0.918719 "Exp1"; 
	                  0.908576 0.187947 "Exp2"; 0.123237 0.00619995 "Exp2"; 0.341462 0.626406 "Exp1"])

	rename!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity, :Experiment])
	d.Ft1 = convert.(Float64, d.Ft1)
	d.Intensity_MedianIntensity_NeurDensity = convert.(Float64, d.Intensity_MedianIntensity_NeurDensity)
	d.Experiment = convert.(String, d.Experiment)


	e1 = Experiment(d)

	s1 = Selector(x -> eltype(x) <: Number)
	s2 = Selector(x -> mean(x) > 0.5, subset = x -> x.Experiment .== "Exp1",
				  description = "High mean for Exp1")

	@test s1.subset === nothing
	@test s2.description == "High mean for Exp1"

	@test select_features(e1, s1) == [1,2]
	select_features!(e1, [s1, s2])
	@test e1.selected_features == [2]

	strToRemove = ["MedianIntensity", "MorePatterns"]
	s3 = NameSelector(x -> !any(occursin.(strToRemove, String(x))))
	e2 = Experiment(d)
	@test select_features(e2, s3) == [1,3]

	select_features!(e2, [s1, s2, s3])
	@test length(e2.selected_features) == 0

	e3 = Experiment(d)
	s4 = deepcopy(s1)
	# Inverse function: keeps textual features
	s4.summarize = !s4.summarize
	s5 = deepcopy(s3)
	# Inverse function: keeps features including "MedianIntensity"
	s5.summarize = !s5.summarize

	cs1 = CombinationSelector(s4,s5,union)
	@test select_features(e3, cs1) == [2,3]
end

@testset "filter!" begin
    # Define example dataset
	d = DataFrame(Any[0.0513198 0.328301 "Exp1"; 0.832986 0.976474 "Exp1"; 0.664634 0.669392 "Exp2"; 
	                  0.306519 0.58938 "Exp2"; 0.71313 0.184778 "Exp2"; 0.818107 0.163095 "Exp2"; 
	                  0.0565727 0.0601279 "Exp1"; 0.022015 0.170559 "Exp2"; 0.498196 0.918719 "Exp1"; 
	                  0.908576 0.187947 "Exp2"; 0.123237 0.00619995 "Exp2"; 0.341462 0.626406 "Exp1"])
	rename!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity, :Experiment])
	d.Ft1 = convert.(Float64, d.Ft1)
	d.Intensity_MedianIntensity_NeurDensity = convert.(Float64, d.Intensity_MedianIntensity_NeurDensity)
	d.Experiment = convert.(String, d.Experiment)


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

	filter!(e1,[cs1,f1,f2])
	@test length(e1.selected_features) == 2
	@test e1.selected_entries == [7]
end

@testset "diagnostic" begin
    # Define example dataset
	d = DataFrame(Any[0.0513198 0.328301 "Exp1"; 0.832986 0.976474 "Exp1"; 0.664634 0.669392 "Exp2"; 
	                  0.306519 0.58938 "Exp2"; 0.71313 0.184778 "Exp2"; 0.818107 0.163095 "Exp2"; 
	                  0.0565727 0.0601279 "Exp1"; 0.022015 0.170559 "Exp2"; 0.498196 0.918719 "Exp1"; 
	                  0.908576 0.187947 "Exp2"; 0.123237 0.00619995 "Exp2"; 0.341462 0.626406 "Exp1"])

	rename!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity, :Experiment])
	d.Ft1 = convert.(Float64, d.Ft1)
	d.Intensity_MedianIntensity_NeurDensity = convert.(Float64, d.Intensity_MedianIntensity_NeurDensity)
	d.Experiment = convert.(String, d.Experiment)


	e1 = Experiment(d)

	d1 = "Select only a single experiment"
	f1 = Filter("Exp1", :Experiment, description = d1)
	d2 = "Reject cells in high density regions"
	f2 = Filter(0.2, :Intensity_MedianIntensity_NeurDensity, compare = isless, 
	            description = d2)

	cf1 = CombinationFilter(f1,f2,intersect)

	@test diagnostic(e1, cf1, features = [:Ft1]) == DataFrame(Ft1 = 0.0565727)

	@test diagnostic_path(e1, cf1, :Ft1) == [0.0565727]
	@test diagnostic_path(e1, cf1, :Experiment, rgx = [r".*" => s"example.png"]) == ["example.png"]

	@test diagnostic_images(e1, cf1, :Experiment, rgx = [r".*" => s"example.png"], saveimages = false)
	# Additional checks that could be performed:
	# Centers of diagnostic_path
	# getColorImage [internal]
	# colimgifrgb [internal]
	# rgb parameters of diagnostic_images
	# output of diagnostic_images
end

@testset "interpret" begin
	# Define example dataset
	d = DataFrame([[0,2,4,6,8,21],[0,1,2,3,4,0],[0,3,6,9,12,3],'A':'F'])
	rename!(d, [Symbol.("Ft".*string.(1:3))..., :Class])

	f1 = Filter('F', :Class, compare = !=, description = "Exclude row")
	s1 = NameSelector(x -> occursin("Ft", String(x)), "Keep numerical features")

	e = Experiment(d)
	select!(e, [f1,s1])

	@test most_variable_features(e) == ["Ft3", "Ft1", "Ft2"]

	# Test equivalence to sorting by mad
	top1ft = most_variable_features(e, top = 1)
	decorrelate_by_mad!(e)
	@test names(e.data)[e.selected_features] == top1ft

    d = DataFrame(rand(120,3))
	rename!(d, Symbol.("Ft".*string.(1:3)))
	d.Class = repeat(["Ref", "A", "B"], 40)

	# Add specific differences for each class
	d[d.Class .== "A",:Ft2] .+= 2;
	d[d.Class .== "B",:Ft3] .+= 2;

	f1 = Filter(0.9, :Ft1, compare = <=, description = "Exclude 10% of entries")
	s1 = NameSelector(x -> occursin("Ft", String(x)), "Keep numerical features")

	e = Experiment(d)
	select!(e, [f1,s1])

	filt_Ref = Filter("Ref", :Class)
	filt_A = Filter("A", :Class)
	filt_B = Filter("B", :Class)

	@test characteristic_features(e, filt_Ref, filt_A, top = 1) == ["Ft2"]
	@test characteristic_features(e, filt_Ref, filt_B, top = 1) == ["Ft3"]
	@test characteristic_features(e, filt_A, filt_B)[3] == "Ft1"
	@test characteristic_features(e, filt_A, filt_B) == characteristic_features(e, filt_B, filt_A)

	correlated_ref = 3 .* getdata(e).Ft2;
	@test most_correlated(e, correlated_ref, top = 1)[1] == "Ft2"
	@test most_correlated(e, :Ft1)[1] == "Ft1"
	e.data.Ft2 .-= 2 .* e.data.Ft3
	@test most_correlated(e, :Ft3) == ["Ft3", "Ft2", "Ft1"]
end

@testset "negation" begin
	# Define example dataset
	d = DataFrame(Any[0.0513198 0.328301 "Exp1"; 0.832986 0.976474 "Exp1"; 0.664634 0.669392 "Exp2"; 
	                  0.306519 0.58938 "Exp2"; 0.71313 0.184778 "Exp2"; 0.818107 0.163095 "Exp2"; 
	                  0.0565727 0.0601279 "Exp1"; 0.022015 0.170559 "Exp2"; 0.498196 0.918719 "Exp1"; 
	                  0.908576 0.187947 "Exp2"; 0.123237 0.00619995 "Exp2"; 0.341462 0.626406 "Exp1"])

	rename!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity, :Experiment])
	d.Ft1 = convert.(Float64, d.Ft1)
	d.Intensity_MedianIntensity_NeurDensity = convert.(Float64, d.Intensity_MedianIntensity_NeurDensity)
	d.Experiment = convert.(String, d.Experiment)


	e1 = Experiment(d)

	# Test negation of simple filter
	d1 = "Select only a single experiment"
	f1 = Filter("Exp1", :Experiment, description = d1)
	nf1 = negation(f1)

	@test nf1.description == "Do not "*f1.description
	@test all(e1.data.Experiment[filter_entries(e1, f1)] .== "Exp1")
	@test all(e1.data.Experiment[filter_entries(e1, nf1)] .== "Exp2")

	# Test negation of simple selector
	s1 = Selector(x -> eltype(x) <: Number, description = "Keep numeric features")
	ns1 = negation(s1)

	@test ns1.description == "Do not "*s1.description

	ft_ns1 = select_features(e1, ns1)
	@test ft_ns1 == [3]
	# The union of the columns selected by a selector and its negation should be the set of all columns
	append!(ft_ns1, select_features(e1, s1))
	@test Set(ft_ns1) == Set(1:ncol(e1.data))

    # Test negation of name selector
	s2 = NameSelector(x -> occursin("Ft1", String(x)), "Keep Ft1")
	ns2 = negation(s2)

	@test ns2.description == "Do not "*s2.description

	ft_ns2 = select_features(e1, ns2)
	@test ft_ns2 == [2,3]
	# The union of the columns selected by a selector and its negation should be the set of all columns
	append!(ft_ns2, select_features(e1, s2))
	@test Set(ft_ns2) == Set(1:ncol(e1.data))
end

@testset "getdata" begin
    # Here we test whether we can access the data filtered
    # and use it for helper functions

    # Generate test data
	d = DataFrame(rand(12,2))
	rename!(d, [:Ft1, :Intensity_MedianIntensity_NeurDensity])
	d.Experiment = repeat(["Exp1", "Exp2"], 6)

	e1 = Experiment(d)

	# Filter data
	d1 = "Select only a single experiment"
	f1 = Filter("Exp1", :Experiment, description = d1)
	s1 = Selector(x -> eltype(x) <: Number,
	              description = "Keep numerical features")

	filter!(e1,[f1,s1])

	# Test `getdata`
	@test length(e1.selected_features) == 2
	@test length(e1.selected_entries) == 6
	@test getdata(e1) == e1.data[e1.selected_entries, e1.selected_features]

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
	filter!(e4,[f1,s1])
	decorrelate!(e4)
	# First column always kept, inverse column removed
	@test 1 in e4.selected_features
	@test !(4 in e4.selected_features)

	e4 = Experiment(d)
	filter!(e4,[f1,s1])
	decorrelate!(e4, threshold = 1)
	# Not perfectly correlated by design
	@test 5 in e4.selected_features

	e4 = Experiment(d)
	filter!(e4,[f1,s1])
	decorrelate!(e4, ordercol = [4,3,2,1])
	# Reversed order: first column always kept, inverse column removed
	@test 5 in e4.selected_features
	if cor(e4.data[e4.selected_entries, :Ft4], 
		   e4.data[e4.selected_entries, :Ft3]) < 0.8
		@test 4 in e4.selected_features
	else
		@test !(4 in e4.selected_features)
	end

	@test !(1 in e4.selected_features)

	# Test sorting by mad
	e5 = Experiment(DataFrame([[0,2,4,6,8],[0,1,2,3,4],[0,3,6,9,12]]))
	decorrelate_by_mad!(e5)
	@test e5.selected_features == [3]

	# Test type issues
	d.Ft4 = [collect(1:9)..., missing, Inf, NaN]
	e5 = Experiment(d)

	# Includes String column
	@test_throws AssertionError decorrelate!(e5)

	filter!(e5,[f1,s1])
	decorrelate!(e5) # This should now work
	append!(e5.selected_features, 5)

	# Includes Inf values
	@test_throws AssertionError decorrelate!(e5)

	e5.data[11,5] = 3
	e6 = deepcopy(e5)
	decorrelate!(e6) # This should now work
	append!(e5.selected_entries, 10)

	# Includes Missing values
	@test_throws AssertionError decorrelate!(e5)

	e5.data[10,5] = 3
	e6 = deepcopy(e5)
	decorrelate!(e6) # This should now work
	append!(e5.selected_entries, 12)

	# Includes NaN values
	@test_throws AssertionError decorrelate!(e5)

	e5.data[12,5] = 3
	decorrelate!(e5) # This should now work

	# Test handling of non-float variables
	d.Ft2 = rand(1:4, size(d,1))
	e5 = Experiment(d)

	thr = sort(getdata(e5).Intensity_MedianIntensity_NeurDensity)[end-2]
	f3 = Filter(thr, :Intensity_MedianIntensity_NeurDensity, 
	       compare = >=, description = "Top 3 values")

	@test_throws AssertionError logtransform!(e5)
	@test_throws AssertionError normtransform!(e5,f3)

	filter!(e5,[s1])

	e6 = deepcopy(e5)
	logtransform!(e5)
	normtransform!(e6,f3)

	@test eltype(getdata(e5).Ft2) == Float64
	@test eltype(getdata(e6).Ft2) == Float64
end

@testset "umap" begin
    # Create dataset with 4 random and 1 index column
    d = DataFrame(rand(40,4))
	rename!(d, Symbol.("Ft" .* string.(1:4)))
	d.Ft5 = 1:40;
	e = Experiment(d)

	# Set filters
	f = Filter(10, :Ft5, compare = >)
	s = negation(NameSelector(x -> occursin("Ft3", string(x))))
	filter!(e,[f,s])

	# Test dimensions and arguments
	@test size(umap(e)) == (2, 30)
	@test size(umap(e, 3, n_neighbors = 10, min_dist = 1, n_epochs = 10)) == (3, 30)
	@test_throws ArgumentError size(umap(e, 4))
end

@testset "biaseddistances" begin
	Random.seed!(777)

	# We want significantly more points than dimensions or the covariance
	# matrix can be singular and the results would not make any sense
	d = rand(100,5)
	@test distance_mahalanobis_center(d, 1:50, 1:50) + 1 ≈ 1
	
	d = hcat(d, (1:100)./50)
	# If some points are share with reference, the distance should be
	# smaller than to a set of completely different points
	dist1 = distance_mahalanobis_center(d, 51:100, 1:50)
	dist2 = distance_mahalanobis_center(d, 25:74, 1:50)
	@test dist1 > 0
	@test dist2 > 0
	@test dist1 > dist2
	
	dist0 = distance_mahalanobis_median(d, 1:50, 1:50)
	dist1 = distance_mahalanobis_median(d, 25:74, 1:50)
	dist2 = distance_mahalanobis_median(d, 51:100, 1:50)
	@test 0 < dist0 < dist1 < dist2

	# Testing permutation tests:
	# If both ref and pert are sampled from the same distribution,
	# p-value must be high.
	# If ref and pert are sampled from non-overlapping distributions,
	# p-value must be 0.
	d = rand(100,5)
	params = (d, 51:100, 1:50)
	@test 0 < mean(shuffled_distance_mahalanobis_center(params...) .< 
	               distance_mahalanobis_center(params...)) < 1
	@test 0 < mean(shuffled_distance_mahalanobis_median(params...) .< 
	               distance_mahalanobis_median(params...)) < 1

	d[51:100, :] .+= 2
	@test mean(shuffled_distance_mahalanobis_center(params...) .< 
	           distance_mahalanobis_center(params...)) == 1
	@test mean(shuffled_distance_mahalanobis_median(params...) .< 
	           distance_mahalanobis_median(params...)) == 1
end

@testset "robustdistances" begin
	Random.seed!(777)

	# First, RCall must be running correctly
	@test_throws RCall.REvalError R"""
	library(NotALibrary)
	"""

	# Robustbase must be installed
	R"""
	if (!require("robustbase")) install.packages("robustbase", 
												  repos = "https://cloud.r-project.org")
	library(robustbase)
	"""
	d = rand(100,5)
	@test distance_robust_hellinger(d, 1:50, 1:50) + 1 ≈ 1
	
	d = hcat(d, (1:100)./50)
	# If some points are share with reference, the distance should be
	# smaller than to a set of completely different points
	dist0 = distance_robust_mahalanobis_median(d, 1:50, 1:50)
	dist1 = distance_robust_mahalanobis_median(d, 25:74, 1:50)
	dist2 = distance_robust_mahalanobis_median(d, 51:100, 1:50)
	@test 0 < dist0 < dist1 < dist2

	dist0 = distance_robust_hellinger(d, 1:50, 1:50)
	dist1 = distance_robust_hellinger(d, 25:74, 1:50)
	dist2 = distance_robust_hellinger(d, 51:100, 1:50)
	@test dist0 < dist1 < dist2	

	# Testing permutation tests:
	# If both ref and pert are sampled from the same distribution,
	# p-value must be high.
	# If ref and pert are sampled from non-overlapping distributions,
	# p-value must be 0.
	d = rand(100,5)
	params = (d, 51:100, 1:50)
	@test 0 < mean(shuffled_distance_robust_mahalanobis_median(params...) .< 
	               distance_robust_mahalanobis_median(params...)) < 1
	@test 0 < mean(shuffled_distance_robust_hellinger(params...) .< 
	               distance_robust_hellinger(params...)) < 1

	d[51:100, :] .+= 1
	@test mean(shuffled_distance_robust_mahalanobis_median(params...) .<=
	           distance_robust_mahalanobis_median(params...)) > 0.9
	@test mean(shuffled_distance_robust_hellinger(params...) .<= 
	           distance_robust_hellinger(params...)) > 0.9
end

@testset "robust_morphological_perturbation_value" begin
	Random.seed!(777)

	d = DataFrame(rand(250,5))
	d.Condition = sample('A':'D', 250);

	# Make one condition stand out
	d[d.Condition .== 'D',1:5] .+= 1;

	e = Experiment(d)

	# Select numerical columns
	slt = NameSelector(x -> x != "Condition")
	select_features!(e, slt)
	# Filter out some rows
	# Useful to check that the RMPV computation correctly works on subset of the data
	row_filter = Filter(0.9, :x1, compare = (x,y) -> round(x, digits = 1) != y)
	filter_entries!(e, row_filter)

	# Define reference condition
	f = Filter('C', :Condition)

	@test_throws DomainError robust_morphological_perturbation_value(e, 
																     :Condition, 
																     f,
																     dist = :IncorrectValue)

	rmpv = robust_morphological_perturbation_value(e, :Condition, f)

	# 4 conditions, 3 columns
	@test size(rmpv) == (4,3)

	# Distance of control to itself == 0
	@test rmpv[rmpv.Condition .== 'C', :Distance][1] + 1 ≈ 1

	# Shifted distribution should be the most different
	@test maximum(rmpv.Distance) == rmpv.Distance[rmpv.Condition .== 'D'][1]

	# A, B and C have the same distribution but D has a different one
	@test rmpv.RMPV[rmpv.Condition .== 'C'][1] > 0.1
	@test rmpv.RMPV[rmpv.Condition .== 'D'][1] < 0.1

	rmpv2 = robust_morphological_perturbation_value(e, 
													:Condition, 
													'C', 
													nb_rep = 50, 
													dist = :RobMedMahalanobis)

	# A, B and C have the same distribution but D has a different one
	@test rmpv2.RMPV[rmpv2.Condition .== 'C'][1] > 0.1
	@test rmpv2.RMPV[rmpv2.Condition .== 'D'][1] < 0.1

	rmpv3 = robust_morphological_perturbation_value(e, 
													:Condition, 
													'C', 
													nb_rep = 50, 
													dist = :MedMahalanobis)

	# A, B and C have the same distribution but D has a different one
	@test rmpv3.RMPV[rmpv3.Condition .== 'C'][1] > 0.1
	@test rmpv3.RMPV[rmpv3.Condition .== 'D'][1] < 0.1

	rmpv4 = robust_morphological_perturbation_value(e, 
													:Condition, 
													'C', 
													nb_rep = 50, 
													dist = :CenterMahalanobis)

	# A, B and C have the same distribution but D has a different one
	@test rmpv4.RMPV[rmpv4.Condition .== 'C'][1] > 0.1
	@test rmpv4.RMPV[rmpv4.Condition .== 'D'][1] < 0.1

	# Test reproducibility
    Random.seed!(777)
    rmpv_run1 = robust_morphological_perturbation_value(e, 
                                                        :Condition, 
                                                        'C', 
                                                        nb_rep = 4, 
                                                        dist = :RobMedMahalanobis)
    Random.seed!(777)
    rmpv_run2 = robust_morphological_perturbation_value(e, 
                                                        :Condition, 
                                                        'C', 
                                                        nb_rep = 4, 
                                                        dist = :RobMedMahalanobis)
    Random.seed!(777)
    rmpv_run3 = robust_morphological_perturbation_value(e, 
                                                    :Condition, 
                                                    'C', 
                                                    nb_rep = 4, 
                                                    dist = :RobMedMahalanobis,
                                                    r_seed = false)
    @test rmpv_run1 == rmpv_run2
    # NB: without changing the seeds, it is possible that
    # the MCD converges so the following is a bad test:
    # @test rmpv_run1 != rmpv_run3

    Random.seed!(777)
    rmpv_run1 = robust_morphological_perturbation_value(e, 
                                                        :Condition, 
                                                        'C', 
                                                        nb_rep = 4, 
                                                        dist = :RobHellinger)
    Random.seed!(777)
    rmpv_run2 = robust_morphological_perturbation_value(e, 
                                                        :Condition, 
                                                        'C', 
                                                        nb_rep = 4, 
                                                        dist = :RobHellinger)
    Random.seed!(777)
    rmpv_run3 = robust_morphological_perturbation_value(e, 
                                                    :Condition, 
                                                    'C', 
                                                    nb_rep = 4, 
                                                    dist = :RobHellinger,
                                                    r_seed = false)
    @test rmpv_run1 == rmpv_run2
    @test rmpv_run1 != rmpv_run3
end

@testset "parallel_rmpv" begin
	d = DataFrame(rand(100,5))
	d.Condition = sample('A':'D', 100);

	e = Experiment(d)

    addprocs(4)
    pool = CachingPool(workers())
    @everywhere using BioProfiling


	slt = NameSelector(x -> x != "Condition")
	select_features!(e, slt)
	f = Filter('C', :Condition)

	rmpv = robust_morphological_perturbation_value(e, 
												   :Condition, 
												   f,
												   process_pool = pool)

	# 4 conditions, 3 columns
	@test size(rmpv) == (4,3)
end
