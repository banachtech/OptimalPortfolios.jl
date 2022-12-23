using Documenter
using OptimalPortfolios

makedocs(
    sitename = "OptimalPortfolios Documentation",
    pages = [
        "Index" => "index.md",
    ],
    format = Documenter.HTML(),
    modules = [OptimalPortfolios]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/banachtech/OptimalPortfolios.jl.git",
    devbranch = "main"
)
