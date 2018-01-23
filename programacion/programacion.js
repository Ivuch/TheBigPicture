var express = require('express')
var app = express()
app.use(express.static(__dirname+"/public"))

app.get('/', function (req, res) {
  res.sendFile(__dirname+'/index.html')
})

app.get('/JSONModificator', function (req, res) {
  res.sendFile(__dirname+'/JSONModificator.html')
})

app.listen(8088, function () {
  console.log('Example app listening on port 8088!')
})
