###
Crafting Guide Server - github.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

GitHubClient = require '../models/github_client'
express      = require 'express'
{http}       = require 'crafting-guide-common'

########################################################################################################################

module.exports = router = express.Router()

# Public Routers ###################################################################################

router.post '/complete-login', (request, response)->
    client = new GitHubClient
    response.api ->
        client.completeLogin request.body.code
            .then ->
                request.session.accessToken = client.accessToken
                request.gitHubClient.accessToken = client.accessToken
                client.fetchCurrentUser()
            .then (user)->
                request.session.user = user
                return data:user:user
