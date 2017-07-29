_ = require 'lodash'

class Player
  constructor: (@_socket, @uuid) ->
    @state = {}

  update: (data) ->
    _.assign @state, data
    @_socket.emit 'update', data

  on: (action, fn) ->
    @_socket.on action, (data) ->
      fn @, data

module.exports = Player

