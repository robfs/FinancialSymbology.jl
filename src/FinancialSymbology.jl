module FinancialSymbology

include("FinancialSymbols.jl")
include("SymbolTests.jl")
include("FinancialSecurities.jl")

using .FinancialSymbols, .FinancialSecurities, .SymbolTests

export Sedol, Cusip, Isin, Figi, Ticker, Equity

function main()

    @show sedol = Sedol("B0YQ5W0")
    @show cusip = Cusip("037833100")
    @show isin = Isin("US0378331005")
    @show figi = Figi("BBG000B9Y5X2")
    @show ticker = Ticker("AAPL US Equity")
    
    @show aapl = Equity(ticker)
    @show vod = Equity("VOD LN Equity")
    @show ibm = Equity("US4592001014")

    @show multi = Equity(["AAPL US Equity", "VOD LN Equity", "US4592001014"])

end

if abspath(PROGRAM_FILE) == @__FILE__
    using Pkg
    Pkg.activate(".")
    main()
end

end
