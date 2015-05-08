###
Crafting Guide Server - github.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

GitHubClient   = require '../models/github_client'
express        = require 'express'
{Repo}         = require '../constants'
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

# Private Routes ###################################################################################

router.get '/user', requireLogin, (request, response)->
    response.api ->
        request.gitHubClient.fetchCurrentUser()
            .then (user)->
                request.session.user = user
                return data:user:user

router.get '/file/*', requireLogin, (request, response)->
    owner = Repo.craftingGuideData.owner
    path  = request.params[0]
    repo  = Repo.craftingGuideData.name

    response.api ->
        request.gitHubClient.fetchFile owner, repo, path
            .then (fileRecord)->
                fileRecord.path = path
                return data:fileRecord

router.put '/file/*', requireLogin, (request, response)->
    content = request.body.content
    message = request.body.message
    owner   = Repo.craftingGuideData.owner
    path    = request.params[0]
    repo    = Repo.craftingGuideData.name
    sha     = request.body.sha

    response.api ->
        request.gitHubClient.updateFile owner, repo, path, message, content, sha
