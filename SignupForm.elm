var express = require("express");

var app = express();

app.set('port', (process.env.PORT || 8080));

console.log("Starting server on: " + app.get('port'));

app.use(function(req, res, next) {
  console.log("request");
  next();
});

app.use(function(req, res, next) {
  console.log("here: " + JSON.stringify(req.headers));
  if (req.headers['x-forwarded-proto'] === 'https') {
    console.log("redirecting to: " + 'http://' + req.hostname + req.url);
    res.redirect('http://' + req.hostname + req.url);
  }
  else {
    next();
  }
});

app.use(express.static(__dirname + '/public'));

app.listen(app.get('port'), function() {
    console.log("server started on " + app.get('port'));
});
