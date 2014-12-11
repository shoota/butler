moment = require 'moment'

module.exports = (robot) ->
  WEATHER_ID = 'weather_id'
  KELVIN = 273.15

  getIDs = () ->
    return robot.brain.get(WEATHER_ID) or {}

  getID = (k) ->
    all = getIDs()
    for key, val of all
      if key == k
        return val
    return 0

  listGeo = (msg) ->
    source = getIDs()
    list_msg = "now list : \n"
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
    listGeo(msg)


  robot.respond /weather (.*)/i, (msg) ->
    id = getID(msg.match[1])
    if id==0
      msg.send 'do not find id.'
      return

    url = 'http://api.openweathermap.org/data/2.5/forecast?id=' + id
    request = msg.http(url).get()
    request (err, res, body) ->
      json = JSON.parse body
      voice = '現在からの天気です\n';

      for obj, i in json.list
        if i>10
          break
        d = moment.unix(obj.dt).format("MM/DD HH時")
        weather = obj.weather[0].description
        temp = obj.main.temp - KELVIN
        temp = String(temp).substring(0, 4)
        humidity = obj.main.humidity
        # iconUrl = 'http://openweathermap.org/img/w/' + obj.weather[0].icon + '.png'
        w_speed = obj.wind.speed
        if obj.rain?
          weather = weather+' 降雨量: '+obj.rain["3h"]+'mm'
        if obj.snow?
          weather = weather+' 降雪量: '+obj.snow["3h"]+'mm'
        voice = voice+d+'  '+weather+' 気温: '+temp+'度, 湿度:'+humidity+'%, 風速: '+w_speed+'m/s\n'
      msg.send voice
