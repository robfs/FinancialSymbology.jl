# FinancialSymbology v0.2.1

A package to standardise financial security symbology with the [OpenFIGI](https://www.openfigi.com) methodology. 

Inlcudes automatic symbol type detection to allow for various ID input types (i.e. Sedol, Cusip, ISIN etc.).

Communicates with the [OpenFIGI API](https://www.openfigi.com/api) to retrieve security information. 

# Usage

```julia
using FinancialSymbology
```
If you have an OpenFIGI API key it can be set in one of two ways. 
```python
# By setting the environment variable
ENV["X-OPENFIGI-APIKEY"] = "enter-api-key"
api = OpenFigiAPI()

# By providing an input to the class
api = OpenFigiAPI(apikey="enter-api-key")
```
## Symbols

Financial symbols must first be converted to a vector of `Identifier`. This can be automated or done manually (automated detection unavailable for `Index` identifiers).

```julia
ids = [
   Sedol("B0YQ5W0"),
   Cusip("037833100"),
   Isin("US0378331005"),
   Figi("BBG000B9Y5X2"),
   Ticker("AAPL US Equity")
]

# is equivalent to

ids = makesymbol.([
   "B0YQ5W0",
   "037833100",
   "US0378331005",
   "BBG000B9Y5X2",
   "AAPL US Equity"
])
```

## Fetching Data

The `Identifier` vector can then be passed to the `fetchsecuritydata` function to retrieve informaiton from the OpenFIGI database. 

```julia
data = fetchsecuritydata(ids)

# An API can be manually created and passed
api = OpenFigiAPI()
data = fetchsecuritydata(ids, api)
```

The function returns a dictionary where the keys are the identifiers and the values are a `StructArray` of `OpenFigiAsset` types. The fields can be indexed into or the objects can be passed to other constructors.

```julia
@show data["US0378331005"].figi

using DataFrames
@show data["US0378331005"] |> DataFrame
```