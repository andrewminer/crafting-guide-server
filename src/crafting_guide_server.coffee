###
Crafting Guide Server - server.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

express    = require 'express'
http       = require 'http'
middleware = require './middleware'

########################################################################################################################

global.logger ?= new Logger

module.exports = class CraftingGuideServer

    constructor: (port, env)->
        if not port? then throw new Error 'port is mandatory'
        if not env? then throw new Error 'env is mandatory'

        @expressApp = express()
        @port       = port

        @expressApp.env = env

        middleware.addPrefixes @expressApp
        @expressApp.use '/', require './routers/root'
        @expressApp.use '/github', require './routers/github'
        middleware.addSuffixes @expressApp

        @httpServer = http.createServer @expressApp

    start: ->
        deferred = w.defer()
        @httpServer.once 'error', (e)-> deferred.reject e
        @httpServer.listen @port, =>
            logger.warning "Crafting Guide Server is listening on port #{@port}"
            deferred.resolve this
        return deferred.promise

    stop: ->
        w.promise (resolve, reject)=>
            logger.warning "Crafting Guide Server is shutting down" unless @expressApp.env is 'test'
            @httpServer.close -> resolve this
