# Public Rest API for **http://margin.exchange**

 The base endpoint is: **https://api.margin.exchange**
* All endpoints return a JSON object.
* All requests to API should have HTTP status 200.
* All responces have basic structure like this:

successful:
```javascript
{
 RESULT: 1,
 MESSAGE: 'OK or descriptive text',
 DATA: { ... }
}
```

failed:
```javascript
{
 RESULT: 0,
 MESSAGE: 'error message'
}
```
