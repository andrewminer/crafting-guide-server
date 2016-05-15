#
# Crafting Guide - root.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

Harness = require '../../test/harness'

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
