module Identifiers

# Export key symbols
export Identifier, Sedol, Cusip, Isin, Figi, Ticker, Index

# Define the abstract type for all identifier types
abstract type Identifier end

#####################################
#      DEFINE IDENTIFIER TYPES      #
#####################################
struct Sedol <: Identifier
    x::AbstractString
end

struct Cusip <: Identifier
    x::AbstractString
end

struct Isin <: Identifier
    x::AbstractString
end

struct Figi <: Identifier
    x::AbstractString
end

struct Ticker <: Identifier
    x::AbstractString
    Ticker(x::AbstractString) = new(join(split(x), ' '))
end

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