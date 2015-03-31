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

        if not @clientId? then throw new Error "A GitHub Client Id. must be provided"
        if not @clientSecret? then throw new Error "A GitHub Client Secret must be provided"

    # GitHub Login Calls ###########################################################################

    completeLogin: (code)->
        if not code? then return w.reject throw new Error 'code is required'

        headers = accept:'application/json'
        body    = client_id:@clientId, client_secret:@clientSecret, code:code

        http.post "#{@baseUrl}/login/oauth/access_token", headers:headers, body:body
            .timeout @timeout
            .then (response)=>
                if response.statusCode isnt 200
                    throw new Error "GitHub request failed: #{response.statusCode} #{response.body}"

                data = JSON.parse response.body
                if not data.access_token?
                    throw new Error "GitHub request failed: No access code included in body: #{response.body}"

                @accessToken = data.access_token
                return this
            .catch (error)->
                HttpStatus.badGateway.throw error.message, {}, error
            .catch w.TimeoutError, -> HttpStatus.gatewayTimeout.throw 'GitHub failed to respond'

    # GitHub User Calls ############################################################################

    fetchCurrentUser: ->
        if not @accessToken? then throw new Error "user must be logged in first"

        headers = authorization: "token #{@accessToken}"
        http.get "#{@apiBaseUrl}/user", headers:headers
            .then (response)=>
                data = JSON.parse response.body
                user = _.pick data, 'id', 'login', 'avatar_url', 'name', 'email'
                return user
