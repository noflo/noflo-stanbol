noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  EnhanceText = require '../components/EnhanceText.coffee'
else
  EnhanceText = require 'noflo-stanbol/components/EnhanceText.js'

describe 'EnhanceText component', ->
  c = null
  ins = null
  inURL = null
  inChain = null
  out = null
  beforeEach ->
    c = EnhanceText.getComponent()
    ins = noflo.internalSocket.createSocket()
    inURL = noflo.internalSocket.createSocket()
    inChain = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.inPorts.url.attach inURL
    c.inPorts.chain.attach inChain
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have input ports', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
      chai.expect(c.inPorts.url).to.be.an 'object'
      chai.expect(c.inPorts.chain).to.be.an 'object'
    it 'should have one output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'when given a text', ->
    it 'should enhance it with semantics', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.languages).to.be.an 'array'
        chai.expect(data.sentiments).to.be.an 'object'
        done()

      inURL.send 'http://localhost:8080'
      inChain.send 'default'
      ins.send 'I love you my darling. But I hate all the people.'

    it 'should enhance with the right language', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.languages).to.be.an 'array'
        chai.expect(data.languages[0]).to.be.an 'object'
        chai.expect(data.languages[0].language).to.be.equal 'en'
        chai.expect(data.languages[0].confidence).to.be.at.least 0.8
        done()

      ins.send 'I believe in you, I know you can guess my language and understand my feelings.'

    it 'should enhance with positive sentiment', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.sentiments).to.be.an 'object'
        chai.expect(data.sentiments.overall).to.be.at.least 0.8
        done()

      ins.send 'I really love you my darling.'

    it 'should enhance with negative sentiment', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.be.an 'object'
        chai.expect(data.sentiments).to.be.an 'object'
        chai.expect(data.sentiments.overall).to.be.at.most -0.1
        done()

      ins.send 'I really do not like onion.'
