var express = require("express")
var app = express()
var router = express.Router();
var http = require('http')
var https = require('https')
var bodyParser = require('body-parser')
var fs = require("fs")

app.use(bodyParser.json()); // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // to support URL-encoded bodies
app.use(express.static(__dirname+"/public"))



/* GET home page. */
app.get('/', function(req, res) {
	res.sendFile(__dirname+'/index.html')
});

app.post('/upload', function(req, res){
	console.log(req.files);
});

//var doc = "http://stackoverflow.com/questions/23691194/node-express-file-upload"
//var htmlScroll = "http://stackoverflow.com/questions/18814183/make-a-tag-scroll-jump-to-a-div-with-only-html5-and-css"

app.listen(8081, function () {
  console.log('Example app listening on port 8080!')
})
