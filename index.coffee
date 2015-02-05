Client = require './lib/RPCClient'
port = 3000
host = "    "

c = new Client(host, port)
c.call "method", ["funny", "yo!"], (d) ->
  console.log d.getData()
  process.exit()
