# FinancialSymbology v0.1.0

A package to standardise financial security symbology with the [OpenFIGI](https://www.openfigi.com) methodology. 

Inlcudes automatic symbol type detection to allow for various ID input types (i.e. Sedol, Cusip, ISIN etc.).

Communicates with the [OpenFIGI API](https://www.openfigi.com/api) to retrieve security information. 

# Usage

```julia
using FinancialSymbology

# Setting the API key if you have one significantly increases the scale of available queries
ENV["OPENFIGI_API_KEY"] = "enter_api_key"

sedol = Sedol("B0YQ5W0")
cusip = Cusip("B0YQ5W0")
isin = Isin("US0378331005")
figi = Figi("BBG000B9Y5X2")
ticker = Ticker("AAPL US Equity")

# Only Equity type exists so far
aapl = Equity(ticker)
vod = Equity("VOD LN Equity")
ibm = Equity("US4592001014")

#= Passing a vector of ids (strings or symbols) is more efficient than vectorizing
   the constructor (Equity.()) because it queries the API in batches and constructs 
   the elements from the response rather than fetching every security as an individual 
   query. Query limits are defined by the OpenFIGI API and whether or not you have a
   API Key, but once limits are hit, the functions will wait and retry once your allowance
   has reset. =#

listofequities = Equity(["B0YQ5W0", "B0YQ5W0", "US0378331005", "BBG000B9Y5X2"])

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
* Alternatives
  * These are different symbols that also match the query
  * This is returned as a `StructArray` so fields can be easily accessed for all alternatives


