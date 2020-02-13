using RMP
using Test
using DataFrames
using LinearAlgebra: I

@testset "mahalanobis" begin
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

@testset "logtransform" begin
    @test logtransform(1) == 0
    @test_throws MethodError logtransform("str")
    @test round.(logtransform(1:5), digits=2) == [0.0, 0.69, 1.1, 1.39, 1.61]
end

@testset "normtransform" begin
    x = 1:5
	@test round.(normtransform(x,x), digits = 2) == [-1.35, -0.67, 0.0, 0.67, 1.35]
    @test round.(normtransform(x,x[1:3]), digits = 2)  == [-0.67, 0.0, 0.67, 1.35, 2.02]
    @test_throws MethodError normtransform("str",x)
    @test_throws MethodError normtransform(x,"str")
end

@testset "decorrelate" begin
    X = DataFrame([[1,2,3],[3,2,1],[0,1,2],[1,0,1]])
    @test decorrelate(X) == [1,4]
    @test decorrelate(X, orderCol = [3,1,2]) == [3]
end