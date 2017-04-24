#
# Crafting Guide Server - mod_vote.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_              = require "../underscore"
express        = require "express"
{requireLogin} = require "../middleware"
status         = require "../http_status"
store          = require "../store"

ModVote = store.definitions.ModVote

########################################################################################################################

module.exports = router = express.Router()

# Public Routers ###################################################################################

router.get "/", requireLogin, (request, response)->
    response.api ->
        ModVote.findAll userId:request.user.id, orderBy:["modId"]
            .then (votes)->
                return (v.toHash() for v in votes)

router.post "/", requireLogin, (request, response)->
    modId = request.body.modId
    if not modId? then status.badRequest.throw "modId is required"

    response.api ->
        ModVote.findAll(userId:request.user.id, modId:modId)
            .then (modVotes)->
                if modVotes.length > 0 then status.badRequest.throw "duplicate mod vote"

                ModVote.create userId:request.user.id, modId:modId
            .then (modVote)->
                return modVote.toHash()

router.delete "/:modVoteId", requireLogin, (request, response)->
    modVoteId = request.params.modVoteId
    if not modVoteId? then status.badRequest.throw "modVoteId is required"

    userId = request.user.id
    response.api =>
        ModVote.find(modVoteId)
            .then (modVote)->
                if not modVote? then status.notFound.throw "modVote not found"
                if modVote.userId isnt userId then status.forbidden.throw "not authorized to delete this modVote"

                ModVote.destroy modVoteId
            .catch (error)->
                if error.message.match /not found/i then status.notFound.throw "modVote not found"
                throw error
            .then ->
                return null
