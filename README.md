# Public Rest API for **https://margin.exchange**

 The base endpoint is: **https://api.margin.exchange**
* All requests to API return a JSON object.
* All requests to API expects JSON object as parameters.
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

```javascript
{
  "DATA": [
    {
      "MARKET": "BTCUSD",
      "SELL": 3678.8,      
      "BUY": 3678.5,
      "LAST": 3678.5
    },
    {
      "MARKET": "LTCUSD",
      "SELL": 43.39,
      "BUY": 43.36,
      "LAST": 43.36      
    },
    ...
  ],
  "RESULT": 1,
  "MESSAGE": "OK"
}
```

## Get Ticker for specific market
### GET /v1/public/ticker/`market_id`

```javascript
{
  "DATA": {
    "MARKET": "BTCUSD",
    "SELL": 3678.8,      
    "BUY": 3678.5,
    "LAST": 3678.5
   },
  "RESULT": 1,
  "MESSAGE": "OK"
}
```

## Get market order book
### GET /v1/public/orders/`market_id`

**Parameters:**

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
limit | INT | NO | Default 10; max 1000.

`GET /v1/public/orders/BTCUSD?limit=2`
```javascript
{
  "DATA": {
    "BUY": [
      {
        "PRICE": 3678.5,
        "QTY": 6.0836145,
        "COUNT": 2        
      },
      {
        "PRICE": 3678.4,
        "QTY": 2.06334167,        
        "COUNT": 3
      }
    ],
    "SELL": [
      {
        "PRICE": 3678.8,
        "QTY": 5.33834515,
        "COUNT": 2
      },
      {
        "PRICE": 3678.9,
        "QTY": 0.84328958,
        "COUNT": 3
      }
    ]
  },
  "RESULT": 1,
  "MESSAGE": "OK"
}
```


## Get market order book history
### GET /v1/public/orders_history/`market_id`

**Parameters:**

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
limit | INT | NO | Default 10; max 100.

`GET /v1/public/orders_hisotry/BTCUSD?limit=2`
```javascript
{
  "DATA": [
    {
      "TYPE": "SELL",
      "PRICE": 3678.5,
      "QTY": 0.00963449,
      "TOTAL": 35.44047146,      
      "DT": "2019-02-13 13:22:00"      
    },
    {
      "TYPE": "SELL",
      "PRICE": 3678.5,
      "QTY": 0.0056712,
      "TOTAL": 20.8615092,
      "DT": "2019-02-13 13:21:51"
    }
  ],
  "RESULT": 1,
  "MESSAGE": "OK"
}
```


# PRIVATE requests
* Each private request should send additional information to identify user
* Before you start - you should make `Api key` / `Api secret` pair using main web site.
* List of required headers:

Header | Description
--------- | ---------
X-APIKEY | `Api key` as is
X-PAYLOAD | base64(request data)
X-SIGNATURE | base64(Hmac sha256 of payload using your `Api secret`)
X-NONCE | Incrementing integer. usually it is `unix time * 1000`

### How to calculate payload / signature
`payload = REQUEST_METHOD + URL_PATH + POST_DATA + NONCE`

Lets make request ещ (as example): `/v1/private/cancel_order`
- Current NONCE (can be any): 12233342344
- Request body (POST DATA) is {"MARKET":"BTCUSD","ID":12333}


