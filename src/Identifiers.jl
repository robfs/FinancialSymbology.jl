module Identifiers

# Export key symbols
export Identifier, Sedol, Cusip, Isin, Figi, Ticker, Index

# Define the abstract type for all identifier types
abstract type Identifier end

#####################################
#      DEFINE IDENTIFIER TYPES      #
#####################################

"""
    Sedol(x::String)

Create a Sedol `Identifier` type.

See also: [`makesymbol`](@ref)

# Examples
```jldoctest
julia> using FinancialSymbology

julia> Sedol("5505072")
Sedol: 5505072
```
"""
struct Sedol <: Identifier
    x::AbstractString
end

"""
    Cusip(x::String)

Create a Cusip `Identifier` type.

See also: [`makesymbol`](@ref)

# Examples
```jldoctest
julia> using FinancialSymbology

julia> Cusip("42751Q105")
Cusip: 42751Q105
```
"""
struct Cusip <: Identifier
    x::AbstractString
end

"""
    Isin(x::String)

Create a Isin `Identifier` type.

See also: [`makesymbol`](@ref)

# Examples
```jldoctest
julia> using FinancialSymbology

julia> Isin("US88160R1014")
Isin: US88160R1014
```
"""
struct Isin <: Identifier
    x::AbstractString
end

"""
    Figi(x::String)

Create a Figi `Identifier` type.

See also: [`makesymbol`](@ref)

# Examples
```jldoctest
julia> using FinancialSymbology

julia> Figi("BBG00JRQS527")
Figi: BBG00JRQS527
```
"""
struct Figi <: Identifier
    x::AbstractString
end

"""
    Ticker(x::String)

Create a Bloomberg Ticker `Identifier` type.

See also: [`makesymbol`](@ref)

# Examples
```jldoctest
julia> using FinancialSymbology

julia> Ticker("AAPL US Equity")
Ticker: AAPL US Equity
```
"""
struct Ticker <: Identifier
    x::AbstractString
    Ticker(x::AbstractString) = new(join(split(x), ' '))
end

"""
    Index(x::String)

Create an Index `Identifier` type.

See also: [`makesymbol`](@ref)

# Examples
```jldoctest
julia> using FinancialSymbology

julia> Index("990100")
Index: 990100
```
"""
struct Index <: Identifier
    x::AbstractString
end

#####################################
# CONSTRUCTORS FOR IDENTIFIER TYPES #
#####################################
Sedol(x::Identifier)= Sedol(x.x)
Sedol(x::Sedol) = x
Sedol(x::Missing) = missing

Cusip(x::Identifier) = Cusip(x.x)
Cusip(x::Cusip) = x
Cusip(x::Missing) = missing

Isin(x::Identifier)= Isin(x.x)
Isin(x::Isin) = x
Isin(x::Missing) = missing

Figi(x::Identifier) = Figi(x.x)
Figi(x::Figi) = x
Figi(x::Missing) = missing

Ticker(x::Identifier) = Ticker(x.x)
Ticker(x::Ticker) = x
Ticker(x::Missing) = missing

Index(x::Identifier) = Index(x.x)
Index(x::Ticker) = x
Index(x::Missing) = missing

Base.show(io::IO, x::Identifier) = print(io, x.x)
Base.show(io::IO, ::MIME"text/plain", x::Identifier) = print(io, "$(typeof(x)): $(x.x)")

end # module