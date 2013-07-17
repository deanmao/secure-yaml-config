require('coffee-script');
var Configuration = require('./lib/configuration');

module.exports.getConfig = function(options) {
  var c = new Configuration(options);
  return c.config;
}
