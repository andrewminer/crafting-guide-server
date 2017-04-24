#
# Crafting Guide Server - github.test.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

GitHubClient     = require "../models/github_client"
Harness          = require "../../test/harness"
{TestHttpServer} = require("crafting-guide-common").api

########################################################################################################################

process.env.GITHUB_CLIENT_ID = "cid"
process.env.GITHUB_CLIENT_SECRET = "cse"

GitHubClient.API_BASE_URL = "http://localhost:8002"
GitHubClient.BASE_URL     = "http://localhost:8002"

harness = new Harness
gitHubServer = null

########################################################################################################################

describe "router: /github", ->
    @slow 250 # ms

    before ->
        gitHubServer = new TestHttpServer 8002
        w.join gitHubServer.start(), harness.before()

    beforeEach ->
        @gitHubUserData =
            avatar_url: "http://avatar.url"
            email:      "test.subject@email.com"
            id:         "123"
            login:      "test_subject"
            name:       "Test Subject"

        @userData =
            avatarUrl:   "http://avatar.url"
            email:       "test.subject@email.com"
            gitHubId:    123
            gitHubLogin: "test_subject"
            name:        "Test Subject"

        w.join gitHubServer.clear(), harness.beforeEach()

    after -> w.join gitHubServer.stop()

    describe "/session POST", ->

        it "returns a user object when successful", ->
            gitHubServer.pushResponse statusCode:200, body:JSON.stringify access_token:"tok"
            gitHubServer.pushResponse statusCode:200, body:JSON.stringify @gitHubUserData

            harness.client.createSession code:"cod"
                .then (response)=>
                    user = response.json
                    _.pick(user, _.keys(@userData)).should.eql @userData

                    r = gitHubServer.requests[0]
                    r.method.should.equal "POST"
                    r.url.should.equal    "/login/oauth/access_token"
                    r.body.should.equal   JSON.stringify client_id:"cid", client_secret:"cse", code:"cod"

                    r = gitHubServer.requests[1]
                    r.method.should.equal "GET"
                    r.url.should.equal "/user"
                    r.body.should.equal ""

                    gitHubServer.requests.length.should.equal 2

        it "returns an error if the GitHub call fails", ->
            gitHubServer.pushResponse statusCode:500, body:"internal server error"

            harness.client.createSession code:"cod"
                .catch (error)->
                    error.response.statusCode.should.equal 502
                    error.response.json.message.should.equal "Could not parse GitHub's response " +
                         "(SyntaxError: Unexpected token i in JSON at position 0): internal server error"

        it "returns an error if no access token was returned", ->
            gitHubServer.pushResponse statusCode:200, body:JSON.stringify message:"nothing to see here"

            harness.client.createSession code:"cod"
                .catch (error)->
                    error.response.statusCode.should.equal 502
                    error.response.json.message.should.equal "GitHub request failed: No access code included in " +
                        "body: {\"message\":\"nothing to see here\"}"

    describe "/logout", ->

        it "causes subsequent calls to request a login", ->
            gitHubServer.pushResponse statusCode:200, body:JSON.stringify access_token:"tok"
            gitHubServer.pushResponse statusCode:200, body:JSON.stringify @gitHubUserData
            gitHubServer.pushResponse statusCode:200, body:JSON.stringify @gitHubUserData
            loginRequested = false

            harness.client.createSession code:"cod"
                .then (response)=>
                    _.pick(response.json, _.keys(@userData)).should.eql @userData
                    harness.client.getCurrentUser()
                .then (response)=>
                    _.pick(response.json, _.keys(@userData)).should.eql @userData
                    harness.client.deleteSession()
                .then ->
                    harness.client.getCurrentUser()
                .catch (error)->
                    if not error.response? then throw error

                    error.response.statusCode.should.equal 401
                    error.response.json.message.should.equal "Not logged in"

    describe "/user", ->

        it "returns a full user record when logged in", ->
            gitHubServer.pushResponse statusCode:200, body:JSON.stringify access_token:"tok"
            gitHubServer.pushResponse statusCode:200, body:JSON.stringify @gitHubUserData
            gitHubServer.pushResponse statusCode:200, body:JSON.stringify @gitHubUserData

            harness.client.createSession code:"cod"
                .then (response)=>
                    _.pick(response.json, _.keys(@userData)).should.eql @userData

                    harness.client.getCurrentUser()
                        .then (response)=>
                            _.pick(response.json, _.keys(@userData)).should.eql @userData
