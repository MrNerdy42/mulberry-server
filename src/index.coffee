express = require 'express'
app = express()
http = require( 'http' ).Server app
io = require( 'socket.io' ) http
fs = require 'fs'
path = require 'path'
_ = require 'lodash'
uuid = require 'uuid'

players = {}
gameboard = ''

serve = (registerPlayerActions = _.noop) ->
  config = null
  if fs.existsSync 'mulberry.config.json'
    config = JSON.parse fs.readFileSync 'mulberry.config.json', 'utf8'

  buildDir = if config? and config.buildDir? then config.buildDir else 'build'
  app.use express.static buildDir

  entry = if config? and config.entry? then config.entry else 'index.html'
  app.get '/', (req, res) ->
    res.sendFile path.join process.cwd(), buildDir, entry

  player = if config? and config.player then config.player else 'player.html'
  app.get /[A-Z]{4}/, (req, res) ->
    res.sendFile path.join process.cwd(), buildDir, player

  io.on 'connection', (socket) ->
    id = uuid.v4()
    socket.emit 'uuid', id
    players[id] =
      socket: socket 
    socket.on 'player', ->
      registerPlayerActions socket
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
