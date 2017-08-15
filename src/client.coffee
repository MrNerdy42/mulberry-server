_ = require 'lodash'

class Screen
  constructor: (@_socket) ->
    @state = {}

  update: (data) ->
    _.assign @state, data
    @_socket.emit 'update', data

  sync: ->
    @_socket.emit 'update', @state

  reset: ->
    @state = {}
    @_socket.emit 'reset'

  migrateSocket: (@_socket) ->
    
class Player extends Screen
  constructor: (@_socket, @uuid) ->
    @state = {}
    
  on: (action, fn) ->
    @_socket.on action, ((data) ->
      fn @, data
    ).bind @

module.exports = {
  Screen
  Player
}
