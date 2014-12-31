moment = require 'moment'

module.exports = (robot) ->

  robot.hear /camera/i, (msg) ->
    exec = require('child_process').exec
    exec('/home/pi/rp_still.sh')
    msg.send 'ok :camera:'
