using RMP
using Test
using DataFrames

@testset "RMP.jl" begin
    # Write your own tests here.
end

@testset "transfLog" begin
    @test transfLog(1) == 0
    @test_throws MethodError transfLog("str")
    @test round.(transfLog(1:5), digits=2) == [0.0, 0.69, 1.1, 1.39, 1.61]
end

@testset "transfNorm" begin
    x = 1:5
	@test round.(transfNorm(x,x), digits = 2) == [-1.35, -0.67, 0.0, 0.67, 1.35]
    @test round.(transfNorm(x,x[1:3]), digits = 2)  == [-0.67, 0.0, 0.67, 1.35, 2.02]
    @test_throws MethodError transfNorm("str",x)
    @test_throws MethodError transfNorm(x,"str")
end

@testset "decorrelate" begin
    X = DataFrame([[1,2,3],[3,2,1],[0,1,2],[1,0,1]])
    @test decorrelate(X) == [1,4]
    @test decorrelate(X, orderCol = [3,1,2]) == [3]
end