###
Crafting Guide Server - github_client.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

HttpStatus = require '../http_status'
{http}     = require 'crafting-guide-common'

########################################################################################################################

module.exports = class GitHubClient

    @API_BASE_URL: 'https://api.github.com'
    @BASE_URL:     'https://github.com'

    constructor: (options={})->
        options.accessToken  ?= null
        options.apiBaseUrl   ?= GitHubClient.API_BASE_URL
        options.baseUrl      ?= GitHubClient.BASE_URL
        options.clientId     ?= process.env.GITHUB_CLIENT_ID
        options.clientSecret ?= process.env.GITHUB_CLIENT_SECRET
        options.timeout      ?= 60000

        _.extend this, _.pick options, 'accessToken', 'apiBaseUrl', 'baseUrl', 'clientId', 'clientSecret', 'timeout'

        @_headers =
            'Accept':     'application/json'
            'User-Agent': 'Crafting Guide Server'

        if not @clientId? then throw new Error "A GitHub Client ID must be provided"
        if not @clientSecret? then throw new Error "A GitHub Client Secret must be provided"

    # GitHub File Calls ############################################################################

    fetchFile: (owner, repo, path)->
        @_requireAuthorization()

        http.get "#{@apiBaseUrl}/repos/#{owner}/#{repo}/contents/#{path}", headers:@_headers
            .timeout @timeout
            .then (response)=>
                data = @_parseResponse response
                return result =
                    content: new Buffer(data.content, 'base64').toString('utf8')
                    sha: data.sha
            .catch (error)=>
                if error instanceof w.TimeoutError
                    HttpStatus.gatewayTimeout.throw 'GitHub failed to respond'
                else
                    HttpStatus.badGateway.throw error.message, {}, error

    updateFile: (owner, repo, path, message, content, sha)->
        @_requireAuthorization()

        content = new Buffer(content, 'utf8').toString('base64')
        body = message:message, content:content, sha:sha
        http.put "#{@apiBaseUrl}/repos/#{owner}/#{repo}/contents/#{path}", headers:@_headers, body:body
            .timeout @timeout
            .then (response)=>
                @_parseResponse response
                return null
            .catch (error)=>
                if error instanceof w.TimeoutError
                    HttpStatus.gatewayTimeout.throw 'GitHub failed to respond'
                else
                    HttpStatus.badGateway.throw error.message, {}, error

    # GitHub Login Calls ###########################################################################

    completeLogin: (code)->
        if not code? then return w.reject throw new Error 'code is required'

        body = client_id:@clientId, client_secret:@clientSecret, code:code
        http.post "#{@baseUrl}/login/oauth/access_token", headers:@_headers, body:body
            .timeout @timeout
            .then (response)=>
                data = @_parseResponse response
                if not data.access_token?
                    throw new Error "GitHub request failed: No access code included in body: #{response.body}"
                @accessToken = data.access_token
                return null
            .catch (error)=>
                if error instanceof w.TimeoutError
                    HttpStatus.gatewayTimeout.throw 'GitHub failed to respond'
                else
                    HttpStatus.badGateway.throw error.message, {}, error

    # GitHub User Calls ############################################################################

    fetchCurrentUser: ->
        @_requireAuthorization()
        http.get "#{@apiBaseUrl}/user", headers:@_headers
            .timeout @timeout
            .then (response)=>
                data = @_parseResponse response
                user = _.pick data, 'avatar_url', 'email', 'login', 'name'
                return user
            .catch (error)=>
                if error instanceof w.TimeoutError
                    HttpStatus.gatewayTimeout.throw 'GitHub failed to respond'
                else
                    HttpStatus.badGateway.throw error.message, {}, error

    # Private Methods ##############################################################################

    _parseResponse: (response)->
        logger.verbose "GitHub response: #{_.ellipsize(_.pp(response), 1024)}"

        if response.statusCode is 404
            HttpStatus.notFound.throw "GitHub could not find the requested resource"

        try
            data = JSON.parse response.body
        catch error
            HttpStatus.badGateway.throw "Could not parse GitHub's response (#{error}): #{_.ellipsize(response.body)}"

        if response.statusCode is 401
            HttpStatus.unauthorized.throw "GitHub credentials were not accepted: #{data.message}"
        else if 300 <= response.statusCode < 500
            HttpStatus.internalServerError.throw "Unexpected problem communicating with GitHub: #{data.message}"
        else if response.statusCode >= 500
            HttpStatus.badGateway.throw "GitHub encountered a problem with the request: #{data.message}"

        return data

    _requireAuthorization: ->
        if not @accessToken? then throw new Error "user must be logged in first"
        @_headers['Authorization'] = "token #{@accessToken}"
