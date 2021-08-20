module FinancialSymbology

using HTTP, StructArrays

const APIKEYNAME = "X-OPENFIGI-APIKEY"

include("types.jl")
include("utils.jl")

export Identifier, Sedol, Cusip, Isin, Figi, Ticker, Index
export OpenFigiAPI
export makesymbol
export fetchsecuritydata

"""
    makesymbol(x::String)

Automatically detect `Identifier` and create type.

See also: [`fetchsecuritydata`](@ref)

# Examples
```jldoctest makesymboldoc
julia> using FinancialSymbology

julia> ids = makesymbol.(["AAPL US Equity", "BDDXSM4"])
2-element Vector{Identifier}:
 "AAPL US Equity"
 "BDDXSM4"
```
"""
function makesymbol(x::AbstractString)::Identifier
    return symboltype(x)(x)
end

"""
    fetchsecuritydata(id::Identifier, api=OpenFigiAPI()) 
    fetchsecuritydata(ids::Vector{Identifier}, api=OpenFigiAPI())

Fetch Identifier data from API.

Do not broadcast this function over a vector of identifiers. 
Pass the vector as the `ids` argument.

See also: [`makesymbol`](@ref)

# Examples
```jldoctest
julia> using FinancialSymbology

julia> fetchsecuritydata([Ticker("AAPL US Equity"), Sedol("BDDXSM4")])
Dict{String, StructArrays.StructArray} with 2 entries:
  "AAPL US Equity" => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "BDDXSM4"        => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
```
"""
function fetchsecuritydata(ids::Vector{<:Identifier}, api::OpenFigiAPI=OpenFigiAPI())::Dict{String, StructArray}
    responses = request(ids, api)
    return extractdata(ids, responses)
end

function fetchsecuritydata(id::Identifier, api::OpenFigiAPI=OpenFigiAPI())::Dict{String, StructArray}
    return fetchsecuritydata([id], api)
end


end # module
