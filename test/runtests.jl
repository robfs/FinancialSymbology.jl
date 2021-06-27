using FinancialSymbology
using Test


@testset "IdChecks.jl" begin
    @test makesymbol("B0YQ5W0") isa Sedol
    @test makesymbol("037833100") isa Cusip
    @test makesymbol("US0378331005") isa Isin
    @test makesymbol("BBG000B9Y5X2") isa Figi
    @test makesymbol("AAPL US Equity") isa Ticker
    @test makesymbol("  B0YQ5W0 ") isa Sedol
    @test makesymbol(" AHFMCF     Corp ") isa Ticker
end

@testset "OpenFigiApi.jl" begin
    x = [1, 2, 3, 4, 5, 6, 7]
    xsplit = FinancialSymbology.FinancialSecurities.OpenFigiApi.splitvector(x, 3) 
    y = ['1','2','3','4','5','6','7']
    ysplit = FinancialSymbology.FinancialSecurities.OpenFigiApi.splitvector(y, 4) 
    @test xsplit == [[1, 2, 3], [4, 5, 6], [7]]
    @test ysplit == [['1','2','3','4'],['5','6','7']]
    @test xsplit isa Vector{Vector{Int}}
    @test ysplit isa Vector{Vector{Char}}
    
    a = 10
    b = 60
    h = ["x"=>"sd"]
    ENV["OPENFIGI_API_KEY"] = "MYAPIKEY"
    (h, a, b) = FinancialSymbology.FinancialSecurities.OpenFigiApi.checkapikey(h, a, b)
    @test a == 100
    @test b == 6
end
