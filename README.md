# OptimalPortfolios.jl

[![Build status (Github Actions)](https://github.com/banachtech/OptimalPortfolios.jl/workflows/CI/badge.svg)](https://github.com/OptimalPortfolios/MyAwesomePackage.jl/actions)
[![codecov.io](http://codecov.io/github/banachtech/OptimalPortfolios.jl/coverage.svg?branch=main)](http://codecov.io/github/banachtech/OptimalPortfolios.jl?branch=main)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://banachtech.github.io/OptimalPortfolios.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://banachtech.github.io/OptimalPortfolios.jl/dev)

OptimalPortfolios.jl is a light-weight package for portfolio optimization. It essentially wraps julia optimization package [JuMP](https://jump.dev/JuMP.jl/stable/).

It supports maximizing Sharpe ratio and minimizing variance under linear constraints i.e. bounds on weights and net leverage.

