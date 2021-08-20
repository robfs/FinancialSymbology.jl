using JSON, StructArrays
import HTTP: Response, request

include("types.jl")

const YELLOWKEYS =["Comdty", "Corp", "Curncy", "Equity", "Govt", "Index", "M-Mkt", "Mtge", "Muni", "Pfd"]

function sedolsum(x::AbstractString)::Int
    weights = [1, 3, 1, 7, 3, 9, 1]
    s = 0
    for (w, c) in zip(weights, x)
        s += w * parse(Int, c, base=36)
    end
    return s
end


function issedol(x::AbstractString)::Bool
    return length(x) == 7 && all(isascii, x) && sedolsum(x) % 10 == 0
end


function cusipsum(x::AbstractString)::Int
    s = 0
    for (i, c) in enumerate(x)
        if isdigit(c) || isletter(c)
            v = parse(Int, c, base=36)
        elseif c == '*'
            v = 36
        elseif c == '@'
            v = 37
        elseif c == '#'
            v = 38
        end
        if iseven(i); v *= 2 end
        s += div(v, 10) + rem(v, 10)
    end
    return s
end


function iscusip(x::AbstractString)::Bool
    return length(x) == 9 && all(isascii, x) && cusipsum(x) % 10 == 0
end


function luhntest(x::Integer)::Bool
    (sum(digits(x)[1:2:end]) + sum(map(x->sum(digits(x)), 2 * digits(x)[2:2:end]))) % 10 == 0
end

luhntest(x::AbstractString) = luhntest(parse(Int, x))


function isisin(x::AbstractString)::Bool
    return length(x) == 12 && all(map(c -> isdigit(c) || isletter(c), collect(x[3:end]))) && all(isletter, x[1:2]) && parse.(Int, collect(x), base=36) |> join |> luhntest
end

function isticker(x::AbstractString)::Bool
    xs = split(x)
    return length(xs) > 1 && titlecase(xs[end]) in YELLOWKEYS
end

function isfigi(x::AbstractString)::Bool
    return length(x) == 12 && all(isletter, x[1:3]) && x[3] == 'G'
end

function symboltype(x::AbstractString)::DataType
    x = strip(x)
    if issedol(x); return Sedol
    elseif iscusip(x); return Cusip
    elseif isfigi(x); return Figi
    elseif isisin(x); return Isin
    elseif isticker(x); return Ticker
    else; return Figi
    end
end

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

keystosymbols(d::Dict{String, T} where T)::Dict{Symbol, T} where T = Dict([Symbol(k)=>v for (k, v) in d])

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