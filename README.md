# FinancialSymbology v0.0.1

A package to standardise financial security symbology with the [OpenFIGI](https://www.openfigi.com) methodology. 

Inlcudes automatic symbol type detection to 

Communicates with the [OpenFIGI API](https://www.openfigi.com/api) to retrieve security information. 

# Usage

```julia
using FinancialSymbology

sedol = Sedol("B0YQ5W0")
cusip = Cusip("037833901")
isin = Isin("US0378331005")
figi = Figi("BBG000B9Y5X2")
ticker = Ticker("AAPL US Equity")

# Only Equity type exists so far
aapl = Equity(ticker)
vod = Equity("VOD LN Equity")
ibm = Equity("US4592001014")

```

## Equity

Equity types will retrieve the following information:

* FIGI (unique asset level ID)
* Name
* Ticker (e.g. AAPL)
* Exchange code (e.g. US, LN)
* Composite FIGI (country level ID)
* Security Type (e.g. Common Stock)
* Market Sector - will always be Equity
* Share class FIGI (global share class ID)
* Security Type 2
* Security Description

TODO: 

* Add option to retrieve parent and alternative listing information
* Add ability to retrieve list of IDs at once

```julia
multiple_equities::Vector{Equity} = Equity(::Vector{String})
```

