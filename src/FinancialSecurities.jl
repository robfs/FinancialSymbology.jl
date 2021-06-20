module FinancialSecurities

using Base: Symbol
include("OpenFigiApi.jl")

using ..FinancialSymbols, ..SymbolTests, .OpenFigiApi

export FinancialSecurity, Equity

const MaybeString = Union{String, Missing}

abstract type FinancialSecurity end

Base.show(io::IO, x::FinancialSecurity) = print(io, "$(typeof(x)): $(x.id)")
Base.show(io::IO, ::MIME"text/plain", x::FinancialSecurity) = print(io, "$(typeof(x)): $(x.id)")

mutable struct Equity <: FinancialSecurity
    id::FinancialSymbol
    figi::MaybeString
    name::MaybeString
    ticker::MaybeString
    exchCode::MaybeString
    compositeFIGI::MaybeString
    securityType::MaybeString
    marketSector::MaybeString
    shareClassFIGI::MaybeString
    securityType2::MaybeString
    securityDescription::MaybeString
    bloombergTicker::MaybeString

    Equity(;id::FinancialSymbol,
           figi::MaybeString=missing,
           name::MaybeString=missing,
           ticker::MaybeString=missing,
           exchCode::MaybeString=missing,
           compositeFIGI::MaybeString=missing,
           securityType::MaybeString=missing,
           marketSector::MaybeString=missing,
           shareClassFIGI::MaybeString=missing,
           securityType2::MaybeString=missing,
           securityDescription::MaybeString=missing
           ) = new(id, figi, name, ticker, exchCode, compositeFIGI, securityType,
                   marketSector, shareClassFIGI, securityType2, securityDescription, "$(ticker) $(exchCode) $(marketSector)")
end

function makejob(id::FinancialSymbol, idtype::String, securitytype::String)::Dict{String,String}
    return Dict("marketSecDes"=>securitytype, "idValue"=>id, "idType"=>idtype)
end

function makejob(id::Ticker, securitytype::String="")::Dict{String, String}
    (ticker, exchcode, securitytype) = split(id.x, ' ')
    return Dict("idType"=>"TICKER", "idValue"=>ticker, "exchCode"=>exchcode, "marketSecDes"=>securitytype)
end

makejob(id::Sedol, securitytype::String)::Dict{String, String} = makejob(id, "ID_SEDOL", securitytype)
makejob(id::Cusip, securitytype::String)::Dict{String, String} = makejob(id, "ID_CUSIP", securitytype)
makejob(id::Isin, securitytype::String)::Dict{String, String} = makejob(id, "ID_ISIN", securitytype)
makejob(id::Figi, securitytype::String)::Dict{String, String} = makejob(id, "ID_BB_GLOBAL", securitytype)

makeargsdict(d::Dict{String,Any})::Dict{Symbol,String} = Dict(Symbol(k)=>v for (k, v) in d)

Equity(id::String) = Equity(;id=Ticker(id), ((Ticker(id) |> makejob |> fetchsecuritydata)["data"][1] |> makeargsdict)...)

end # module