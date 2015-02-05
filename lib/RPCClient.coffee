Client = require './client'
module.exports = class RPCClient
  constructor: (host, port) ->
    @id = 1
    @client = new Client()
    @eventEmitter = @client.eventEmitter
    @connected = false
    @queue = []
    @client.connect host, port, =>
      @connected = true
      # Threading???
      for element in @queue
        @client.send element.channel, element.data, element.callback
      @queue = []

  on: (channel, cl) =>
    @eventEmitter.on channel, cl
  close: =>
    @client.close()
  call: (method, args, cl) =>
    args = [args] unless Array.isArray(args)
    data =
      id: @id
      jsonrpc: "2.0"
      method: method
      params: args
    @send method, data, cl

    @id += 1

  send: (channel, data, cl) =>
    if @connected
      @client.send channel, data, cl
    else
      @queue.push
        channel: channel
        data: data
        callback: cl
