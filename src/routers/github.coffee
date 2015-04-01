###
Crafting Guide Server - github.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

GitHubClient   = require '../models/github_client'
express        = require 'express'
{http}         = require 'crafting-guide-common'
{requireLogin} = require '../middleware'

########################################################################################################################

module.exports = router = express.Router()

# Public Routers ###################################################################################

router.post '/complete-login', (request, response)->
    response.api ->
        client = request.gitHubClient
        client.completeLogin request.body.code
            .then ->
                request.session.accessToken = client.accessToken
                client.accessToken = client.accessToken
                client.fetchCurrentUser()
            .then (user)->
                request.session.user = user
                return data:user:user

router.delete '/logout', (request, response)->
    response.api ->
        request.session.accessToken = null
        request.session.user = null

router.get '/user', requireLogin, (request, response)->
    response.api ->
        request.gitHubClient.fetchCurrentUser()
            .then (user)->
                request.session.user = user
                return data:user:user
