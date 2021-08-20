const YELLOWKEYS =["Comdty", "Corp", "Curncy", "Equity", "Govt", "Index", "M-Mkt", "Mtge", "Muni", "Pfd"]

function sedolsum(x::AbstractString)::Int
    weights = [1, 3, 1, 7, 3, 9, 1]
    s = 0
    for (w, c) in zip(weights, x)
        s += w * parse(Int, c, base=36)
    end
    return s
end


function issedol(x::AbstractString)::Bool
    return length(x) == 7 && all(isascii, x) && sedolsum(x) % 10 == 0
end


function cusipsum(x::AbstractString)::Int
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


function iscusip(x::AbstractString)::Bool
    return length(x) == 9 && all(isascii, x) && cusipsum(x) % 10 == 0
end


function luhntest(x::Integer)::Bool
    (sum(digits(x)[1:2:end]) + sum(map(x->sum(digits(x)), 2 * digits(x)[2:2:end]))) % 10 == 0
end

luhntest(x::AbstractString) = luhntest(parse(Int, x))


function isisin(x::AbstractString)::Bool
    return length(x) == 12 && all(map(c -> isdigit(c) || isletter(c), collect(x[3:end]))) && all(isletter, x[1:2]) && parse.(Int, collect(x), base=36) |> join |> luhntest
end

function isticker(x::AbstractString)::Bool
    xs = split(x)
    return length(xs) > 1 && titlecase(xs[end]) in YELLOWKEYS
end

function isfigi(x::AbstractString)::Bool
    return length(x) == 12 && all(isletter, x[1:3]) && x[3] == 'G'
end

function identifiertype(x::AbstractString)::DataType
    x = strip(x)
    if issedol(x); return Sedol
    elseif iscusip(x); return Cusip
    elseif isfigi(x); return Figi
    elseif isisin(x); return Isin
    elseif isticker(x); return Ticker
    else; return Figi
    end
end
