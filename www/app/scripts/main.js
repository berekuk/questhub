require.config({
  shim: {
  },

 paths: {
    ember: '../../components/ember',

    hm: 'vendor/hm',
    esprima: 'vendor/esprima',
    jquery: 'vendor/jquery.min'
  }
});
 
require(['app'], function(app) {
  // use app here
  console.log(app);
});