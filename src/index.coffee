express = require 'express'
app = express()
http = require( 'http' ).Server app
io = require( 'socket.io' ) http
fs = require 'fs'
path = require 'path'
_ = require 'lodash'
uuid = require 'uuid'

{Screen, Player} = require './client'

players = []
screen = undefined

updateScreen = (data) ->
  screen.update data if screen?

updateAll = (data) ->
  updateScreen data
  _.forEach players, (player) ->
    player.update data

reset = () ->
  screen.reset() if screen?
  _.forEach players, (player) ->
    player.reset()

# Creates a server, and binds actions that are common to all players
serve = (playerActions = {}) ->
  # If there is a config file present, load it and use it to initialize some
  # constants.
  config = null
  if fs.existsSync 'mulberry.config.js'
    config = module.parent.require './mulberry.config'

  buildDir = if config? and config.buildDir? then config.buildDir else 'build'
  app.use express.static buildDir

  entryPage = if config? and config.entry? then config.entry else 'index.html'
  app.get '/', (req, res) ->
    res.sendFile path.join process.cwd(), buildDir, entryPage

  playerPage = if config? and config.player then config.player else 'player.html'
  app.get /[A-Z]{4}/, (req, res) ->
    res.sendFile path.join process.cwd(), buildDir, playerPage

  # When a socket connects
  io.on 'connection', (socket) ->
    
    # If it is a player, bind the common player actions
    socket.on 'player', data ->
      # If the client sends an id, see if it is associated with an existing player.
      # If so, migrate the socket and sync the client, else make a new player
      player = if data? then _.find players, _.matchesProperty 'uuid', data else null
      if player?
        player.migrateSocket socket
        player.sync()
      else
        player = new Player socket, id
        players.push player
        _.forIn playerActions, (fn, action) ->
          player.on action, fn
        
    # If it is the screen, just save the ref
    socket.on 'screen', ->
      id = uuid.v4()
      socket.emit 'uuid', id
      screen = new Screen socket, id
      
  # Launch the server
  port = if config? and config.port? then config.port else 8080
  http.listen port, ->
    console.log 'Listening on port %d.', port

  # Return emit and on functions for additional configuration
  return
    emit: io.emit.bind io
    on: io.on.bind io

module.exports = {
  serve
  players
  updateScreen
  updateAll
  reset
}
