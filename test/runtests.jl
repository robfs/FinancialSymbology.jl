using FinancialSymbology
using Test, Documenter

import FinancialSymbology.OpenFigi: figiidtype, makeurl, makejob, splitjobs

idstrings = [
    "FR0000121014", "US88160R1014", "AAPL US Equity", "5505072", "CH0210483332",
    "BYVZLD1", "BDDXSM4", "42751Q105", "FR0000120693", "654106103", "GB0002374006" 
]

idchecks = [
    Isin, Isin, Ticker, Sedol, Isin, Sedol, Sedol, Cusip, Isin, Cusip, Isin
]

figitypes = [
    "ID_ISIN","ID_ISIN","TICKER","ID_SEDOL","ID_ISIN",
    "ID_SEDOL","ID_SEDOL","ID_CUSIP","ID_ISIN","ID_CUSIP","ID_ISIN"
]

sedoljob = Dict([
    "idType"=>"ID_SEDOL",
    "idValue"=>"5505072"
])

tickerjob = Dict([
    "idType"=>"TICKER",
    "idValue"=>"AAPL",
    "exchCode"=>"US",
    "marketSecDes"=>"Equity"
])

jobs = [sedoljob, tickerjob]

splitjob = [[sedoljob],[tickerjob]]

ids = makesymbol.(idstrings)

@testset "IdChecks.jl" begin
    @test all(map((id, t) -> id isa t, ids, idchecks))
end

@testset "OpenFigiApi.jl" begin
    @test all(map((id, t) -> figiidtype(id) == t, ids, figitypes))
    @test makeurl(OpenFigiAPI()) == "https://api.openfigi.com/v3/mapping"
    job = makejob(ids[4])
    @test all(map(k -> job[k] == sedoljob[k], sedoljob |> keys |> collect))
    job = makejob(ids[3])
    @test all(map(k -> job[k] == tickerjob[k], tickerjob |> keys |> collect))
    resp = fetchsecuritydata(ids)
    @test length(resp) == length(ids)
    fetchsecuritydata(ids[1])
    fetchsecuritydata([ids[1]])
    fetchsecuritydata(ids[2])
    doctest(FinancialSymbology; manual=false)
end
