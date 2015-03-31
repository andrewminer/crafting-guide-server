###
Crafting Guide Server - root.test.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

Harness = require '../harness'

########################################################################################################################

harness = new Harness

########################################################################################################################

describe 'router: ', ->

    before     -> harness.before()
    beforeEach -> harness.beforeEach()

    describe '/ping', ->

        it 'echos back the given message', ->
            harness.client.ping(message:'foo bar').then (response)->
                response.json.message.should.equal 'foo bar'
