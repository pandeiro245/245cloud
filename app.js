var express = require('express');
var app = express();
var http = require('http');
var coffeeMiddleware = require('coffee-middleware');

app.use(express.static(__dirname + '/public'));
app.use(coffeeMiddleware({
  src: __dirname + '/lib',
  compress: true
}));

app.use(coffeeMiddleware({
  src: __dirname,
  compress: true
}));

app.get('/', function (req, res) {
  res.render('index');
});

app.get("/:filename.js", function (req, res) { 
  res.render('lib/' + req.params.filename);
});

app.get("/main.js", function (req, res) { 
  res.render('main');
});

app.get('/nicovideo/:id(sm\\d+)', function (req, res) {
  var sm_id = req.param('id');
  var url = 'http://ext.nicovideo.jp/api/getthumbinfo/' + sm_id;
  http.get(url, function (nicoRes) {
    var body = '';
    nicoRes.setEncoding('utf8');
    nicoRes.on('data', function (chunk) {
      body += chunk;
    });
    nicoRes.on('end', function () {
      res.send(body);
    });
  }).on('error', function (e) {
    res.send(e.message);
  });
});

var server = app.listen(process.env.PORT || 3001, function () {
  var host = server.address().address
  var port = server.address().port
  console.log('listening at http://%s:%s', host, port)
});

