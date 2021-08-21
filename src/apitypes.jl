abstract type API end

mutable struct OpenFigiAPI <: API
    protocol::AbstractString
    base::AbstractString
    version::AbstractString
    path::AbstractString
    headers::Vector{Pair{AbstractString, AbstractString}}
end

mutable struct OpenFigiAsset
    figi::Union{String, Nothing}
    marketSector::Union{String, Nothing}
    securityType::Union{String, Nothing}
    ticker::Union{String, Nothing}
    name::Union{String, Nothing}
    exchCode::Union{String, Nothing}
    securityDescription::Union{String, Nothing}
    securityType2::Union{String, Nothing}
    compositeFIGI::Union{String, Nothing}
    shareClassFIGI::Union{String, Nothing}
end


"""
    OpenFigiAPI(protocol::AbstractString="https",
                base::AbstractString="api.openfigi.com",
                version::AbstractString="v3",
                path::AbstractString="mapping";
                headers::Vector{Pair{String, String}}=["Content-Type"=>"application/json"],
                apikey::String="")::OpenFigiAPI

Create OpenFigiAPI.

See also: [`fetchsecuritydata`](@ref)

# Example
```jldoctest; setup = :(using FinancialSymbology)
julia> OpenFigiAPI()
OpenFigiAPI: https://api.openfigi.com/v3/mapping
```
"""
function OpenFigiAPI(protocol::AbstractString="https",
                     base::AbstractString="api.openfigi.com",
                     version::AbstractString="v3",
                     path::AbstractString="mapping";
                     headers::Vector{Pair{String, String}}=["Content-Type"=>"application/json"],
                     apikey::String="")::OpenFigiAPI
    
    apikey::String = haskey(ENV, APIKEYNAME) && length(apikey) == 0 ? ENV[APIKEYNAME] : apikey
    push!(headers, APIKEYNAME=>apikey)
    
    return OpenFigiAPI(protocol, base, version, path, headers)

end


"""
    OpenFigiAsset(;figi::Union{String, Nothing}=nothing,
                  marketSector::Union{String, Nothing}=nothing,
                  securityType::Union{String, Nothing}=nothing,
                  ticker::Union{String, Nothing}=nothing,
                  name::Union{String, Nothing}=nothing,
                  exchCode::Union{String, Nothing}=nothing,
                  securityDescription::Union{String, Nothing}=nothing,
                  securityType2::Union{String, Nothing}=nothing,
                  compositeFIGI::Union{String, Nothing}=nothing,
                  shareClassFIGI::Union{String, Nothing}=nothing)::OpenFigiAsset

Each element of the `StructArray` returned by [`fetchsecuritydata`](@ref) for an
individual `Identifier` is an `OpenFigiAsset`. 

# Example
```jldoctest; setup = :(using FinancialSymbology)
julia> aapl = fetchsecuritydata(Ticker("AAPL US Equity"));

julia> aapl[1]
FIGI: BBG000B9XRY4 Common Stock

julia> aapl[1].shareClassFIGI
"BBG001S5N8V8"
```
"""
function OpenFigiAsset(;
    figi::Union{String, Nothing}=nothing,
    marketSector::Union{String, Nothing}=nothing,
    securityType::Union{String, Nothing}=nothing,
    ticker::Union{String, Nothing}=nothing,
    name::Union{String, Nothing}=nothing,
    exchCode::Union{String, Nothing}=nothing,
    securityDescription::Union{String, Nothing}=nothing,
    securityType2::Union{String, Nothing}=nothing,
    compositeFIGI::Union{String, Nothing}=nothing,
    shareClassFIGI::Union{String, Nothing}=nothing
)
    return OpenFigiAsset(
        figi, marketSector, securityType, ticker, name, exchCode,
        securityDescription, securityType2, compositeFIGI, shareClassFIGI
    )
end

keystosymbols(d::Dict{String, T} where T)::Dict{Symbol, T} where T = Dict([Symbol(k)=>v for (k, v) in d])

function OpenFigiAsset(d::Dict{String, Any})
    return OpenFigiAsset(; keystosymbols(d)...)
end
