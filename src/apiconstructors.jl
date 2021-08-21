using JSON, StructArrays, ProgressMeter
import HTTP: Response, request

MAPPING_JOB_PROPERTIES = [:idType, :exchCode, :micCode, :currency, :marketSecDes, :securityType, :securityType2, :stateCode]

include("identifierutils.jl")


function makeurl(api::API)::String
    return "$(api.protocol)://$(api.base)/$(api.version)/$(api.path)"
end


figiidtype(id::Sedol)::String = "ID_SEDOL"
figiidtype(id::Cusip)::String = "ID_CUSIP"
figiidtype(id::Isin)::String = "ID_ISIN"
figiidtype(id::Figi)::String = "ID_BB_GLOBAL"
figiidtype(id::Ticker)::String = "TICKER"
figiidtype(id::Index)::String = "VENDOR_INDEX_CODE"


function checkfigikwargs(; kwargs...)
    for (key, value) in kwargs
        if !(key in MAPPING_JOB_PROPERTIES)
            throw(ArgumentError("$(key) not a valid OpenFIGI mapping value."))
        end
    end
end

function makejob(id::AbstractString; kwargs...)::Dict{Symbol, String}
    checkfigikwargs(; kwargs...)
    return Dict((:idValue=>id, kwargs...))
end


function makejob(id::Identifier; kwargs...)::Dict{Symbol, String}
    return makejob(id.s; idType=figiidtype(id), kwargs...)
end

function makejob(id::Ticker; kwargs...)::Dict{Symbol, String}
    components = split(id.s)
    if length(components) == 2
        return makejob(components[1]; idType="TICKER", marketSecDes=components[2], kwargs...)
    elseif length(components) == 3
        return makejob(components[1]; idType="TICKER", exchCode=components[2], marketSecDes=components[3], kwargs...)
    else
        return makejob(components[1]; idType="TICKER")
    end
end

function makejobs(ids::Vector{<:AbstractString}; kwargs...)::Vector{Dict{Symbol, String}}
    if !any(value isa AbstractVector for (key, value) in kwargs)
        return makejob.(ids; kwargs...)
    else
        kwargslist = collect(zip([key .=> value for (key, value) in kwargs]...))
        return [makejob(id; kw...) for (id, kw) in zip(ids, kwargslist)]
    end
end


function splitjobs(jobs::Vector{Dict{Symbol, String}}, maxjobs::Int)::Vector{Vector{Dict{Symbol, String}}}
    return [i+maxjobs > length(jobs) ? jobs[i:end] : jobs[i:i+maxjobs-1] for i in 1:maxjobs:length(jobs)]
end


function getlimits(api::OpenFigiAPI)::Tuple{Int, Int, Int}
    d = Dict(api.headers)
    return haskey(d, APIKEYNAME) && length(d[APIKEYNAME]) > 0 ? (100, 6, 25) : (5, 60, 25)
end


function request(ids::Vector{<:AbstractString}, api::OpenFigiAPI; kwargs...)::Vector{Response}
    (maxjobs, waittime, maxrequests) = getlimits(api)
    jobs = makejobs(ids; kwargs...)
    joblist = splitjobs(jobs, maxjobs)
    out = []
    p = Progress(length(joblist))
    for job in joblist
        r = request("POST", makeurl(api), api.headers, JSON.json(job); status_exception=false)
        while r.status == 429
            println("Limit exceeded. Retrying in $(waittime)s")
            sleep(waittime)
            r = request("POST", makeurl(api), api.headers, JSON.json(job); status_exception=false)
        end
        push!(out, r)
        next!(p)
    end

    return out
end

function extractdata(ids::Vector{<:AbstractString}, responses::Vector{Response})::Dict{String, StructArray}
    out::Vector{Pair{String, StructArray}} = []
    i::Int = 1
    for j in JSON.parse.(String.([r.body for r in responses]))
        for v in j
            if haskey(v, "data"); push!(out, ids[i] => StructArray(OpenFigiAsset.(v["data"])))
            else; push!(out, ids[i] => StructArray([OpenFigiAsset()]))
            end
            i += 1
        end
    end
    return Dict(out)
end