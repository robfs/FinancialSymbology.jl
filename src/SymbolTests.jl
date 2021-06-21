module SymbolTests

using ..FinancialSymbols

export issedol, iscusip, isisin, isfigi, makesymbol

const YELLOWKEYS =["Comdty", "Corp", "Curncy", "Equity", "Govt", "Index", "M-Mkt", "Mtge", "Muni", "Pfd"]

function issedol(x::String)::Bool
    return length(x) == 7 && all(isascii, x) && _sedolsum(x) % 10 == 0
end

function iscusip(x::String)::Bool
    return length(x) == 9 && all(isascii, x) && _cusipsum(x) % 10 == 0
end

function isisin(x::String)::Bool
    return length(x) == 12 && all(isdigit, x[3:end]) && all(isletter, x[1:2]) && parse.(Int, collect(x), base=36) |> join |> luhntest
end

function isticker(x::String)::Bool
    xs = split(x, ' ')
    return length(xs) > 1 && titlecase(xs[end]) in YELLOWKEYS
end

function isfigi(x::String)::Bool
    return length(x) == 12 && all(isletter, x[1:3]) && x[3] == 'G'
end

function symboltype(x::String)::DataType
    if issedol(x); return Sedol
    elseif iscusip(x); return Cusip
    elseif isfigi(x); return Figi
    elseif isisin(x); return Isin
    elseif isticker(x); return Ticker
    else; return Figi
    end
end

function makesymbol(x::String)::FinancialSymbol
    return symboltype(x)(x)
end


function _sedolsum(x::String)::Int
    weights = [1, 3, 1, 7, 3, 9, 1]
    s = 0
    for (w, c) in zip(weights, x)
        s += w * parse(Int, c, base=36)
    end
    return s
end

function _cusipsum(x::String)::Int
    s = 0
    for (i, c) in enumerate(x)
        if isdigit(c) || isletter(c)
            v = parse(Int, c, base=36)
        elseif c == '*'
            v = 36
        elseif c == '@'
            v = 37
        elseif c == '#'
            v = 38
        end
        if iseven(i); v *= 2 end
        s += div(v, 10) + rem(v, 10)
    end
    return s
end


function luhntest(x::Integer)::Bool
    (sum(digits(x)[1:2:end]) + sum(map(x->sum(digits(x)), 2 * digits(x)[2:2:end]))) % 10 == 0
end

luhntest(x::String) = luhntest(parse(Int, x))

end # module