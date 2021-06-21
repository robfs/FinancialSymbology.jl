module FinancialSymbols

using Base: String, Integer
export FinancialSymbol, Sedol, Cusip, Isin, Figi, Ticker

abstract type FinancialSymbol end

Base.show(io::IO, x::FinancialSymbol) = print(io, x.x)
Base.show(io::IO, ::MIME"text/plain", x::FinancialSymbol) = print(io, "$(typeof(x)): $(x.x)")

struct Sedol <: FinancialSymbol
    x::String
    Sedol(x::String) = new(x)
    Sedol(x::FinancialSymbol) where {T<:FinancialSymbol} = new(x.x)
    Sedol(x::Sedol) = x
    Sedol(x::Missing) = missing
end

struct Cusip <: FinancialSymbol
    x::String
    Cusip(x::String) = new(x)
    Cusip(x::T) where {T<:FinancialSymbol} = new(x.x)
    Cusip(x::Cusip) = x
    Cusip(x::Missing) = missing
end

struct Isin <: FinancialSymbol
    x::String
    Isin(x::String) = new(x)
    Isin(x::T) where {T<:FinancialSymbol} = new(x.x)
    Isin(x::Isin) = x
    Isin(x::Missing) = missing
end

struct Figi <: FinancialSymbol
    x::String
    Figi(x::String) = new(x)
    Figi(x::T) where {T<:FinancialSymbol} = new(x.x)
    Figi(x::Figi) = x
    Figi(x::Missing) = missing
end

struct FigiUniqueID <: FinancialSymbol
    x::String
    FigiUniqueID(x::String) = new(x)
    FigiUniqueID(x::T) where {T<:FinancialSymbol} = new(x.x)
    FigiUniqueID(x::FigiUniqueID) = x
    FigiUniqueID(x::Missing) = missing
end

struct Ticker <: FinancialSymbol
    x::String
    Ticker(x::String) = new(x)
    Ticker(x::T) where {T<:FinancialSymbol} = new(x.x)
    Ticker(x::Ticker) = x
    Ticker(x::Missing) = missing
end

end # module