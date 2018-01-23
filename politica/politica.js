var express = require('express')
var _ = require('underscore');
var app = express()


app.use(express.static(__dirname+"/public"))
var dpt = require(__dirname+'/model/diputados.json');


app.get('/', function (req, res) {
  res.sendFile(__dirname+'/index.html')
})

app.get('/dpt', function(req, res) {
	res.json(dpt)
})

app.get('/partidos', function(req, res){
	res.json(_.countBy(dpt, function(dpt) { return dpt.partido; }))
})

app.listen(8084, function () {
  console.log('Example app listening on port 8084!')
})
