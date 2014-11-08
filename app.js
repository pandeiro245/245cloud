
var express = require('express');
var app = express();
var coffeeMiddleware = require('coffee-middleware');

app.use(express.static(__dirname + '/public'));
app.use(coffeeMiddleware({
  src: __dirname + '/views',
  compress: true
}));

app.get('/', function (req, res) {
  res.render('index');
})
app.get("/:filename.js", function (req, res) { 
  res.render('views/' + req.params.filename);
})

var server = app.listen(3000, function () {
  var host = server.address().address
  var port = server.address().port
  console.log('listening at http://%s:%s', host, port)
})

