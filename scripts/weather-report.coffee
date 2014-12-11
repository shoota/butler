module.exports = (robot) ->
  WEATHER_ID = 'weather_id'

  getIDs = () ->
    return robot.brain.get(WEATHER_ID) or {}

  listGeo = (msg) ->
    source = getIDs()
    list_msg = ''
    for key, val of source
      list_msg = list_msg + "#{key} : #{val} \n"
    msg.send list_msg

  robot.hear /add_geo (.*)/i, (msg) ->
    cmd = msg.match[1].split(/\ /)
    key = cmd[0]
    val = cmd[1]
    if key!=undefined && val!=undefined
      source = getIDs()
      source[key] = val
      robot.brain.set WEATHER_ID, source
      msg.send 'add id done.'
    else
      msg.send 'sorry, your message wrong.'

  robot.hear /li_geo/i, (msg) ->
    listGeo(msg)

  robot.hear /rm_geo (.*)/i, (msg) ->
    target = msg.match[1]
    source = getIDs()
    new_source = {}
    for key, val of source
      if key != target
        new_source[key] = val
      else
        msg.send "find and remove #{target}"
    robot.brain.set WEATHER_ID, new_source
    msg.send "new list"
    listGeo(msg)


  robot.respond /weather (.*)/i, (msg) ->
    m = msg.match[1]
    url = 'http://api.openweathermap.org/data/2.5/forecast?id=' + id
    request = msg.http(url).get()
    request (err, res, body) ->
      json = JSON.parse body
      msg.send json.list[0].dt