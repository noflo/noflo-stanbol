noflo = require 'noflo'
request = require 'request'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'cog'
  c.description = 'Enhance a given text with semantic data.'

  c.inPorts.add 'in',
    datatype: 'string'
    description: 'Text to be enhanced.'
  c.inPorts.add 'url',
    datatype: 'string'
    description: 'URL to Apache Stanbol.'
  c.inPorts.add 'chain',
    datatype: 'string'
    description: 'Enhancer chain.'
  c.outPorts.add 'out',
    datatype: 'string'

  noflo.helpers.WirePattern c,
    in: ['in']
    params: ['url', 'chain']
    out: ['out']
    forwardGroups: true
  , (payload, groups, out, callback) ->
    url =  if c.params.url then c.params.url else 'http://localhost:8080'
    chain = if c.params.chain then c.params.chain else 'default'
    postURL = "#{url}/enhancer/chain/#{chain}"
    text = payload

    result =
      languages: []
      sentiments: {}

    request.post
      url: postURL
      headers:
        'accept': 'application/json'
        'content-type': 'text/plain'
      body: text
    , (err, response, body) ->
      json = JSON.parse body
      graph = json['@graph']
      if graph?
        for entity in graph
          if entity.type is 'LinguisticSystem'
            result.languages.push
              language: entity.language
              confidence: entity.confidence
          else if 'DocumentSentiment' in entity.type
            result.sentiments =
              overall: if entity.sentiment then entity.sentiment else 0
              positive: if entity['positive-sentiment'] then entity['positive-sentiment'] else 0
              negative: if entity['negative-sentiment'] then entity['negative-sentiment'] else 0

      out.send result

  c
