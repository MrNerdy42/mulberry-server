express = require 'express'
app = express()
http = require( 'http' ).Server app
io = require( 'socket.io' ) http
fs = require 'fs'
path = require 'path'
_ = require 'lodash'
uuid = require 'uuid'

Player = require './player'

players = []
gameboard = ''

serve = (playerActions = {}) ->
  config = null
  if fs.existsSync 'mulberry.config.json'
    config = JSON.parse fs.readFileSync 'mulberry.config.json', 'utf8'

  buildDir = if config? and config.buildDir? then config.buildDir else 'build'
  app.use express.static buildDir

  entryPage = if config? and config.entry? then config.entry else 'index.html'
  app.get '/', (req, res) ->
    res.sendFile path.join process.cwd(), buildDir, entryPage

  playerPage = if config? and config.player then config.player else 'player.html'
  app.get /[A-Z]{4}/, (req, res) ->
    res.sendFile path.join process.cwd(), buildDir, playerPage

  io.on 'connection', (socket) ->
    id = uuid.v4()
    socket.emit 'uuid', id
    player = new Player socket, id
    players.push player
    socket.on 'player', ->
      _.forIn playerActions, (fn, action) ->
        console.log 'Binding fn for action ' + action
        player.on action, fn
    socket.on 'screen', ->
      gameboard = id

  port = if config? and config.port? then config.port else 8080
  http.listen port, ->
    console.log 'Listening on port %d.', port

  return
    emit: io.emit.bind io
    on: io.on.bind io

module.exports =
  serve: serve
  players: players
