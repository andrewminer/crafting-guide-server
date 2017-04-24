#
# Crafting Guide Server - add_mod_votes.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

{Logger}      = require("crafting-guide-common").util
global.logger = new Logger level:Logger.WARNING

w = require "when"
global.Promise = w.Promise

store   = require "../../store"
Mod     = store.definitions.Mod
ModVote = store.definitions.ModVote
User    = store.definitions.User

process.argv.shift() # coffee
process.argv.shift() # script file

if process.argv.length isnt 3
    console.log "USAGE: add_mod_votes <mod name> <vote count> <url>"
    process.exit 1

[modName, voteCount, url] = process.argv
voteCount = Number.parseInt voteCount

if Number.isNaN voteCount
    console.log "Invalid vote count: #{process.argv[1]}"
    process.exit 1

dataLoaded = []

createModVote = (modId, count)->
    return w(true) if count is 0
    User.create name:"Anonymous Voter"
        .then (user)->
            ModVote.create modId:modId, userId:user.id
        .then (modVote)->
            createModVote modId, count - 1

loadModVote = (modName, voteCount, url)->
    Mod.create name:modName, url:url
        .then (mod)->
            createModVote mod.id, voteCount

dataLoaded.push loadModVote modName, voteCount, url

w.all dataLoaded
    .catch (error) -> console.error "failed to insert mod: #{error.stack}"
    .then -> process.exit 0

