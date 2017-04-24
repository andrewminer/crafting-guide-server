#
# Crafting Guide Server - mod_votes.test.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

Harness          = require "../../test/harness"
store            = require "../store"
{TestHttpServer} = require("crafting-guide-common").api

Mod     = store.definitions.Mod
ModVote = store.definitions.ModVote
User    = store.definitions.User

########################################################################################################################

harness = new Harness

removeTimestamps = (obj)->
    delete obj.createdAt
    delete obj.updatedAt
    return obj

createPrimaryData = ->
    w.all(
        Mod.create id:1, name:"Alpha", url:"http://alpha.com"
        Mod.create id:2, name:"Bravo", url:"http://bravo.com"
        User.create id:1
        User.create id:2
    )

createModVotes = ->
    createPrimaryData()
        .then =>
            w.all(
                ModVote.create id:1, modId:1, userId:1
                ModVote.create id:2, modId:2, userId:1
                ModVote.create id:3, modId:2, userId:2
            )

########################################################################################################################

describe "router: /modVotes", ->
    @slow 250 # ms

    before -> harness.before()
    beforeEach -> harness.beforeEach()

    describe "/ GET", ->

        it "returns all votes for the current user", ->
            createModVotes()
                .then =>
                    harness.login id:1
                    harness.client.getModVotes()
                .then (response)=>
                    votes = response.json
                    (v.modId for v in votes).should.eql [1, 2]

    describe "/ POST", ->

        it "creates a new mod vote", ->
            createPrimaryData()
                .then =>
                    harness.login id:2
                    harness.client.castVote modId:1
                .then (response)=>
                    modVote = removeTimestamps response.json
                    modVote.should.eql id:1, modId:1, userId:2

                    ModVote.find(1)
                .then (modVote)=>
                    modVote = removeTimestamps modVote.toHash()
                    modVote.should.eql id:1, modId:1, userId:2

        it "does not allow duplicate votes", ->
            createModVotes()
                .then =>
                    harness.login id:1
                    harness.client.castVote modId:1
                .catch (error)=>
                    error.response.json.message.should.match /duplicate/
                    ModVote.findAll(userId:1, modId:1)
                .then (modVotes)=>
                    (v.id for v in modVotes).should.eql [1]

    describe "/:modVoteId DELETE", ->

        it "removes an existing mod vote", ->
            createModVotes()
                .then =>
                    harness.login id:1
                    harness.client.cancelVote modVoteId:2
                .then (response)=>
                    response.statusCode.should.equal 200

                    ModVote.find(2)
                .catch (error)=>
                    error.message.should.match /not found/i

                    ModVote.findAll(userId:1)
                .then (modVotes)=>
                    (v.id for v in modVotes).should.eql [1]

        it "requires an existing mod vote", ->
            w(true)
                .then =>
                    harness.login id:1
                    harness.client.cancelVote modVoteId:1
                .catch (error)=>
                    error.response.json.message.should.match /modVote not found/

        it "requires the modVote match the current user", ->
            createModVotes()
                .then =>
                    harness.login id:2
                    harness.client.cancelVote modVoteId:1
                .catch (error)=>
                    error.response.json.message.should.match /not authorized/
