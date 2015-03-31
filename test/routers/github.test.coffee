###
Crafting Guide Server - github.test.coffee

Copyright (c) 2015 by Redwood Labs
All rights reserved.
###

GitHubClient     = require '../../src/models/github_client'
Harness          = require '../harness'
{TestHttpServer} = require 'crafting-guide-common'

########################################################################################################################

process.env.GITHUB_CLIENT_ID = 'cid'
process.env.GITHUB_CLIENT_SECRET = 'cse'

GitHubClient.API_BASE_URL = 'http://localhost:8002'
GitHubClient.BASE_URL     = 'http://localhost:8002'

harness = new Harness
gitHubServer = null

########################################################################################################################

describe 'router: /github', ->

    before ->
        gitHubServer = new TestHttpServer 8002
        w.join gitHubServer.start(), harness.before()

    beforeEach -> w.join gitHubServer.clear(), harness.beforeEach()

    after -> w.join gitHubServer.stop()

    describe '/complete-login', ->

        it 'returns a user object when successful', ->
            userData = id:1, login:'log', avatar_url:'ava', name:'nam', email:'ema'

            gitHubServer.pushResponse statusCode:200, body:JSON.stringify access_token:'tok'
            gitHubServer.pushResponse statusCode:200, body:JSON.stringify userData

            harness.client.completeGitHubLogin code:'cod'
                .then (response)->
                    user = response.json.data.user
                    user.should.eql userData

                    r = gitHubServer.requests[0]
                    r.method.should.equal 'POST'
                    r.url.should.equal    '/login/oauth/access_token'
                    r.body.should.equal   JSON.stringify client_id:'cid', client_secret:'cse', code:'cod'

                    r = gitHubServer.requests[1]
                    r.method.should.equal 'GET'
                    r.url.should.equal '/user'
                    r.body.should.equal ''

                    gitHubServer.requests.length.should.equal 2

        it 'returns an error if the GitHub call fails', ->
            gitHubServer.pushResponse statusCode:500, body:'internal server error'

            harness.client.completeGitHubLogin code:'cod'
                .catch (error)->
                    error.response.statusCode.should.equal 502
                    error.response.json.message.should.equal 'GitHub request failed: 500 internal server error'

        it 'returns an error if no access token was returned', ->
            gitHubServer.pushResponse statusCode:200, body:JSON.stringify message:'nothing to see here'

            harness.client.completeGitHubLogin code:'cod'
                .catch (error)->
                    error.response.statusCode.should.equal 502
                    error.response.json.message.should.equal 'GitHub request failed: No access code included in ' +
                        'body: {"message":"nothing to see here"}'
