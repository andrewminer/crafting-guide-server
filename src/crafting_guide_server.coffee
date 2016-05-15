#
# Crafting Guide - crafting_guide_server.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

express    = require 'express'
http       = require 'http'
middleware = require './middleware'
{Logger}   = require 'crafting-guide-common'

########################################################################################################################

global.logger ?= new Logger

module.exports = class CraftingGuideServer

    constructor: (port, env)->
        if not port? then throw new Error 'port is mandatory'
        if not env? then throw new Error 'env is mandatory'

        @expressApp = express()
        @port       = port
        @env        = env

        @expressApp.env = env
        @expressApp.disable 'etag'

        middleware.addPrefixes @expressApp
        @expressApp.use '/', require './routers/root'
        @expressApp.use '/github', require './routers/github'
        @expressApp.use '/modBallot', require './routers/mod_ballots'
        @expressApp.use '/users', require './routers/users'
        middleware.addSuffixes @expressApp

        @httpServer = http.createServer @expressApp

    start: ->
        deferred = w.defer()
        @httpServer.once 'error', (e)-> deferred.reject e
        @httpServer.listen @port, =>
            logger.warning "Crafting Guide Server is listening on port #{@port} in the #{@env} environment"
            deferred.resolve this
        return deferred.promise

    stop: ->
        w.promise (resolve, reject)=>
            logger.warning "Crafting Guide Server is shutting down" unless @expressApp.env is 'test'
            @httpServer.close -> resolve this
