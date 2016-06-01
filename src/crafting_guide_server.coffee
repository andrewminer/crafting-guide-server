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
        @expressApp.use '/modBallot', require './routers/mod_ballot'
        @expressApp.use '/modVotes', require './routers/mod_votes'
        @expressApp.use '/users', require './routers/users'
        middleware.addSuffixes @expressApp

        @httpServer = http.createServer @expressApp

    start: ->
        w.promise (resolve, reject)=>
            @httpServer.once 'error', (e)->
                logger.error -> "Crafting Guide Server failed to start: #{e}"
                reject e

            @httpServer.listen @port, (error)=>
                if error?
                    reject error
                    return

                logger.warning => "Crafting Guide Server is listening on port #{@port} in the #{@env} environment"
                @httpServer.on 'error', (e)->
                    logger.error -> "Crafting Guide Server encountered an error: #{e}"

                resolve this

    stop: ->
        w.promise (resolve, reject)=>
            logger.warning => "Crafting Guide Server is shutting down" unless @expressApp.env is 'test'
            @httpServer.once 'error', -> reject error
            @httpServer.close => resolve this
