###
Crafting Guide Server - admin.test.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

Harness = require '../harness'

########################################################################################################################

harness = new Harness

########################################################################################################################

describe 'admin router', ->

    before     -> harness.before()
    beforeEach -> harness.beforeEach()
    after      -> harness.after()

    describe 'ping', ->

        it 'echos back the given message', ->
            harness.client.ping(message:'foo bar').then (response)->
                logger.debug "response: #{util.inspect(response)}"
                response.json.message.should.equal 'foo bar'