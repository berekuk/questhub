'use strict';
var express = require('express');
var httpProxy = require('http-proxy');
var path = require('path');

var app = express();

var proxy = httpProxy.createProxyServer();

app.use(
  express.static(
    path.join(__dirname, 'public')
  )
);

['api', 'blog', 'auth'].forEach(function (prefix) {
  var route = '/' + prefix + '/*';
  app.all(route, function (req, res) {
    proxy.web(
      req, res,
      { target: 'http://app' },
      function (e) {
        console.log('proxy error: ' + e);
      }
    );
  });
});

var engines = require('consolidate');
app.engine('html', engines.underscore);

app.use(function (req, res) {
  res.render('index.html', {
    assetPrefix: (process.env.NODE_ENV == 'development' ? 'http://localhost:9090' : ''),
    settings: {
      service_name: 'Questhub',
      analytics: process.env.GOOGLE_ANALYTICS,
      mixpanel_id: process.env.MIXPANEL_TOKEN,
    },
  });
});

app.listen(80);
