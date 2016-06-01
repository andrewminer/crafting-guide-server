#
# Crafting Guide - mod_ballot_loader.test.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

ModBallotLoader = require './mod_ballot_loader'
store           = require '../store'
_               = require 'underscore'

Mod           = store.definitions.Mod
ModBallot     = store.definitions.ModBallot
ModBallotLine = store.definitions.ModBallotLine
ModVote       = store.definitions.ModVote
User          = store.definitions.User

########################################################################################################################

createModVotes = ->
    w(true)
        .then =>
            w.all(
                Mod.create id:1, name:'Alpha',   url:'http://alpha.com'
                Mod.create id:2, name:'Bravo',   url:'http://bravo.com'
                Mod.create id:3, name:'Charlie', url:'http://charlie.com'

                User.create id:1
                User.create id:2
                User.create id:3
            )
        .then =>
            w.all(
                ModVote.create id:1, modId:3, userId:1
                ModVote.create id:2, modId:2, userId:1
                ModVote.create id:3, modId:3, userId:2
                ModVote.create id:4, modId:1, userId:2
                ModVote.create id:5, modId:3, userId:3
                ModVote.create id:6, modId:2, userId:3
            )

########################################################################################################################

describe "mod_ballot_loader.coffee", ->
    @slow 200 # ms

    beforeEach ->
        @db = store.getAdapter('sql').query

    it 'should return an empty ballot with no data', ->
        ModBallotLoader.loadFrom @db
            .then (ballot)->
                ballot.lines.should.eql []

    it 'should return a fully populated ballot', ->
        createModVotes()
            .then =>
                ModBallotLoader.loadFrom @db
            .then (ballot)=>
                (l.modId for l in ballot.lines).should.eql [3, 2, 1]
