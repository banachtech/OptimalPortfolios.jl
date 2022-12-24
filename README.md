# OptimalPortfolios.jl

OptimalPortfolios.jl is a light-weight package for portfolio optimization. It essentially wraps julia optimization package [JuMP](https://jump.dev/JuMP.jl/stable/).

## Portfolio Problem

$$\text{max}_w \; \mathrm{J}(w)$$

s.t.

$$l \leq w \leq u$$ 

and

$$0 \leq w^T\mathbb{1} \leq 1,$$

where $w$ is the vector of % weights and the objective function $\mathrm{J}(w) = \frac{\mu^Tw - r_f}{\sqrt{w^T\Sigma w}}$ for maximum Sharpe ratio (MSR) portfolio and $\mathrm{J}(w) = w^T\Sigma w$ for minimum variance (MV) portfolio.


Covariance matrix of returns $\Sigma$ and vector of mean returns $\mu$ are estimated from historical returns data. Estimation of $\mu$ is notoriously unreliable and for that reason MV is often preferred over MSR. There are several methods available for robust estimation of $\Sigma$ and this package offers a denoising option based on random matrix theory (Marcenko-Pastur). 

## Usage

Execute below on Julia REPL to install the package.

```julia
julia> import Pkg

julia> Pkg.add("OptimalPortfolios")
```

Import the package with

```julia
julia> using OptimalPortfolios
```

Compute maximum Sharpe ratio portfolio with

```julia
julia> allocate(X, lower, upper; rf = 0, fullinvest = true, denoise = true, method = "MSR")
```

X is the $N \times T$ matrix of returns. N is the number of assets and T the is the number of samples. lower and upper are the bounds on weights. 

Compute minimum variance portfolio with

```julia
julia> allocate(X, lower, upper; fullinvest = true, denoise = true, method = "MV")
```

Backtest optimal portfolio allocations. -obs_ is the size of historical returns window used to compute optimal portfolio and _hold_ is the holding or rebalance period. Transaction costs are assumed to be zero. P is the $N \times T$ matrix of prices.

```julia
julia> res = backtest(px, obs, hold, lower, upper; rf = 0.0, fullinvest=true, 
denoise=true, method = "MSR")
julia> plot(res.nav)
julia> println(res.wt)
```
