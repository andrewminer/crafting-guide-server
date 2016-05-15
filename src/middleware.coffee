#
# Crafting Guide - middleware.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

bodyParser            = require 'body-parser'
clientSession         = require 'client-sessions'
GitHubClient          = require './models/github_client'
status                = require './http_status'
store                 = require './store'
{CraftingGuideClient} = require 'crafting-guide-common'
{Logger}              = require 'crafting-guide-common'

User = store.definitions.User

########################################################################################################################

global.logger ?= new Logger

########################################################################################################################

exports.addPrefixes = (app)->
    app.use(m) for m in [
        approveOrigin
        registerFinalizers
        bodyParser.json
            limit: '1024kb'
        clientSession
            cookieName: CraftingGuideClient.SESSION_COOKIE
            duration: 1000 * 60 * 60 * 24 * 7 * 2 # 2 weeks in ms
            secret: 'CKpyGnY2C(]@Z38u'
            cookie:
                domain: '.crafting-guide.com'
                httpOnly: false
                secure: false
        unpackCurrentUser
        logRequest
        addApiResponseMethod
    ]

exports.addSuffixes = (app)->
    app.get '*', (request, response)->
        request.api -> status.notFound.throw "unknown API endpoint: #{request.path}"
    app.use reportError

addApiResponseMethod = (request, response, next)->
    response.api = ((req, res)-> return (v)->
        if _.isFunction(v)
            promise = w.try(v)
        else
            promise = w(v)

        result = null
        promise
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
        response.set 'Access-Control-Allow-Methods', request.headers['access-control-request-methods']
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
    request.gitHubClient = new GitHubClient

    if request.session?.userId?
        User.find request.session.userId
            .then (user)->
                if user?
                    request.user = user
                    request.gitHubClient.accessToken = user.gitHubAccessToken
                next()
    else
        next()

# Optional Middleware ##################################################################################################

exports.requireLogin = (request, response, next)->
    if not request.user?.gitHubAccessToken?
        writeErrorResponse { statusCode:status.unauthorized, message:'Not logged in' }, request, response
    else
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
        if request.user?
            user.gitHubAccessToken = null
            User.save user
                .catch (error)-> logger.error -> "Could not clear user access token: #{error.stack}"
        if request.session?
            request.session.userId = null

    result = {status:'error', message:error.message}
    result.data = error.data if error.data?
    result.stack = error.stack if request.app.env in ['test' or 'local']

    writeResponse request, response, statusCode, result

writeResponse = (request, response, statusCode, result)->
    logger.verbose -> "writing result: #{statusCode} #{util.inspect(result, depth:10)}"
    response.status(statusCode).json result
    runFinalizers request, response

writeSuccessResponse = (result, request, response)->
    if result is null then result = { message:'ok' }
    if _.isString result then result = { message:result }

    writeResponse request, response, status.ok, result
