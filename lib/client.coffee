WebSocket = require('ws')
request = require('request')
Data = require './data'
JSONResponse = require './jsonResponse'
EventEmitter2 = require('eventemitter2').EventEmitter2

module.exports = class Client
  constructor: ->
    # initialize EventEmitter
    @eventEmitter = new EventEmitter2
      wildcard: true
      delimiter: ':'
      newListener: false
      maxListeners: 20
    @counter = 0
    @callBacks = {}
  connect: (host, port, cl)  =>
    @getToken "http://#{host}:#{port}", (token) =>
      socket_io_url = "ws://#{host}:#{port}/socket.io/1/websocket/#{token}"
      @ws = new WebSocket(socket_io_url)
      @ws.on 'open', => cl @
      @ws.on 'close', -> console.log "ws closed"
      @ws.on 'message', (data, flags) =>
        # send ping back (around every 25secs)
        if data is "2::"
          @ws.send "2::"
          return
        dataCounter = /6:::(\d+)+/.exec(data)
        if dataCounter? and @callBacks.hasOwnProperty(dataCounter[1])
          data = new JSONResponse(data)
          @callBacks[dataCounter[1]](data)
          delete @callBacks[dataCounter[1]]
        else if (data.indexOf("jsonrpc") > -1)
          # TODO possible attacking point
          data = new JSONResponse(data)
        else
          # broadcast
          data = new Data(data)
          if data.isMessage()
            @eventEmitter.emit(data.channel, data.getData()...)
  sendKeepAlive: =>
    @ws.send
  close: =>
    @ws?.close()
  getToken: (url, cl) ->
    timeStamp = (new Date).getTime()
    request.get {url: url, jar: true}, (err, httpResponse, body) ->
      request.post {url: url + "/socket.io/1/?t=#{timeStamp}", jar: true}, (err, httpResponse, body) ->
        if body?
          cl body.split(":")[0]
        else
          console.warn "Got no token - is your socket.io server running?"

  send: (channel, data, cl) =>
    prefix = "5:#{@counter}+::"
    data = [data] unless Array.isArray data
    @callBacks[@counter] = cl if cl?
    data = prefix + JSON.stringify
      name: channel
      args: data
    @ws.send data
    @counter += 1
