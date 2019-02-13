# Public Rest API for **https://margin.exchange**

 The base endpoint is: **https://api.margin.exchange**
* All endpoints return a JSON object.
* All requests to API should have HTTP status `200`
* All responces have basic structure like this:

Successful:
```javascript
{
 RESULT: 1,
 MESSAGE: 'OK or descriptive text',
 DATA: { ... } or [ ... ]
}
```
DATA can be object or array.


Failed:
```javascript
{
 RESULT: 0,
 MESSAGE: 'error message'
}
```


# PUBLIC requests

## Get Markets List
### GET /v1/public/markets

```javascript
"DATA":[
   {
      "ID":"BTCUSD",
      "BASE_CURRENCY":"BTC",
      "USING_CURRENCY":"USD",
      "BASE_CURRENCY_MIN_TRADE_SIZE":"0.00005",
      "USING_CURRENCY_MIN_TRADE_SIZE":"0.1",
      "CREATED":"2018-01-21 08:31:12",
      "ENABLED":1
   },
   {
      "ID":"ETHBTC",
      "BASE_CURRENCY":"ETH",
      "USING_CURRENCY":"BTC",
      "BASE_CURRENCY_MIN_TRADE_SIZE":"0.001",
      "USING_CURRENCY_MIN_TRADE_SIZE":"0.00005",
      "CREATED":"2018-01-21 09:51:15",
      "ENABLED":1
   },
   ...
],
"MESSAGE":"OK",
"RESULT":1
}
```


## Get Market Details
### GET /v1/public/market/`market_id`

```javascript
{
  "DATA": {
    "ID": "BTCUSD",
    "BUY": 3675,
    "SELL": 3675.3,
    "LOW": 3670.1,
    "HI": 3675.3,
    "LAST": 3675.3,
    "VOLUME": 30856.98,
    "ENABLED": 1,    
    "CREATED": "2018-01-21 08:31:12"  
  },
  "MESSAGE": "OK",
  "RESULT": 1
}
```

## Get Tickers
### GET /v1/public/tickers
