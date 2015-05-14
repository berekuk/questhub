var path = require('path');
var srcRoot = path.join(__dirname, 'src');
var ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = {
  entry: './app.coffee',
  context: srcRoot,

  output: {
    path: __dirname,
    filename: 'bundle.js',
    publicPath: '/',
  },

  resolve: {
    root: srcRoot,
    extensions: ['', '.js', '.jsx', '.coffee'],
    fallback: [__dirname, path.join(__dirname, 'sass')], // for templates and styles
    alias: {
      jquery: 'jquery/jquery.js',
      'jquery.timeago':   path.join(__dirname, 'vendors', 'jquery.timeago'),
      'jquery.typeahead': path.join(__dirname, 'vendors', 'typeahead'),
      'jquery.easing':    path.join(__dirname, 'vendors', 'jquery.easing.1.3'),
      'bootstrap':        path.join(__dirname, 'vendors', 'bootstrap/js/bootstrap'),
      'jquery-ui':        path.join(__dirname, 'vendors', 'jquery-ui/js/jquery-ui-1.10.3.custom'),
    },
  },

  module: {
    loaders: [
      {
        test: /\.coffee$/,
        loader: 'coffee-loader',
      },
      {
        test: /\.jsx/,
        loader: 'babel-loader',
      },
      {
        test: /\.scss$/,
        loader: ExtractTextPlugin.extract('style-loader', 'css-loader!sass-loader'),
      },
      {
        test: /vendors\/jquery\.timeago\.js$/,
        loader: 'imports?define=>false',
      },
      {
        test: /jquery\.autosize\.js$/,
        loader: 'imports?define=>false',
      },
    ],
  },

  plugins: [
    new ExtractTextPlugin('css/main.css', {allChunks: true }),
  ],

  amd: {
    jQuery: true,
  },

  devtool: 'eval',
};
