# FinancialSymbology v0.3.1

A package to standardise financial security symbology with the [OpenFIGI](https://www.openfigi.com) methodology. 

Inlcudes automatic symbol type detection to allow for various ID input types (i.e. Sedol, Cusip, ISIN etc.).

Communicates with the [OpenFIGI API](https://www.openfigi.com/api) to retrieve security information. 

# Usage

`fetchsecuritydata` can be used either using `String`s as identifiers or the built-in `Type`s in the [`Identifiers`](@ref id_header) module. 

```julia-repl
julia> using FinancialSymbology

julia> aapl_5 = first(fetchsecuritydata("AAPL", "TICKER"), 5)
5-element StructArray(::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}) with eltype FinancialSymbology.OpenFigiAsset:
 FIGI: BBG000B9XRY4 Common Stock
 FIGI: BBG000B9XSK7 Common Stock
 FIGI: BBG000B9XT70 Common Stock
 FIGI: BBG000B9XVV8 Common Stock
 FIGI: BBG000B9XWM6 Common Stock

julia> aapl_5.exchCode
5-element Vector{Union{Nothing, String}}:
 "US"
 "UA"
 "UC"
 "UN"
 "UP"

julia> aapl_us = fetchsecuritydata("AAPL", "TICKER"; exchCode="US")
1-element StructArray(::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}, ::Vector{Union{Nothing, String}}) with eltype FinancialSymbology.OpenFigiAsset:
 FIGI: BBG000B9XRY4 Common Stock

julia> aapl_us[1]
FIGI: BBG000B9XRY4 Common Stock

julia> aapl_us[1].name
"APPLE INC"
```

Individual constructors can create `Identifier` types or the convenience function `makeidentifier` will automatically detect the identifier type and convert it. 
Single `Identifier`s or `Vector{<:Identifier}` can be passed to the `fetchsecuritydata` function without the need for the `idType` argument. 

```julia-repl
julia> identifiers = makeidentifier.(["AAPL US Equity", "BDDXSM4"])
2-element Vector{Identifier}:
 "AAPL US Equity"
 "BDDXSM4"

julia> fetchsecuritydata(identifiers)
Dict{String, StructArrays.StructArray} with 2 entries:
  "AAPL US Equity" => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "BDDXSM4"        => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
```

```julia-repl
julia> identifiers = [Ticker("AAPL US Equity"), Sedol("BDDXSM4")]
2-element Vector{Identifier}:
 "AAPL US Equity"
 "BDDXSM4"

julia> fetchsecuritydata(identifiers)
Dict{String, StructArrays.StructArray} with 2 entries:
  "AAPL US Equity" => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "BDDXSM4"        => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
```

```julia-repl
julia> aapl = fetchsecuritydata(Ticker("AAPL US Equity"))
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


# More Examples

```julia-repl
julia> tickers = ["AAPL", "VOD", "TSLA"]
3-element Vector{String}:
 "AAPL"
 "VOD"
 "TSLA"

julia> fetchsecuritydata(tickers, "TICKER"; marketSecDes="Equity", exchCode=["US", "LN", "US"])
Dict{String, StructArrays.StructArray} with 3 entries:
  "AAPL" => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "VOD"  => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "TSLA" => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
```

```julia-repl
julia> idstrings = ["BBG000B9XRY4", "037833100", "US0378331005"]
3-element Vector{String}:
 "BBG000B9XRY4"
 "037833100"
 "US0378331005"

julia> idtypes = ["ID_BB_GLOBAL", "ID_CUSIP", "ID_ISIN"]
3-element Vector{String}:
 "ID_BB_GLOBAL"
 "ID_CUSIP"
 "ID_ISIN"

julia> fetchsecuritydata(idstrings, idtypes; exchCode="US")
Dict{String, StructArrays.StructArray} with 3 entries:
  "US0378331005" => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "037833100"    => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
  "BBG000B9XRY4" => FinancialSymbology.OpenFigiAsset[OpenFigiAsset…
```

## [Identifiers](@id id_header)

Financial symbols must first be converted to a vector of `Identifier`. This can be automated or done manually (automated detection unavailable for `Index` identifiers).

```julia-repl
julia> ids = makeidentifier.(["B0YQ5W0",
                              "037833100",
                              "US0378331005",
                              "BBG000B9Y5X2",
                              "AAPL US Equity")
5-element Vector{Identifier}:
 "B0YQ5W0"
 "037833100"
 "US0378331005"
 "BBG000B9Y5X2"
 "AAPL US Equity"

julia> typeof.(ids)
5-element Vector{DataType}:
 Sedol
 Cusip
 Isin
 Figi
 Ticker
```
