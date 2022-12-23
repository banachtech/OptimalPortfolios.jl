module OptimalPortfolios

using JuMP, Ipopt, LinearAlgebra, Statistics

export denoisecov, allocate

function marcenko_pastur(λ,σ,q)
    σ2 = σ * σ
    qs = sqrt(q)
    λmax = σ2 * (1.0 + qs) * (1.0 + qs)
    λmin = σ2 * (1.0 - qs) * (1.0 - qs)
    if λ <= λmin || λ >= λmax
        return 0.0
    else
        return sqrt((λmax-λ) * (λ-λmin))/(2.0*π*q*σ2*λ)
    end
end

function fit(l,q)
    model = Model(Ipopt.Optimizer)
    lik(p) = sum([marcenko_pastur(u,exp(p),q) for u in l])
    register(model, :lik, 1, lik; autodiff=true)
    @variable(model, x)
    @NLobjective(model, Max, lik(x))
    set_silent(model)
    optimize!(model)
    return exp(value(x))
end

"""
    denoisecov(Σ, q)

Denoise covariance matrix. q is the ratio of number of variables to number of samples.
"""
function denoisecov(Σ, q)
    v = diag(Σ)
    D = diagm(1 ./ sqrt.(v))
    C = D*Σ*D
    C .= 0.5 * (C .+ C')
    F = eigen(C)
    λ = max.(F.values, 0.0)
    σ = fit(λ,0.5)
    λmax = σ * σ * (1 + sqrt(q))^2
    λ[λ .<= λmax] .= mean(λ[λ .<= λmax])
    C1 = F.vectors * diagm(λ) * F.vectors'
    Σ1 = diagm(sqrt.(v)) * C1 * diagm(sqrt.(v))
    Σ1 .= 0.5 * (Σ1 .+ Σ1)
    return Σ1
end

function solve(Σ, μ, lower, upper; rf = 0.0, fullinvest = true)
    N = size(Σ,1)    
    model = Model(Ipopt.Optimizer)
    i = ones(N)
    minlev, maxlev = 1.0, 1.0
    if !fullinvest
        minlev = 0.0
    end
    @variable(model, upper[i] >= x[i=1:N] >= lower[i])
    @constraint(model, minlev .<= x'*i .<= maxlev)
    @NLobjective(model, Max, (sum(x[i]*μ[i] for i in 1:N) - rf) / sqrt(sum(x[i]*x[j]*Σ[i,j] 
                for i in 1:N for j in 1:N)))
    set_silent(model)
    optimize!(model)
    w = value.(x)
    w .= w ./ sum(w)
    return round.(w, digits=4)
end

function solve(Σ, lower, upper; fullinvest = true)
    N = size(Σ,1)    
    model = Model(Ipopt.Optimizer)
    i = ones(N)
    minlev, maxlev = 1.0, 1.0
    if !fullinvest
        minlev = 0.0
    end
    @variable(model, upper[i] >= x[i=1:N] >= lower[i])
    @constraint(model, minlev .<= x'*i .<= maxlev)
    @NLobjective(model, Min, sum(x[i]*x[j]*Σ[i,j] for i in 1:N for j in 1:N))
    set_silent(model)
    optimize!(model)
    w = value.(x)
    w .= w ./ sum(w)
    return round.(w, digits=4)
end

"""
    allocate(X, lower, upper; rf = 0.0, denoise = false, fullinvest = true, 
method = "MSR")

Compute optimal % allocations according to given method.

# Arguments
- `X::Matrix{Float64}`: N x T returns matrix, where N is the number of assets and T is the number of samples.
- `lower::Union{Float64, Vector{Float64}}`: lower bound on allocations in %; if specified as a scalar, then the same value is applied to all assets.
- `upper::Union{Float64, Vector{Float64}}`: upper bound on allocations in %; if specified as a scalar, then the same value is applied to all assets.
- `rf::Float64=0.0`: risk-free rate; applicable only for MSR method.
- `denoise::Bool=False`: If true, sample covariance matrix will be de-noised by flooring the eigen values at λmax estimated from Marcenko-Pastur distribution.
- `fullinvest::Bool=True`: If true, allocations will sum to 1.

Returns a vector of % allocations.

"""
function allocate(X, lower, upper; rf = 0.0, denoise = false, fullinvest = true, 
    method = "MSR")
    T, N = size(X)
    w = ones(N)/N
    Σ = cov(X)
    Σ .= 0.5 * (Σ .+ Σ')
    if denoise
        q = N/T
        Σ .= denoisecov(Σ, q)
    end
    if !isa(lower, Vector)
        lower = lower * ones(N)
    end
    if !isa(upper, Vector)
        upper = upper * ones(N)
    end
    if method == "MSR"
        μ = vec(mean(X, dims=1))
        w .= solve(Σ, μ, lower, upper, rf = rf, fullinvest = fullinvest)
    elseif method == "MV"
        w .= solve(Σ, lower, upper, fullinvest = fullinvest)
    else
        @warn "Unknown method. Only MSR and MV are supported."
        return nothing
    end
    return w
end

end # module OptimalPortfolios
