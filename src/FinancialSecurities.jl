module FinancialSecurities

using Base: Symbol
using StructArrays

include("OpenFigiApi.jl")

using ..FinancialSymbols, ..SymbolTests, .OpenFigiApi

export FinancialSecurity, Equity

const MaybeString = Union{String, Missing}

abstract type FinancialSecurity end

function makejob(id::FinancialSymbol, idtype::String, securitytype::String)::Dict{String,String}
    return Dict("marketSecDes"=>securitytype, "idValue"=>id.x, "idType"=>idtype)
end

function makejob(id::Ticker, securitytype::String="")::Dict{String, String}
    (ticker, exchcode, securitytype) = split(id.x, ' ')
    return Dict("idType"=>"TICKER", "idValue"=>ticker, "exchCode"=>exchcode, "marketSecDes"=>securitytype)
end

makejob(id::Sedol, securitytype::String)::Dict{String, String} = makejob(id, "ID_SEDOL", securitytype)
makejob(id::Cusip, securitytype::String)::Dict{String, String} = makejob(id, "ID_CUSIP", securitytype)
makejob(id::Isin, securitytype::String)::Dict{String, String} = makejob(id, "ID_ISIN", securitytype)
makejob(id::Figi, securitytype::String)::Dict{String, String} = makejob(id, "ID_BB_GLOBAL", securitytype)

makesymbolkeys(d::Dict{String,<:Any})::Dict{Symbol,<:Any} = Dict(Symbol(k)=>v for (k, v) in d)

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
    alternatives::Union{Missing, StructArray}

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
           securityDescription::MaybeString=missing,
           alternatives::Union{Missing, StructArray}=missing) = new(id, figi, name, ticker, exchCode, compositeFIGI, securityType,
                   marketSector, shareClassFIGI, securityType2, securityDescription, "$(ticker) $(exchCode) $(marketSector)", alternatives)
    
end

function Equity(id::FinancialSymbol, v::Vector{Dict{Symbol, String}})::Vector{Equity}
    out = []
    for d in v
        push!(out, Equity(; id=id, d...))
    end
    return out
end

function Equity(id::FinancialSymbol)
    job = makejob(id, "Equity")
    response = fetchsecuritydata(job)[1]
    if haskey(response, "data")
        kws = makesymbolkeys.(response["data"])
        alternatives=length(kws) > 1 ? StructArray(Equity(id, kws[2:end])) : missing
        return Equity(;id=id, kws[1]..., alternatives=alternatives)
    else
        return Equity(;id=id)
    end
end

function Equity(ids::Vector{FinancialSymbol})
    job = makejob.(ids, "Equity")
    responses = fetchsecuritydata(job)
    out = []
    for (id, response) in zip(ids, responses)
        if haskey(response, "data")
            kws = makesymbolkeys.(response["data"])
            alternatives=length(kws) > 1 ? StructArray(Equity(id, kws[2:end])) : missing
            push!(out, Equity(;id=id, kws[1]..., alternatives=alternatives))
        else
            push!(out, Equity(;id=id))
        end
    end
    return out
end

Equity(id::String) = Equity(makesymbol(id))
Equity(ids::Vector{String}) = Equity(makesymbol.(ids))

end # module