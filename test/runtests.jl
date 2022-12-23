using Test, OptimalPortfolios

N, M = 10, 100
X = 0.1*randn(N,M)

w = allocate(X,0.0,0.5)
@test length(w) == N
@test isapprox(sum(w), 1.0; atol=0.01)

w = allocate(X,0.0,0.5,denoise=true)
@test length(w) == N
@test isapprox(sum(w), 1.0; atol=0.01)

w = allocate(X,0.0,0.5,denoise=true, method="MV")
@test length(w) == N
@test isapprox(sum(w), 1.0; atol=0.01)

w = allocate(X,0.0,0.5,fullinvest=false)
@test length(w) == N
@test sum(w) <= 1.0 && sum(w) >= 0.0