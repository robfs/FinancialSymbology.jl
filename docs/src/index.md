# FinancialSymbology.jl

```@contents
```

## Installation

```julia-repl
julia> using Pkg

julia> Pkg.add("FinancialSymbology")
```

## Usage

```julia-repl
julia> using FinancialSymbology
```

If you have an OpenFIGI API key it can be set in one of two ways, using either the environment variable `X-OPENFIGI-APIKEY` or setting the `apikey` argument when instantiating an `OpenFigiAPI`. 

```julia-repl
julia> ENV["X-OPENFIGI-APIKEY"] = "enter-api-key"
"enter-api-key"

julia> api = OpenFigiAPI(apikey="enter-api-key")
OpenFigiAPI: https://api.openfigi.com/v3/mapping
```
### Symbols

Financial symbols must first be converted to a vector of `Identifier`. This can be automated or done manually (automated detection unavailable for `Index` identifiers).

```jldoctest; setup = :(using FinancialSymbology)
julia> ids = makeidentifier.(["B0YQ5W0", "037833100", "US0378331005", "BBG000B9Y5X2", "AAPL US Equity"])
5-element Vector{Identifier}:
 "B0YQ5W0"
 "037833100"
 "US0378331005"
 "BBG000B9Y5X2"
 "AAPL US Equity"
```

### Fetching Data

The `Identifier` vector can then be passed to the `fetchsecuritydata` function to retrieve information from the OpenFIGI database. 

```@meta
DocTestSetup = quote
    using FinancialSymbology
    if "X-OPENFIGI-APIKEY" in keys(ENV)
        delete!(ENV, "X-OPENFIGI-APIKEY")
    end
    ids = makeidentifier.(["B0YQ5W0","037833100","US0378331005","BBG000B9Y5X2","AAPL US Equity"])
end
```

```jldoctest
julia> data = fetchsecuritydata(ids)
Dict{String, StructArrays.StructArray} with 5 entries:
  "US0378331005"   => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "AAPL US Equity" => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "B0YQ5W0"        => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "037833100"      => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "BBG000B9Y5X2"   => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…

julia> api = OpenFigiAPI()
OpenFigiAPI: https://api.openfigi.com/v3/mapping

julia> data = fetchsecuritydata(ids, api)
Dict{String, StructArrays.StructArray} with 5 entries:
  "US0378331005"   => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "AAPL US Equity" => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "B0YQ5W0"        => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "037833100"      => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "BBG000B9Y5X2"   => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
```

The function returns a dictionary where the keys are the identifiers and the values are a `StructArray` of `OpenFigiAsset` types. The fields can be indexed into or the objects can be passed to other constructors.

```@meta
DocTestSetup = quote
    using FinancialSymbology
    ids = makeidentifier.(["B0YQ5W0","037833100","US0378331005","BBG000B9Y5X2","AAPL US Equity"]);
    data = fetchsecuritydata(ids)
end
```

```jldoctest
julia> aapl = data["AAPL US Equity"]
1-element StructArray(::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}) with eltype FinancialSymbology.OpenFigiAsset:
 FIGI: BBG000B9XRY4 Common Stock

julia> aapl.figi
1-element Vector{Union{Nothing, String}}:
 "BBG000B9XRY4"

julia> using DataFrames

julia> aapl |> DataFrame
1×10 DataFrame
 Row │ figi          marketSector  securityType  ticker  name       exchCode   ⋯
     │ Union…        Union…        Union…        Union…  Union…     Union…     ⋯
─────┼──────────────────────────────────────────────────────────────────────────
   1 │ BBG000B9XRY4  Equity        Common Stock  AAPL    APPLE INC  US         ⋯
                                                               4 columns omitted
```

```@meta
DocTestSetup = nothing
```

## Functions

```@autodocs
Modules = [FinancialSymbology]
Order = [:function]
```

## Identifier Types

```@autodocs
Modules = [FinancialSymbology]
Pages = ["identifiertypes.jl"]
Order = [:type]
```

## API and Responses

```@autodocs
Modules = [FinancialSymbology]
Pages = ["apitypes.jl"]
Order = [:type]
```

## Index
```@index
```