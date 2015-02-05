module.exports =
  R: /([\d]+)([:+]+)([\d]*)([:+]*)(.+)/
  type: (id) =>
    return switch id
      when '1' then "Connect"
      when '2' then "KeepAlive"
      when '5' then "BroadCast"
      when '6' then "Receive"
      else id + " Unknown"
