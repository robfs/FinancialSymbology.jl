module FinancialSymbology

using HTTP, StructArrays

const APIKEYNAME = "X-OPENFIGI-APIKEY"

include("identifiertypes.jl")
include("apitypes.jl")
include("apiconstructors.jl")
include("prettyprinters.jl")

export Identifier, Sedol, Cusip, Isin, Figi, Ticker, Index
export OpenFigiAPI
export makeidentifier
export fetchsecuritydata

"""
    makeidentifier(x::String)

Automatically detect `Identifier` and create type.

See also: [`fetchsecuritydata`](@ref)

# Example
```jldoctest; setup = :(using FinancialSymbology)
julia> ids = makeidentifier.(["AAPL US Equity", "BDDXSM4"])
2-element Vector{Identifier}:
 "AAPL US Equity"
 "BDDXSM4"
```
"""
function makeidentifier(x::AbstractString)::Identifier
    return identifiertype(x)(x)
end

"""
    fetchsecuritydata(id::Identifier, api=OpenFigiAPI()) 
    fetchsecuritydata(ids::Vector{Identifier}, api=OpenFigiAPI())

Fetch Identifier data from API.

Do not broadcast this function over a vector of identifiers. 
Pass the vector as the `ids` argument. Returns a `Dict` with `Identifier` strings as keys.

See also: [`makeidentifier`](@ref), [`OpenFigiAPI`](@ref), [`OpenFigiAsset`](@ref)

# Example
```jldoctest; setup = :(using FinancialSymbology)
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

function fetchsecuritydata(id::Identifier, api::OpenFigiAPI=OpenFigiAPI())::StructArray
    data = fetchsecuritydata([id], api)
    return data[id]
end


end # module
