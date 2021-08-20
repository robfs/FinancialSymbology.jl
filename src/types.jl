abstract type Identifier <: AbstractString end
abstract type API end


struct Sedol <: Identifier
    s::AbstractString
end

struct Cusip <: Identifier
    s::AbstractString
end

struct Isin <: Identifier
    s::AbstractString
end

struct Figi <: Identifier
    s::AbstractString
end

struct Ticker <: Identifier
    s::AbstractString
    Ticker(s::AbstractString) = new(join(split(s), ' '))
end

struct Index <: Identifier
    s::AbstractString
end


Sedol(s::Identifier)= Sedol(s.s)
Sedol(s::Sedol) = s
Sedol(s::Missing) = missing

Cusip(s::Identifier) = Cusip(s.s)
Cusip(s::Cusip) = s
Cusip(s::Missing) = missing

Isin(s::Identifier)= Isin(s.s)
Isin(s::Isin) = s
Isin(s::Missing) = missing

Figi(s::Identifier) = Figi(s.s)
Figi(s::Figi) = s
Figi(s::Missing) = missing

Ticker(s::Identifier) = Ticker(s.s)
Ticker(s::Ticker) = s
Ticker(s::Missing) = missing

Index(s::Identifier) = Index(s.s)
Index(s::Ticker) = s
Index(s::Missing) = missing


mutable struct OpenFigiAPI <: API
    protocol::AbstractString
    base::AbstractString
    version::AbstractString
    path::AbstractString
    headers::Vector{Pair{AbstractString, AbstractString}}
end

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

function OpenFigiAsset(d::Dict{String, Any})
    return OpenFigiAsset(; keystosymbols(d)...)
end

Base.show(io::IO, api::API) = print(io, "$(typeof(api)): $(makeurl(api))")

Base.show(io::IO, x::OpenFigiAsset) = print(io, typeof(x), "\n", join(["$(rpad(fld, 22, " ")) => $(getfield(x,fld))" for fld in fieldnames(typeof(x))], "\n"))
Base.show(io::IO, ::MIME"text/plain", x::OpenFigiAsset) = print(io, "FIGI: $(x.figi) $(x.securityType2)")


Base.firstindex(s::Identifier) = firstindex(s.s)
Base.lastindex(s::Identifier) = lastindex(s.s)
Base.iterate(s::Identifier, i::Int) = iterate(s.s, i)
Base.iterate(s::Identifier) = iterate(s.s)
Base.nextind(s::Identifier, i::Int) = nextind(s.s, i)
Base.prevind(s::Identifier, i::Int) = prevind(s.s, i)
Base.eachindex(s::Identifier) = eachindex(s.s)
Base.length(s::Identifier) = length(s.s)
Base.getindex(s::Identifier, i::Integer) = getindex(s.s, i)
Base.getindex(s::Identifier, i::Int) = getindex(s.s, i) # for method ambig in Julia 0.6
Base.getindex(s::Identifier, i::UnitRange{Int}) = getindex(s.s, i)
Base.getindex(s::Identifier, i::UnitRange{<:Integer}) = getindex(s.s, i)
Base.getindex(s::Identifier, i::AbstractVector{<:Integer}) = getindex(s.s, i)
Base.codeunit(s::Identifier, i::Integer) = codeunit(s.s, i)
Base.codeunit(s::Identifier) = codeunit(s.s)
Base.ncodeunits(s::Identifier) = ncodeunits(s.s)
Base.codeunits(s::Identifier) = codeunits(s.s)
Base.sizeof(s::Identifier) = sizeof(s.s)
Base.isvalid(s::Identifier, i::Integer) = isvalid(s.s, i)
Base.pointer(s::Identifier) = pointer(s.s)
Base.IOBuffer(s::Identifier) = IOBuffer(s.s)
Base.unsafe_convert(T::Union{Type{Ptr{UInt8}},Type{Ptr{Int8}},Cstring}, s::Identifier) = Base.unsafe_convert(T, s.s)