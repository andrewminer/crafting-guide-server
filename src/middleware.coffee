###
Crafting Guide Server - middleware.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

GitHubClient          = require './models/github_client'
bodyParser            = require 'body-parser'
clientSession         = require 'client-sessions'
status                = require './http_status'
{CraftingGuideClient} = require 'crafting-guide-common'
{Logger}              = require 'crafting-guide-common'

########################################################################################################################

global.logger ?= new Logger

########################################################################################################################

exports.addPrefixes = (app)->
    app.use(m) for m in [
        approveOrigin
        registerFinalizers
        bodyParser.json()
        clientSession
            cookieName: CraftingGuideClient.SESSION_COOKIE
            duration: 1000 * 60 * 60 * 24 * 7 * 2 # 2 weeks in ms
            secret: 'CKpyGnY2C(]@Z38u'
        unpackCurrentUser
        logRequest
        addApiResponseMethod
    ]

exports.addSuffixes = (app)->
    app.get '*', (request, response)->
        request.api -> status.notFound.throw "unknown request: #{request.path}"
    app.use reportError

addApiResponseMethod = (request, response, next)->
    response.api = ((req, res)-> return (value)->
        if _.isFunction(value) then value = value()
        promise = w(value)
        result = null
        w(promise)
            .then (r)-> result = r
            .timeout 60000, new Error 'Timed out while answering request'
            .then -> writeSuccessResponse result, req, res
            .catch (error)-> writeErrorResponse error, req, res
    )(request, response)
    next()

approveOrigin = (request, response, next)->
    origin = request.headers.origin
    if origin? and origin.match /^http:\/\/([a-z]{1,7}\.)?crafting-guide\.com(:[0-9]{1,4})?/
        response.set 'Access-Control-Allow-Origin', origin
        response.set 'Access-Control-Allow-Credentials', 'true'
        response.set 'Access-Control-Allow-Methods', request.headers['access-control-request-method']
        response.set 'Access-Control-Allow-Headers', request.headers['access-control-request-headers']

    if request.method is 'OPTIONS'
        response.end()
    else
        next()

logRequest = (request, response, next)->
    account = request.session?.account

    logger.verbose -> ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    logger.info    -> "HTTP #{request.httpVersion} #{request.method} #{request.originalUrl}"
    logger.verbose -> "*** user:    #{request?.user?.name} <#{request?.user?.email}>"
    logger.verbose -> "*** headers: #{_.pp(request.headers)}"
    logger.verbose -> "*** params:  #{_.pp(request.params)}"
    logger.verbose -> "----------"

    start = Date.now()
    response.finalizers.push (request, response)->
        logger.verbose -> "----------"
        logger.verbose -> "*** session: #{_.pp(request.session)}"
        logger.info ->
            duration = Date.now() - start
            resultLine = "Responded: #{response.statusCode} after #{duration}ms"
            if response.result?
                length = response.result.length; unit = 'B'
                if length > 1024 then length /= 1024; unit = 'kB'
                if length > 1024 then length /= 1024; unit = 'MB'
                resultLine += " with #{length}#{unit} of data"
            return resultLine

    next()

registerFinalizers = (request, response, next)->
    response.finalizers = []
    next()

reportError = (error, request, response, next)->
    logger.error "Caught unexpected error: #{error.message}:\n#{error.stack}"
    writeErrorResponse error, request, response
    runFinalizers request, response

unpackCurrentUser = (request, response, next)->
    request.user = request.session?.user
    request.gitHubClient = new GitHubClient accessToken:request.session?.accessToken, user:request.user

    next()

# Optional Middleware ##################################################################################################

exports.requireLogin = (request, response, next)->
    if not request.session?.accessToken?
        status.unauthorized.throw 'you must be logged in to use this API'
    next()

# Helper Functions #####################################################################################################

runFinalizers = (request, response)->
    processRemaining = (finalizers)->
        return if finalizers.length is 0
        w.try finalizers[0], request, response
            .catch (e)-> logger.error -> "Error while running finalizers: #{e.message}\n#{e.stack}"
            .then -> processRemaining _.rest finalizers
    processRemaining response.finalizers.reverse()

writeErrorResponse = (error, request, response)->
    statusCode = if error.statusCode? then error.statusCode else status.internalServerError
    if statusCode is status.internalServerError
        logger.error "Unexpected internal error: #{error.stack}"
    if statusCode is status.unauthorized
        if request.session?
            request.session.accessToken = null
            request.session.user = null

    result = {status:'error', message:error.message}
    result.data = error.data if error.data?
    result.stack = error.stack if request.app.env in ['test' or 'development']

    writeResponse request, response, statusCode, result

writeResponse = (request, response, statusCode, result)->
    logger.verbose -> "writing result: #{statusCode} #{util.inspect(result, depth:10)}"
    response.status(statusCode).json result
    runFinalizers request, response

writeSuccessResponse = (result, request, response)->
    if _.isString result then result = {message:result}
    result           ?= {}
    result.data      ?= null
    result.message   ?= 'ok'
    result.status    ?= 'success'

    writeResponse request, response, status.ok, result
