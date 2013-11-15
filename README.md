# amqp-eventemitter

`EventEmitter` over AMQP. YES!

[![Dependency status](https://david-dm.org/goodeggs/amqp-eventemitter.png)](https://david-dm.org/goodeggs/amqp-eventemitter) [![Build Status](https://travis-ci.org/goodeggs/amqp-eventemitter.png)](https://travis-ci.org/goodeggs/amqp-eventemitter)

## Install

    npm install amqp-eventemitter

## Test

Tests connect to locally running AMQP (such as RabbitMQ, `brew install rabbitmq`).

    npm test

## Usage

```coffeescript
{AmqpEventEmitter} = require 'amqp-eventemitter'

pub = new AmqpEventEmitter url: 'amqp://guest:guest@localhost:5672'
sub = new AmqpEventEmitter url: 'amqp://guest:guest@localhost:5672'

sub.on 'message', (arg1, arg2) -> console.log arg1, arg2
pub.emit 'message', 'hello', 'world'

#=> hello world
```

## API

### new AmqpEventEmitter(options)

`options` are passed directly to [`node-amqp`](https://github.com/postwait/node-amqp) with exception of:

- `exchange` name for the event emitter, which defaults to `amqp-eventemitter`. The exchange name is also used for the `ready` event when AMQP connection is made, as in `[options.exchange].ready`

## Notes

- **Each** instance of `AmqpEventEmitter` receives each emitted event.
- You can immediately emit events without waiting for AMQP connection.
- `amqp-eventemitter.ready` is emitted when connection is actually made.

## License

The MIT License (MIT)

Copyright (c) 2013 Good Eggs Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.