PAYLOAD:
```
payload = "POST" + "/v1/private/cancel_order" + "{"MARKET":"BTCUSD","ID":12333}" + "12233342344"
payload = encode_base64(payload)
````

SIGNATURE:
```
signature = encode_base64(hmac_sha256(payload, Api secret))
```

NOTE: length(signature) should be always a multiple of 4. If not add '=' at the end.
```
while ((length(signature) % 4) != 0) { 
 signature = signature + '=' 
}
```

## Get Balance
### GET /v1/private/balances

```javascript
{
  "DATA": [
    {
      "CURRENCY_ID": "BAB",
      "CURRENCY_TICKER": "BAB",
      "CURRENCY_NAME": "Bitcoin ABC"
      "MARGIN": {
        "TOTAL": 0,
        "LOCKED": 0,
        "PENDING": 0,
        "AVAIL": 0
      },      
      "EXCHANGE": {
        "AVAIL": "3.38",
        "PENDING": "0",
        "LOCKED": "0",
        "TOTAL": "3.38"
      },
      "FUNDING": {
        "PENDING": 0,
        "AVAIL": 0,
        "LOCKED": 0,
        "TOTAL": 0
      }
    },
    {
      "CURRENCY_ID": "USD",
      "CURRENCY_TICKER": "USD",
      "CURRENCY_NAME": "USD",
      "EXCHANGE": {
        "AVAIL": "230.6",
        "PENDING": "0",
        "TOTAL": "233",
        "LOCKED": "3.6"
      },      
      "MARGIN": {
        "AVAIL": 0,
        "PENDING": 0,
        "TOTAL": 0,
        "LOCKED": 0
      },
      "FUNDING": {
        "TOTAL": 0,
        "LOCKED": 0,
        "PENDING": 0,
        "AVAIL": 0
      }
    },
    ...
  ],
  "RESULT": 1,
  "MESSAGE": "OK"
}
```

## Get Balance for specific currency
### GET /v1/private/balance/`currency_ID`

`GET /v1/private/balance/USD`

```javascript
{
  "DATA": {
     "CURRENCY_ID": "USD",
     "CURRENCY_TICKER": "USD",
     "CURRENCY_NAME": "USD",
     "EXCHANGE": {
       "AVAIL": "230.6",
       "PENDING": "0",
       "TOTAL": "233",
       "LOCKED": "3.6"
     },      
     "MARGIN": {
       "AVAIL": 0,
       "PENDING": 0,
       "TOTAL": 0,
       "LOCKED": 0
     },
     "FUNDING": {
       "TOTAL": 0,
       "LOCKED": 0,
       "PENDING": 0,
       "AVAIL": 0
     }
   },
  "RESULT": 1,
  "MESSAGE": "OK"
}
```

## New order
### POST /v1/private/new_order
Parameter | Required | Description
----------- | ----------- | -----------
MARKET | Yes | Market ID  (ex: BTCUSD, LTCUSD ...)
TYPE | Yes | "BUY" or "SELL"
ORDER_TYPE | Yes | "market" or "limit" or "stop" or "conditional"
QTY | Yes | Order qty. General Precision Rules apply.
PRICE | Yes | Order price. should be "0" for market orders. (stop/conditional trigger price stop/conditional orders) General Precision Rules apply.
EXCHANGE_TYPE | No | "exchange" or "margin". default is "exchange"
HIDDEN | No | "1" or "0". Default is "0"
POST_ONLY | No | "1" or "0". Default is "0". "1" = will cancel order if it is going to execute immidiately
REDUCE_ONLY | No, used when EXCHANGE_TYPE='margin' | "1" or "0". Default is "0". "1" = will cancel order if it is going to increase current margin position size
NOTE | No | Order note, max 100 chars. Visible only to owner.
STOP_TYPE | required for ORDER_TYPE="stop" | "market" or "limit" or "trailing"
STOP_LIMIT_PRICE | required for ORDER_TYPE="stop" and STOP_TYPE="limit" | Price for limit order to appear once stop order is triggered
STOP_TRAILING_DISTANCE | required for ORDER_TYPE="stop" and STOP_TYPE="trailing" | Distance Price. General Precision Rules apply.
CONDITIONAL_TYPE | required for ORDER_TYPE="conditional" | "market" or "limit"
CONDITIONAL_LIMIT_PRICE | required for ORDER_TYPE="conditional" and CONDITIONAL_TYPE="limit" | Price for limit order to appear once conditional order is triggered
MARGIN_LEVERAGE | No, used when EXCHANGE_TYPE='margin' | float: from 1 to MARKET_MAX_LEVERAGE. default=MARKET_MAX_LEVERAGE
MARGIN_GROUP | No, used when EXCHANGE_TYPE='margin' | "0" or "1" or "2". default=0
TIME_IN_FORCE | No | Time when order will be auto cancelled. format "YYYY-MM-DD HH:mm:ss" (UTC). if supplied - should be valid datetime in future. Can be set to "0" to cancel expiration.


### **difference beween "stop" and "conditional" orders:**
 - STOP BUY order can have price only lower than current market price.
 - STOP SELL order can have price only higer than current market price.
 - CONDITIONAL orders can have any price and will be triggered once current price crosses conditional price.

```javascript
{
 "DATA" : {
   'ID': 1013132
  },
  "RESULT": 1,
  "MESSAGE": "OK"
}
```


## Update order
### POST /v1/private/update_order

Parameter | Required | Description
----------- | ----------- | -----------
MARKET | Yes | Market ID  (ex: BTCUSD, LTCUSD ...)
ID | Yes | Order ID
QTY | Yes | Order qty. General Precision Rules apply.
PRICE | Yes | Order price. General Precision Rules apply.
params from `new_order` except TYPE, ORDER_TYPE, STOP_TYPE and CONDITIONAL_TYPE | No | Send only parameters you want to change

```javascript
{
 "DATA" : {
   'ID': 1013132
  },
  "RESULT": 1,
  "MESSAGE": "OK"
}
```

## Cancel order
### POST /v1/private/cancel_order

Parameter | Required | Description
----------- | ----------- | -----------
MARKET | Yes | Market ID  (ex: BTCUSD, LTCUSD ...)
ID | Yes | Order ID

```javascript
{
 "DATA" : {},
 "RESULT": 1,
 "MESSAGE": "OK"
}
```


## List open orders
### POST /v1/private/list_open_orders

Parameter | Required | Description
----------- | ----------- | -----------
MARKET | No | Market ID  (ex: BTCUSD, LTCUSD ...)

```javascript
{
 "DATA" : [
    {
      "MARKET" : "BTCUSD",
      "ID" : 1013120,
      "DT" : "2019-01-11 02:23:26",
      "TYPE" : "BUY",
      "ORDER_TYPE" : "limit",
      "TOTAL_QTY" : "10.9",
      "FILLED_QTY" : "0.1",
      "PENDING_QTY" : "10.8",
      "PRICE" : "3840.25",
      "EXCHANGE_TYPE" : "exchange",
      "TIME_IN_FORCE" : 0,
      "NOTE" : "",
      "HIDDEN" : 1
    },
    {
      "MARKET" : "BTCUSD",
      "ID" : 1013130,
      "DT" : "2019-01-14 10:21:46",
      "TYPE" : "BUY",
      "ORDER_TYPE" : "stop",
      "STOP_TYPE" : "market",
      "TOTAL_QTY" : "0.1",
      "FILLED_QTY" : "0",
      "PENDING_QTY" : "0.1",
      "PRICE" : "3848.25",
      "EXCHANGE_TYPE" : "exchange",
      "TIME_IN_FORCE" : 0,
      "NOTE" : "",
      "HIDDEN" : 0
    },
    {
      "MARKET" : "BTCUSD",
      "ID" : 1013131,
      "DT" : "2019-01-14 10:21:47",
      "TYPE" : "BUY",
      "ORDER_TYPE" : "stop",
      "STOP_TYPE" : "limit",
      "STOP_LIMIT_PRICE" : "3848.25",
      "TOTAL_QTY" : "0.1",
      "FILLED_QTY" : "0",
      "PENDING_QTY" : "0.1",
      "PRICE" : "3848.25",
      "EXCHANGE_TYPE" : "exchange",
      "TIME_IN_FORCE" : 0,
      "NOTE" : "",
      "HIDDEN" : 0
    },
    {
      "MARKET" : "BTCUSD",
      "ID" : 1013132,
      "DT" : "2019-01-14 10:21:48",
      "TYPE" : "BUY",
      "ORDER_TYPE" : "stop",
      "STOP_TYPE" : "trailing",
      "STOP_TRAILING_DISTANCE" : "36.65",
      "TOTAL_QTY" : "0.1",
      "FILLED_QTY" : "0",
      "PENDING_QTY" : "0.1",
      "PRICE" : "3701.65",
      "EXCHANGE_TYPE" : "exchange",
      "TIME_IN_FORCE" : "2019-01-16 09:57:16",
      "NOTE" : "",
      "HIDDEN" : 0
    }
  ],
  "RESULT": 1,
  "MESSAGE": "OK"
}
```
