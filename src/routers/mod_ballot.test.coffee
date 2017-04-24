#
# Crafting Guide Server - mod_ballots.test.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

Harness          = require "../../test/harness"
store            = require "../store"

Mod     = store.definitions.Mod
ModVote = store.definitions.ModVote
User    = store.definitions.User

########################################################################################################################

harness = new Harness

########################################################################################################################

describe "router: /mod_ballot", ->
    @slow 250 # ms

    before -> harness.before()
    beforeEach -> harness.beforeEach()

    describe "/ GET", ->

        it "returns a populated mod ballot", ->
            w(true)
                .then =>
                    w.all(
                        Mod.create id:1, name:"Alpha", url:"http://alpha.com"
                        Mod.create id:2, name:"Bravo", url:"http://bravo.com"
                        User.create id:1
                        User.create id:2
                    )
                .then =>
                    w.all(
                        ModVote.create id:1, modId:1, userId:1
                        ModVote.create id:2, modId:2, userId:1
                        ModVote.create id:3, modId:2, userId:2
                    )
                .then =>
                    harness.client.getModBallot()
                .then (response)=>
                    ballot = response.json
                    (l.modId for l in ballot.lines).should.eql [2, 1]
                    (l.name for l in ballot.lines).should.eql ["Bravo", "Alpha"]
