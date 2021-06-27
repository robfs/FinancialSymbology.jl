module FinancialSymbology

include("Symbols/Identifiers.jl")
include("Symbols/IdChecks.jl")
include("APIs/APIs.jl")
include("APIs/OpenFigi.jl")

using .Identifiers, .IdChecks, .APIs, .OpenFigi

export Identifier, Sedol, Cusip, Isin, Figi, Ticker, Index
export makesymbol
export OpenFigiAPI
export fetchsecuritydata

end # module
