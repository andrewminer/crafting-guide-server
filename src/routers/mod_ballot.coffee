#
# Crafting Guide - mod_ballot.coffee
#
# Copyright © 2014-2016 by Redwood Labs
# All rights reserved.
#

express         = require 'express'
ModBallotLoader = require '../models/mod_ballot_loader'
store           = require '../store'
_               = require '../underscore'

########################################################################################################################

module.exports = router = express.Router()

# Public Routers ###################################################################################

router.get '/', (request, response)->
    response.api ->
        loader = new ModBallotLoader store.getAdapter('sql').query
        loader.load()
            .then (ballot)->
                ballot.toHash()
