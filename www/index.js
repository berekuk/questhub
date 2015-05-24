'use strict';
var express = require('express');
var httpProxy = require('http-proxy');
var path = require('path');

var app = express();

var proxy = httpProxy.createProxyServer();

if (process.env.NODE_ENV === 'development') {
  var webpackMiddleware = require('webpack-dev-middleware');
  var webpack = require('webpack');
  var compiler = webpack(require('./webpack.config.js'));
  app.use(webpackMiddleware(compiler));
}

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

app.use(function (req, res) {
  res.sendFile(
    path.join(__dirname, 'public', 'index.html')
  );
});

app.listen(80);
