chai = require 'chai'
chai.should()
Configuration = require('./../lib/configuration')
fs = require('fs')

createConfiguration = (configFile, env) ->
  new Configuration(
    env: env
    publicKeyFile: __dirname + '/public_key'
    privateKeyFile: __dirname + '/private_key'
    configFile: configFile
  )

describe 'configuration', ->
  it 'should auto generate a key file if it does not exist', (done) ->
    targetKeyFile = '/tmp/test___key'
    if fs.existsSync(targetKeyFile)
      fs.unlinkSync(targetKeyFile)
    c = new Configuration(publicKeyFile: targetKeyFile, privateKeyFile: targetKeyFile+'_private', configFile: __dirname + '/example4.yml')
    fs.existsSync(targetKeyFile).should.equal(true)
    done()

  it 'should rewrite config file if it contains encrypt()', (done) ->
    # make a copy of the file in /tmp:
    targetConfigFile = '/tmp/example1.yml'
    if fs.existsSync(targetConfigFile)
      fs.unlinkSync(targetConfigFile)
    contents = fs.readFileSync(__dirname + '/example1.yml').toString()
    fs.writeFileSync(targetConfigFile, contents)
    # do the actual test now:
    c = createConfiguration(targetConfigFile)
    c.rewriteConfig()
    newContents = fs.readFileSync(targetConfigFile).toString()
    contents.should.not.equal(newContents)
    done()

  it 'should automatically decrypt config elements', (done) ->
    c = createConfiguration(__dirname + '/example2.yml')
    c.config.fruit.apple.should.equal('apple')
    c.config.fruit.orange.should.equal('orange')
    c.config.fruit.lemon.should.equal('lemon')
    done()

  it 'should safely handle stuff with bad keys', (done) ->
    c = createConfiguration(__dirname + '/invalid_key.yml')
    c.config.fruit.apple.should.equal('ERROR: invalid key')
    done()

  it 'should choose the right environment config', (done) ->
    c = createConfiguration(__dirname + '/example3.yml', 'development')
    c.config.fruit.should.equal("apple")
    c2 = createConfiguration(__dirname + '/example3.yml', 'production')
    c2.config.fruit.should.equal("orange")
    done()

  it 'should handle a complicated yaml file', (done) ->
    c = createConfiguration(__dirname + '/big_config.yml', 'production')
    c.config.host.should.equal("my-live-site.com")
    c.config.files[3].should.equal("orange")
    done()
