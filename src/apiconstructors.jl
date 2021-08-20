using JSON, StructArrays
import HTTP: Response, request

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


makejob(id::Identifier)::Dict{String, String} = Dict(("idType"=>figiidtype(id), "idValue"=>id.s))
function makejob(id::Ticker)::Dict{String, String}
    components = split(id.s)
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


function request(ids::Vector{<:Identifier}, api::OpenFigiAPI)::Vector{Response}
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

function extractdata(ids::Vector{<:Identifier}, responses::Vector{Response})::Dict{String, StructArray}
    out::Vector{Pair{String, StructArray}} = []
    i::Int = 1
    for j in JSON.parse.(String.([r.body for r in responses]))
        for v in j
            if haskey(v, "data"); push!(out, ids[i].s => StructArray(OpenFigiAsset.(v["data"])))
            else; push!(out, ids[i].s => StructArray([OpenFigiAsset()]))
            end
            i += 1
        end
    end
    return Dict(out)
end