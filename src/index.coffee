amqp = require 'amqp'
uuid = require 'uuid'
{EventEmitter} = require 'events'

class AmqpEventEmitter extends EventEmitter
  constructor: (@opts) ->
    super

    @_emit = => EventEmitter::emit.apply @, arguments
    @ready = no
    @opts.exchange ?= 'amqp-eventemitter'

    @connection = amqp.createConnection @opts

    @connection.on 'error', @error

    @connection.once 'ready', =>
      @exchange = @connection.exchange @opts.exchange, type: 'fanout', autoDelete: yes
      @exchange.on 'error', @error

      @connection.queue "#{opts.exchange}.#{uuid.v4()}", (queue) =>
        queue.on 'error', @error

        queue.on 'queueBindOk', =>
          promise = queue.subscribe ({type, args}, headers, deliveryInfo) =>
            @_emit type, args...

          promise.addErrback @error

          promise.addCallback =>
            @_emit "#{@opts.exchange}.ready"
            @ready = yes

        queue.bind @exchange, 'message'

  error: (err) =>
    @_emit 'error', err

  emit: (type, args...) ->
    do wait = =>
      if @ready
        @exchange.publish 'message', {type, args}
      else
        setImmediate wait

module.exports = {AmqpEventEmitter}