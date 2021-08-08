using Documenter

using Pkg
Pkg.activate("..")

using FinancialSymbology

makedocs(
    sitename = "FinancialSymbology",
    format = Documenter.HTML(),
    modules = [FinancialSymbology,
               FinancialSymbology.Identifiers,
               FinancialSymbology.OpenFigi],
    doctest = true
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
