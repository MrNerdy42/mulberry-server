expect = require 'expect.js'
sinon = require 'sinon'

{Screen, Player} = require '../src/client'

describe 'Screen', ->
  myScreen = null
  beforeEach ->
    mockSocket =
      emit: sinon.spy()
      on: sinon.spy()
    myScreen = new Screen mockSocket

  describe '.constructor', ->
    it 'creates a new screen with an empty state', ->
      expect(myScreen.state).to.eql({})

  describe '.update', ->
    it 'assigns data to he state', ->
      myScreen.update({name: 'Ford Prefect'})
      expect(myScreen.state).to.have.property('name')
    it 'emits data to the client', ->
      myScreen.update({name: 'Ford Prefect'})
      expect(myScreen._socket.emit.withArgs 'update', myScreen.state).to.be.ok()

  describe '.sync', ->
    it 'sends the existing state to the client', ->
      myScreen.state = {name: 'Arthur Dent'}
      myScreen.sync()
      expect(myScreen._socket.emit.withArgs 'update', myScreen.state).to.be.ok()

  describe '.reset', ->
    it 'resets the state', ->
      myScreen.state = {name: 'Marvin the Paranoid Android'}
      myScreen.reset()
      expect(myScreen.state).to.eql({})
    it 'emits a reset call', ->
      myScreen.reset()
      expect(myScreen._socket.emit.withArgs 'reset').to.be.ok()

  describe '.migrateSocket', ->
    it 'changes to the new socket', ->
      mockSocket = "I'm a mock socket"
      myScreen.migrateSocket mockSocket
      expect(myScreen._socket).to.be(mockSocket)
