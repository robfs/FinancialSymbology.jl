module Identifiers

export Identifier, Sedol, Cusip, Isin, Ticker, Figi, Index

abstract type Identifier <: AbstractString end


"""
    Sedol(x::String)

Create a Sedol Identifier.

# Example
```jldoctest; setup = :(using FinancialSymbology)
julia> sedol_id = Sedol("B0YQ5W0")
"B0YQ5W0"
```
"""
struct Sedol <: Identifier
    s::AbstractString
end


"""
    Cusip(x::String)

Create a Cusip Identifier.

# Example
```jldoctest; setup = :(using FinancialSymbology)
julia> cusip_id = Cusip("037833100")
"037833100"
```
"""
struct Cusip <: Identifier
    s::AbstractString
end


"""
    Isin(x::String)

Create a ISIN Identifier.

# Example
```jldoctest; setup = :(using FinancialSymbology)
julia> isin_id = Isin("US0378331005")
"US0378331005"
```
"""
struct Isin <: Identifier
    s::AbstractString
end


"""
    Figi(x::String)

Create a FIGI Identifier.

# Example
```jldoctest; setup = :(using FinancialSymbology)
julia> figi_id = Figi("BBG001S5N8V8")
"BBG001S5N8V8"
```
"""
struct Figi <: Identifier
    s::AbstractString
end


"""
    Ticker(x::String)

Create a Ticker Identifier.

# Example
```jldoctest; setup = :(using FinancialSymbology)
julia> ticker_id = Ticker("AAPL US Equity")
"AAPL US Equity"
```
"""
struct Ticker <: Identifier
    s::AbstractString
    Ticker(s::AbstractString) = new(join(split(s), ' '))
end


"""
    Index(x::String)

Create a Index Identifier.

# Example
```jldoctest; setup = :(using FinancialSymbology)
julia> index_id = Index("990100")
"990100"
```
"""
struct Index <: Identifier
    s::AbstractString
end


Sedol(s::Identifier)= Sedol(s.s)
Sedol(s::Sedol) = s
Sedol(s::Missing) = missing

Cusip(s::Identifier) = Cusip(s.s)
Cusip(s::Cusip) = s
Cusip(s::Missing) = missing

Isin(s::Identifier)= Isin(s.s)
Isin(s::Isin) = s
Isin(s::Missing) = missing

Figi(s::Identifier) = Figi(s.s)
Figi(s::Figi) = s
Figi(s::Missing) = missing

Ticker(s::Identifier) = Ticker(s.s)
Ticker(s::Ticker) = s
Ticker(s::Missing) = missing

Index(s::Identifier) = Index(s.s)
Index(s::Ticker) = s
Index(s::Missing) = missing

end # module