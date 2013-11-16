amqp = require 'amqp'
uuid = require 'uuid'
{EventEmitter} = require 'events'

class AmqpQueue extends EventEmitter
  constructor: (options) ->
    @options = JSON.parse JSON.stringify options

  error: (err) =>
    @emit 'error', err

  createConnection: ->
    options = @options.connection or {}
    @connection = amqp.createConnection options

    @connection.once 'error', @error
    @connection.once 'ready', => @emit 'connection.ready'

  createExchange: =>
    options = @options.exchange ?= {}
    options.name ?= 'amqp-eventemitter'
    options.type ?= 'fanout'
    options.autoDelete ?= yes

    @exchange = @connection.exchange options.name, options
    @exchange.on 'error', @error

    setImmediate => @emit 'exchange.ready'

  createQueue: =>
    options = @options.queue ?= {}
    options.name ?= "#{@options.exchange.name}.#{uuid.v4()}"

    @connection.queue options.name, options, (@queue) =>
      @queue.on 'error', @error
      @queue.once 'queueBindOk', => @emit 'queue.ready'
      @queue.bind @exchange, '#{@options.exchange.name}.event'

  subscribe: =>
    promise = @queue.subscribe (message, headers, deliveryInfo) =>
      @emit 'message', message

    promise.addErrback @error

    promise.addCallback =>
      @emit 'amqp-eventemitter.ready'
      @ready = yes

  connect: ->
    @once 'connection.ready', @createExchange
    @once 'exchange.ready', @createQueue
    @once 'queue.ready', @subscribe

    @createConnection()

class AmqpEventEmitter extends EventEmitter
  constructor: (options) ->
    super

    options = connection: options if options.url?
    @queue = new AmqpQueue options
    @queue.connect() unless options.autoConnect is no
    @queue.on 'message', ({type, args}) => EventEmitter::emit.apply @, [type, args...]

  emit: (type, args...) ->
    do wait = =>
      if @queue.ready
        @queue.exchange.publish 'message', {type, args}
      else
        setImmediate wait

module.exports = {AmqpEventEmitter, AmqpQueue}