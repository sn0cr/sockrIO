utils = require "./utils"
module.exports = class Data
  constructor: (@data) ->
    return if @data.length < 4
    @data = @data.match(utils.R)
    @id = @data[1]
    @type = utils.type(@id)
    @sendCounter = @data[3]
    @receiveCounter = @data[3]
    @dataObject = JSON.parse @data[5] unless  @data[5].length is 0
    @channel = @dataObject?.name?.replace(",", ":")
    @args = @dataObject?.args
  isMessage: =>
    @args? and @channel?
  getData: =>
    @args
  toString: =>
    "#{@type}:#{@id}:#{@sendCounter}:#{@channel}##{JSON.stringify(@args)};#{JSON.stringify @dataObject}"
