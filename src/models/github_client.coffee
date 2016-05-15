#
# Crafting Guide - github_client.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

HttpStatus = require '../http_status'
{http}     = require 'crafting-guide-common'
{Repo}     = require '../constants'

########################################################################################################################

module.exports = class GitHubClient

    @API_BASE_URL: 'https://api.github.com'
    @BASE_URL:     'https://github.com'

    constructor: (options={})->
        options.accessToken  ?= null
        options.adminToken   ?= process.env.GITHUB_ADMIN_TOKEN
        options.apiBaseUrl   ?= GitHubClient.API_BASE_URL
        options.baseUrl      ?= GitHubClient.BASE_URL
        options.clientId     ?= process.env.GITHUB_CLIENT_ID
        options.clientSecret ?= process.env.GITHUB_CLIENT_SECRET
        options.timeout      ?= 60000

        _.extend this, _.pick options,
            'accessToken', 'adminToken', 'apiBaseUrl', 'baseUrl', 'clientId', 'clientSecret', 'timeout'

        @_headers =
            'Accept':     'application/json'
            'User-Agent': 'Crafting Guide Server'

        if not @clientId? then throw new Error "A GitHub Client ID must be provided"
        if not @clientSecret? then throw new Error "A GitHub Client Secret must be provided"

    # GitHub Collaborator Calls ####################################################################

    isCollaborator: (owner, repo, login)->
        @_requireAdmin()

        promise = http.get "#{@apiBaseUrl}/repos/#{owner}/#{repo}/collaborators/#{login}", headers:@_headers
            .timeout @timeout
            .then (response)=>
                @_parseResponse response
                return true
            .catch (error)->
                return false if error.statusCode is HttpStatus.notFound
                throw error

        return @_handleErrors promise

    addCollaborator: (owner, repo, login)->
        @_requireAdmin()

        headers = _.extend {'Content-Length', 0}, @_headers
        promise = http.put "#{@apiBaseUrl}/repos/#{owner}/#{repo}/collaborators/#{login}", headers:@_headers
            .timeout @timeout
            .then (response)=>
                @_parseResponse response

        return @_handleErrors promise

    # GitHub File Calls ############################################################################

    createFile: (owner, repo, path, message, content)->
        @_requireAuthorization()

        body = content:content, message:message
        promise = http.put "#{@apiBaseUrl}/repos/#{owner}/#{repo}/contents/#{path}", headers:@_headers, body:body
            .timeout @timeout
            .then (response)=>
                @_parseResponse response
                return null

        return @_handleErrors promise

    fetchFile: (owner, repo, path)->
        @_requireAuthorization()

        promise = http.get "#{@apiBaseUrl}/repos/#{owner}/#{repo}/contents/#{path}", headers:@_headers
            .timeout @timeout
            .then (response)=>
                data = @_parseResponse response
                return result =
                    content: data.content
                    sha: data.sha
            .catch (error)=>
                if error.statusCode is HttpStatus.notFound
                    return content:'', sha:null
                else
                    throw error

        return @_handleErrors promise

    updateFile: (owner, repo, path, message, content, sha)->
        @_requireAuthorization()

        body = content:content, message:message, sha:sha
        promise = http.put "#{@apiBaseUrl}/repos/#{owner}/#{repo}/contents/#{path}", headers:@_headers, body:body
            .timeout @timeout
            .then (response)=>
                @_parseResponse response
                return null

        return @_handleErrors promise

    # GitHub Login Calls ###########################################################################

    completeLogin: (code)->
        if not code? then return w.reject throw new Error 'code is required'

        body = client_id:@clientId, client_secret:@clientSecret, code:code
        promise = http.post "#{@baseUrl}/login/oauth/access_token", headers:@_headers, body:body
            .timeout @timeout
            .then (response)=>
                data = @_parseResponse response
                if not data.access_token?
                    throw new Error "GitHub request failed: No access code included in body: #{response.body}"
                @accessToken = data.access_token
                return null

        return @_handleErrors promise

    # GitHub User Calls ############################################################################

    fetchCurrentUser: ->
        @_requireAuthorization()

        promise = http.get "#{@apiBaseUrl}/user", headers:@_headers
            .timeout @timeout
            .then (response)=>
                data = @_parseResponse response
                gitHubUser = _.pick data, 'id', 'avatar_url', 'email', 'login', 'name'
                return gitHubUser

        return @_handleErrors promise

    # Private Methods ##############################################################################

    _handleErrors: (promise)->
        promise.catch (error)=>
            if error instanceof w.TimeoutError
                HttpStatus.gatewayTimeout.throw 'GitHub failed to respond'
            else
                HttpStatus.badGateway.throw error.message, {}, error

    _parseResponse: (response)->
        logger.verbose "GitHub response: #{_.ellipsize(_.pp(response), 1024)}"

        if response.statusCode is 404
            HttpStatus.notFound.throw "GitHub could not find the requested resource"

        if response.statusCode is 204
            return {}

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

    _requireAdmin: ->
        if not @adminToken? then throw new Error "admin token required"
        @_headers['Authorization'] = "token #{@adminToken}"

    _requireAuthorization: ->
        if not @accessToken? then throw new Error "user must be logged in first"
        @_headers['Authorization'] = "token #{@accessToken}"
