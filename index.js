require('coffee-script');
var Configuration = require('./lib/configuration');

module.exports.getConfig = (options) ->
  new Configuration(options)
