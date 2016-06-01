#
# Crafting Guide - harness.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

CraftingGuideServer   = require '../src/crafting_guide_server'
middleware            = require '../src/middleware'
store                 = require '../src/store'
{CraftingGuideClient} = require 'crafting-guide-common'

########################################################################################################################

PORT     = 18181
BASE_URL = "http://localhost:#{PORT}"

########################################################################################################################

module.exports = class Harness

    _server         = null
    _serverStarting = null

    constructor: ->
        @client         = null
        @serverStarting = null
        @server         = null

    before: ->
        if not _serverStarting?
            _server = new CraftingGuideServer PORT, 'test'
            _serverStarting = _server.start()

        @server = _server
        @serverStarting = _serverStarting
        return @serverStarting

    beforeEach: ->
        @client = new CraftingGuideClient baseUrl:BASE_URL
        @db = store.getAdapter('sql').query

    login: (options={})->
        options.userId ?= _.uniqueId('user-')
        options.gitHubAccessToken ?= _.uniqueId('github-access-token-')
        middleware.injectTestUser options
