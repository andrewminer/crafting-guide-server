#
# Crafting Guide - github.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

express        = require 'express'
GitHubClient   = require '../models/github_client'
store          = require '../store'
{http}         = require 'crafting-guide-common'
{Repo}         = require '../constants'
{requireLogin} = require '../middleware'

User = store.definitions.User

########################################################################################################################

module.exports = router = express.Router()

# Public Routers ###################################################################################

router.post '/session', (request, response)->
    gitHubUser = null

    response.api ->
        client = request.gitHubClient
        client.completeLogin request.body.code
            .then ->
                client.fetchCurrentUser()
            .then (g)->
                gitHubUser = g
                User.findAll gitHubId:gitHubUser.id
            .then (users)->
                if users.length > 0
                    user = users[0]
                else
                    user = User.createInstance()

                user.copyGitHubUser gitHubUser
                user.gitHubAccessToken = client.accessToken
                User.create user, upsert:true
            .then (user)->
                request.session.userId = user.id
                return user

router.delete '/session', (request, response)->
    response.api ->
        return null unless request.user?

        User.update request.user.id, gitHubAccessToken:null
            .then ->
                for key, value of request.session
                    delete request.session[key]
                return null

# Private Routes ###################################################################################

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
    login   = request.session.user.login

    response.api ->
        request.gitHubClient.isCollaborator owner, repo, login
            .then (isCollaborator)->
                if not isCollaborator
                    request.gitHubClient.addCollaborator owner, repo, login
            .then ->
                if sha?
                    request.gitHubClient.updateFile owner, repo, path, message, content, sha
                else
                    request.gitHubClient.createFile owner, repo, path, message, content
