var webpack = require('webpack');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var path = require('path');
var srcRoot = path.join(__dirname, 'src');

var config = {
  entry: './app.coffee',
  context: srcRoot,

  output: {
    path: path.join(__dirname, 'public'),
    filename: 'bundle.js',
  },

  resolve: {
    root: srcRoot,
    extensions: ['', '.js', '.jsx', '.coffee'],
    fallback: [__dirname, path.join(__dirname, 'sass')], // for templates and styles
    alias: {
      'jquery.timeago':   path.join(__dirname, 'vendors', 'jquery.timeago'),
      'jquery.typeahead': path.join(__dirname, 'vendors', 'typeahead'),
      'jquery.easing':    path.join(__dirname, 'vendors', 'jquery.easing.1.3'),
      'bootstrap':        path.join(__dirname, 'vendors', 'bootstrap'),
      'jquery-ui':        path.join(__dirname, 'vendors', 'jquery-ui/js/jquery-ui-1.10.3.custom'),
    },
  },

  module: {
    loaders: [
      {
        test: /\.coffee$/,
        loader: 'coffee-loader',
      },
      // JSX and SCSS configuration depend on NODE_ENV and will be generated dynamically
    ],
  },

  plugins: [],

  amd: {
    jQuery: true,
    'jquery.timeago': true,
    'jquery-autosize': true,
  },
};

// Generating dynamic parts of configuration which depend on NODE_ENV
var jsxLoader = {
  test: /\.jsx$/,
  loaders: ['babel-loader'],
};
var sassLoader = {
  test: /\.scss$/,
  loaders: ['css-loader', 'autoprefixer-loader', 'sass-loader'],
};

if (process.env.NODE_ENV === 'development') {
  config.entry = [
    'webpack-dev-server/client?http://0.0.0.0:9090',
    'webpack/hot/only-dev-server',
    config.entry,
  ];
  config.output.publicPath = 'http://localhost:9090/';

  jsxLoader.loaders.unshift('react-hot');
  sassLoader.loaders.unshift('style-loader');

  config.plugins = config.plugins.concat([
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin(),
  ]);

  config.devtool = 'cheap-module-eval-source-map';
}
else if (process.env.NODE_ENV === 'production') {
  sassLoader.loader = ExtractTextPlugin.extract('style-loader', sassLoader.loaders.join('!'));
  delete sassLoader.loaders;

  config.plugins = config.plugins.concat([
    new ExtractTextPlugin('css/main.css', {allChunks: true}),
    new webpack.optimize.UglifyJsPlugin(),
  ]);
  config.devtool = 'source-map';
}
else {
  throw 'Unknown NODE_ENV';
}
config.module.loaders.push(jsxLoader);
config.module.loaders.push(sassLoader);

module.exports = config;
