module APIs

import HTTP: request, Response
using StructArrays

using ..Identifiers

export API

abstract type API end

Base.show(io::IO, api::API) = print(io, "$(typeof(api)): $(makeurl(api))")

function getlimits(api::API)::Tuple
end

function makeurl(api::API)::String
    return "$(api.protocol)://$(api.base)/$(api.version)/$(api.path)"
end

function request(x::Vector{String}, api::API)::Response
end

function fetchsecuritydata(ids::Vector{<:Identifier}, api::API)::Dict{String, StructArray}
end

end # module