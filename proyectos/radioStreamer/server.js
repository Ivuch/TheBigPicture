var express = require('express')
var app = express()
var http = require('http').Server(app)
var os = require('os')
var ifaces = os.networkInterfaces()

app.use(express.static(__dirname+"/public"))

app.get('/', function (req, res) {
  res.sendFile(__dirname+'/index.html')
})

app.get('/ip', function(req, res){
	Object.keys(ifaces).forEach(function (ifname) {
	  var alias = 0
	  ifaces[ifname].forEach(function (iface) {
	    if ('IPv4' !== iface.family || iface.internal !== false) {
	      // skip over internal (i.e. 127.0.0.1) and non-ipv4 addresses
	      return
	    }
	    if (alias >= 1) {
	      // this single interface has multiple ipv4 addresses
	      console.log(ifname + ':' + alias, iface.address)
	    } else {
	      // this interface has only one ipv4 adress
	      console.log(ifname, iface.address)
	      res.json({'ip':iface.address})
	    }
	    ++alias
	  })
	})
})

var server = http.listen(8080, function(){	
	var port = server.address().port
	console.log("Server Running in http://127.0.0.1:"+port)
	console.log("Base dir: "+__dirname)
})
