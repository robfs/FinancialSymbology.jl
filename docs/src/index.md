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

If you have an OpenFIGI API key it can be set in one of two ways, using either the environment variable `X-OPENFIGI-APIKEY` or setting the `apikey` argument when instantiating an [`OpenFigiAPI`](@ref). 

```julia-repl
julia> ENV["X-OPENFIGI-APIKEY"] = "enter-api-key"
"enter-api-key"

julia> api = OpenFigiAPI(apikey="enter-api-key")
OpenFigiAPI: https://api.openfigi.com/v3/mapping
```
### Identifiers

Financial symbols can either be converted to a vector of [`Identifier`](@ref identifier_header)s or passed as `String`s along with the `idType` input to the [`fetchsecuritydata`](@ref). `Identifier` types can be created using the [`makeidentifier`](@ref) function or done manually using the constructors listed in [`Identifiers`](@ref identifier_header) (automated detection unavailable for [`Index`](@ref) identifiers).

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

The [`fetchsecuritydata`](@ref) function is the primary interface to the OpenFIGI API. The examples in the function documentation detail some of the different ways it can be used. 

```jldoctest
julia> using FinancialSymbology

julia> ids = makeidentifier.(["B0YQ5W0","037833100","US0378331005","BBG000B9Y5X2","AAPL US Equity"])
5-element Vector{Identifier}:
 "B0YQ5W0"
 "037833100"
 "US0378331005"
 "BBG000B9Y5X2"
 "AAPL US Equity"

julia> data = fetchsecuritydata(ids)
Dict{String, StructArrays.StructArray} with 5 entries:
  "US0378331005"   => FinancialSymbology.OpenFigiAsset[OpenFigiAssetâ€¦
  "AAPL US Equity" => FinancialSymbology.OpenFigiAsset[OpenFigiAssetâ€¦
  "B0YQ5W0"        => FinancialSymbology.OpenFigiAsset[OpenFigiAssetâ€¦
  "037833100"      => FinancialSymbology.OpenFigiAsset[OpenFigiAssetâ€¦
  "BBG000B9Y5X2"   => FinancialSymbology.OpenFigiAsset[OpenFigiAssetâ€¦

julia> api = OpenFigiAPI()
OpenFigiAPI: https://api.openfigi.com/v3/mapping

julia> data = fetchsecuritydata(ids, api)
Dict{String, StructArrays.StructArray} with 5 entries:
  "US0378331005"   => FinancialSymbology.OpenFigiAsset[OpenFigiAssetâ€¦
  "AAPL US Equity" => FinancialSymbology.OpenFigiAsset[OpenFigiAssetâ€¦
  "B0YQ5W0"        => FinancialSymbology.OpenFigiAsset[OpenFigiAssetâ€¦
  "037833100"      => FinancialSymbology.OpenFigiAsset[OpenFigiAssetâ€¦
  "BBG000B9Y5X2"   => FinancialSymbology.OpenFigiAsset[OpenFigiAssetâ€¦
```

The function returns a `Dict` where the keys are the identifiers and the values are a `StructArray` of `OpenFigiAsset` types. The fields can be indexed into or the objects can be passed to other constructors.

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
1Ã—10 DataFrame
 Row â”‚ figi          marketSector  securityType  ticker  name       exchCode   â‹¯
     â”‚ Unionâ€¦        Unionâ€¦        Unionâ€¦        Unionâ€¦  Unionâ€¦     Unionâ€¦     â‹¯
â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
   1 â”‚ BBG000B9XRY4  Equity        Common Stock  AAPL    APPLE INC  US         â‹¯
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

## [Identifier Types](@id identifier_header)

```@autodocs
Modules = [FinancialSymbology.Identifiers]
Pages = ["Identifiers.jl"]
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