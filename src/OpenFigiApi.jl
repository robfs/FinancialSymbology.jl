module OpenFigiApi

using HTTP
using JSON

export fetchsecuritydata

const BASEURL = "https://api.openfigi.com"
const APIVERSION = "v3"
const URL = "$(BASEURL)/$(APIVERSION)/mapping"

splitvector(v::Vector{T} where T, n::Int)::Vector{Vector{T}} where T = [i + n >= length(v) ? v[i+1:end] : v[i+1:(i+n)] for i in 0:n:length(v)]

function fetchsecuritydata(job::Vector{Dict{String, String}}; headers::Vector{Pair{String, String}}=["Content-Type"=>"application/json"],
                           max_jobs::Int=10, retry_time::Int=60, retries::Int=15)::Vector
    
    if haskey(ENV, "OPENFIGI_API_KEY")
        max_jobs=100
        retry_time=6
        push!(headers, "X-OPENFIGI-APIKEY"=>ENV["OPENFIGI_API_KEY"])
    end

    if length(job) > max_jobs
        jobs = splitvector(job, max_jobs)
        return fetchsecuritydata(jobs; headers=headers, max_jobs=max_jobs, retry_time=retry_time, retries=retries)
    end

    r::HTTP.Response = HTTP.request("POST", URL, headers, JSON.json(job); status_exception=false)
    counter::Int = 0
    while r.status == 429 && counter < retries
        println("OpenFIGI limit exceeded, trying again in $(retry_time)s...")
        counter += 1
        sleep(retry_time)
        r = HTTP.request("POST", URL, headers, JSON.json(job); status_exception=false)
    end
    if r.status >= 300
        throw(HTTP.ExceptionRequest.StatusError(r.status, r.body))
    end
    return JSON.parse(String(r.body))
end

fetchsecuritydata(job::Dict{String, String})::Vector{Dict{String, Any}} = fetchsecuritydata([job])

function fetchsecuritydata(jobs::Vector{Vector{Dict{String, String}}}; kwargs...)::Vector{Dict{String, Any}}
    out = []
    for job in jobs
        push!(out, fetchsecuritydata(job; kwargs...)...)
    end
    return out
end

fetchsecuritydata(job::Union{Dict{String, String}, Vector{Dict{String, String}}, Vector{Vector{Dict{String, String}}}};
                  api_key::String, kwargs...)::Vector{Dict{String, Any}} = fetchsecuritydata(job; headers=["Content-Type"=>"application/jsjon", "X-OPENFIGI-APIKEY"=>api_key], kwargs...)

function main()
    job = Dict("idType"=>"TICKER", "idValue"=>"AAPL", "marketSecDes"=>"Equity", "exchCode"=>"US")
    @show fetchsecuritydata(job)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

end # module