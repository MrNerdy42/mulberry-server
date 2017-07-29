_ = require 'lodash'

class Screen
  constructor: (@_socket, @uuid) ->
    @state = {}

  update: (data) ->
    _.assign @state, data
    @_socket.emit 'update', data

class Player extends Screen
  on: (action, fn) ->
    @_socket.on action, ((data) ->
      fn @, data
    ).bind @

module.exports = {
  Screen
  Player
}
