module FinancialSymbology

include("FinancialSymbols.jl")
include("SymbolTests.jl")
include("FinancialSecurities.jl")

using .FinancialSymbols, .FinancialSecurities, .SymbolTests

export Sedol, Cusip, Isin, Figi, FigiUniqueID, Equity

function main()

    @show sedol = Sedol("B0YQ5W0")
    @show cusip = Cusip("037833901")
    @show isin = Isin("US0378331005")
    @show figi = Figi("BBG000B9Y5X2")
    @show figiuniqueid = FigiUniqueID("EQ00101695000010000")
    @show ticker = Ticker("AAPL US Equity")

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

end
