utils = require "./utils"

module.exports = class JSONResponse
  constructor: (@data) ->
    @data = @data.match(utils.R)
    @id = @data[1]
    @type = utils.type(@id)
    @receiveCounter = @data[3]

    @dataObject = JSON.parse @data[5] unless  @data[5].length is 0
    @dataObject = @dataObject[0]
    @jsonRPCVersion = @dataObject.jsonrpc
    @error = false
    if @dataObject.result?
      @response = @dataObject.result
    else
      @response = @dataObject.error
      @error = true
  isMessage: =>
    true
  getData: =>
    @response
