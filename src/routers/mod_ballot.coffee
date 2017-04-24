#
# Crafting Guide Server - mod_ballot.coffee
#
# Copyright © 2014-2017 by Redwood Labs
# All rights reserved.
#

_               = require "../underscore"
express         = require "express"
ModBallotLoader = require "../models/mod_ballot_loader"
store           = require "../store"

########################################################################################################################

module.exports = router = express.Router()

# Public Routers ###################################################################################

router.get "/", (request, response)->
    response.api ->
        loader = new ModBallotLoader store.getAdapter("sql").query
        loader.load()
            .then (ballot)->
                ballot.toHash()
