ursa = require('ursa')
fs = require('fs')
require('js-yaml')
_ = require('underscore')

requiredOptions = 'publicKeyFile configFile'.split(' ')

class Configuration
  constructor: (@options) ->
    hasAllRequired = true
    (hasAllRequired = hasAllRequired + @options[option]) for option in requiredOptions
    if hasAllRequired
      if @options.watch
        fs.watch @options.configFile, (event, filename) =>
          config = @readConfig()
          if _.isFunction(@options.watch)
            @options.watch(null, config)
      keyFile = @options.publicKeyFile
      unless fs.existsSync(keyFile)
        console.log("public key missing, so generating one at: #{keyFile}")
        @generateKey()
      @publicKey = ursa.createPublicKey(fs.readFileSync(keyFile))
      @readConfig()
    else
      throw new Error('options hash requires all of these parameters: ' + requiredOptions.join(', '))

  readConfig: ->
    @rewriteConfig()
    config = require(@options.configFile)
    if @options.env && config[@options.env]
      config = config[@options.env]
    @config = @walk(config)
    return @config

  walk: (obj) ->
    if _.isArray(obj)
      _.map obj, (value) =>
        @walk(value)
    else if _.isObject(obj)
      _.each obj, (value, key) =>
        obj[key] = @walk(value)
      obj
    else
      if _.isString(obj) && /decrypt\(.+\)/.exec(obj)
        matches = /decrypt\((.+)\)/.exec(obj)
        @decrypt(new Buffer(matches[1], 'base64'))
      else
        obj

  rewriteConfig: ->
    contents = fs.readFileSync(@options.configFile).toString()
    if /encrypt\(.+\)/.exec(contents)
      contents = @findEncryptInConfig(contents)
      fs.writeFileSync(@options.configFile, contents)

  findEncryptInConfig: (contents) ->
    previous = ""
    while previous != contents
      previous = contents
      contents = @replaceEncrypt(contents)
    return contents

  replaceEncrypt: (contents) ->
    if /encrypt\(.+\)/.exec(contents)
      matches = /encrypt\((.+)\)/.exec(contents)
      if matches
        data = matches[1]
        encrypted = @publicKey.encrypt(data).toString('base64')
        contents = contents.replace(matches[0], "decrypt(#{encrypted})")
    return contents

  generateKey: ->
    unless @options.privateKeyFile
      throw new Error('cannot generate key because you did not specify the private key file')
    console.log("generating private key at #{@options.privateKeyFile}")
    key = ursa.generatePrivateKey(8192)
    fs.writeFileSync(@options.privateKeyFile, key.toPrivatePem(), "utf8")
    fs.writeFileSync(@options.publicKeyFile, key.toPublicPem(), "utf8")

  decrypt: (data) ->
    unless @privateKey
      file = @options.privateKeyFile
      unless fs.existsSync(file)
        throw new Error("cannot decrypt data because private key is missing: #{file}")
      @privateKey = ursa.createPrivateKey(fs.readFileSync(@options.privateKeyFile))
    try
      @privateKey.decrypt(data).toString()
    catch err
      "ERROR: invalid key"

module.exports = Configuration

