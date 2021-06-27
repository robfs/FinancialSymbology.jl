module OpenFigi

using JSON, StructArrays

import ..APIs: API, makeurl, getlimits, request, Response, fetchsecuritydata

using ..Identifiers, ..IdChecks

export OpenFigiAPI, fetchsecuritydata

const APIKEYNAME = "X-OPENFIGI-APIKEY"

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

figiidtype(id::Sedol)::String = "ID_SEDOL"
figiidtype(id::Cusip)::String = "ID_CUSIP"
figiidtype(id::Isin)::String = "ID_ISIN"
figiidtype(id::Figi)::String = "ID_BB_GLOBAL"
figiidtype(id::Ticker)::String = "TICKER"
figiidtype(id::Index)::String = "VENDOR_INDEX_CODE"

makejob(id::Identifier)::Dict{String, String} = Dict(("idType"=>figiidtype(id), "idValue"=>id.x))

function makejob(id::Ticker)::Dict{String, String}
    components = split(id.x)
    if length(components) == 2
        return Dict(["idType"=>"TICKER", "idValue"=>components[1], "marketSecDes"=>components[2]])
    elseif length(components) == 3
        return Dict(["idType"=>"TICKER", "idValue"=>components[1], "exchCode"=>components[2], "marketSecDes"=>components[3]])
    end
end

function splitjobs(jobs::Vector{Dict{String, String}}, maxjobs::Int)::Vector{Vector{Dict{String, String}}}
    return [i+maxjobs > length(jobs) ? jobs[i:end] : jobs[i:i+maxjobs-1] for i in 1:maxjobs:length(jobs)]
end

function getlimits(api::OpenFigiAPI)::Tuple{Int, Int, Int}
    d = Dict(api.headers)
    return haskey(d, APIKEYNAME) && length(d[APIKEYNAME]) > 0 ? (100, 6, 25) : (5, 60, 25)
end

function request(ids::Vector{Identifier}, api::OpenFigiAPI)::Vector{Response}
    (maxjobs, waittime, maxrequests) = getlimits(api)
    jobs::Vector{Dict{String, String}} = makejob.(ids)
    joblist::Vector{Vector{Dict{String, String}}} = splitjobs(jobs, maxjobs)
    out = []
    for job in joblist
        r = request("POST", makeurl(api), api.headers, JSON.json(job); status_exception=false)
        while r.status == 429
            println("Limit exceeded. Retrying in $(waittime)s")
            sleep(waittime)
            r = request("POST", makeurl(api), api.headers, JSON.json(job); status_exception=false)
        end
        push!(out, r)
    end

    return out
end

keystosymbols(d::Dict{String, T} where T)::Dict{Symbol, T} where T = Dict([Symbol(k)=>v for (k, v) in d])

function extractdata(ids::Vector{Identifier}, responses::Vector{Response})::Dict{String, StructArray}
    out::Vector{Pair{String, StructArray}} = []
    i::Int = 1
    for j in JSON.parse.(String.([r.body for r in responses]))
        for v in j
            if haskey(v, "data"); push!(out, ids[i].x => StructArray(OpenFigiAsset.(v["data"])))
            else; push!(out, ids[i].x => StructArray([OpenFigiAsset()]))
            end
            i += 1
        end
    end
    return Dict(out)
end

function fetchsecuritydata(ids::Vector{Identifier}, api::OpenFigiAPI=OpenFigiAPI())::Dict{String, StructArray}
    responses = request(ids, api)
    return extractdata(ids, responses)
end

end # module