module OpenFigiApi

using HTTP
using JSON

export fetchsecuritydata

const BASEURL = "https://api.openfigi.com"
const APIVERSION = "v3"
const URL = "$(BASEURL)/$(APIVERSION)/mapping"

function fetchsecuritydata(job::Vector{Dict{String, String}})::Vector
    headers = ["Content-Type"=>"application/json"]
    r = HTTP.request("POST", URL, headers, JSON.json(job))
    if div(r.status, 100) > 2
        throw(HTTP.error("Fetch from OpenFIGI failed with error code: $(r.status)"))
    end
    return JSON.parse(String(r.body))
end

fetchsecuritydata(job::Dict{String, String})::Dict{String, Any} = fetchsecuritydata([job])[1]

function main()
    job = Dict("idType"=>"TICKER", "idValue"=>"AAPL", "marketSecDes"=>"Equity", "exchCode"=>"US")
    @show fetchsecuritydata(job)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

end # module