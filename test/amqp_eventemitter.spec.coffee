# use compiled JS file
{AmqpEventEmitter} = require '../lib'

require 'coffee-errors'

chai = require 'chai'
sinon = require 'sinon'

chai.use require 'sinon-chai'

expect = chai.expect

waitsFor = (predicate, done) ->
  do wait = -> if predicate() then done() else setImmediate wait

describe 'AmqpEventEmitter', ->
  for runIndex in [1..5]
    describe "run #{runIndex}", ->
      pub = null
      sub = null
      pubReady = null
      subReady = null

      before ->
        pub = new AmqpEventEmitter url: 'amqp://guest:guest@localhost:5672'
        sub = new AmqpEventEmitter url: 'amqp://guest:guest@localhost:5672'

        pub.on 'amqp-eventemitter.ready', pubReady = sinon.spy()
        sub.on 'amqp-eventemitter.ready', subReady = sinon.spy()

      describe 'immediate availability', ->
        it 'can subscribe', ->
          sub.on 't1', -> throw new Error 'test-event fired'

        it 'can emit', ->
          pub.emit 't2', 'arg1', 'arg2'

      describe 'when connected', ->
        spy = null

        before (done) ->
          waitsFor (-> pubReady.callCount and subReady.callCount), done

        it 'can subscribe', ->
          spy = sinon.spy()
          sub.on 'message', spy

        it 'can emit', (done) ->
          pub.emit 'message', 'arg1', 'arg2'
          waitsFor (-> spy.callCount), done

        it 'passes arguments from emitter to subscriber', ->
          expect(spy).to.have.been.calledWith 'arg1', 'arg2'

        describe 'rapid publising', ->
          receipts = {}
          counter = 0

          it 'publishes 10 times', (done) ->
            sub.on 'foo', ({index}) ->
              receipts[index] = yes
              done() if ++counter is 10

            for index in [1..10]
              pub.emit 'foo', {index}

          it 'published 10 times', ->
            expect(counter).to.eql 10

          it 'received all published events', ->
            for index in [1..10]
              expect(receipts[index]).to.equal yes
