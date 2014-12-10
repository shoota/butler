request = require 'request'

module.exports = (robot) ->
  robot.respond /weather (.*)/i, (msg) ->
    m = msg.match[1]

    if m=='八戸'
      msg.send '八戸の天気を検索いたします'
      id=2129530

    url = 'http://api.openweathermap.org/data/2.5/forecast?id=' + id
    options = 
      url : url
      timeout : 2000

    request options, (error, response, body) ->
      # msg.send body
      list = body.list;
      
    msg.send 'どうぞ'